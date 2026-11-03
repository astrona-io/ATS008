# The Four Controllers and Their Flags

Kyverno is a station with four crews. Each crew is a Deployment in the `kyverno` namespace, and each runs its own program with its own flags. A flag that one crew accepts can be unknown to another. This part shows you what each crew does and how to read the flags it is running with right now.

## One install, four crews

A default Helm install creates four Deployments. Each one has a clear job:

| Controller (Deployment) | Space picture | Job |
| --- | --- | --- |
| `kyverno-admission-controller` | The inspectors at the launch gate | Answers the webhook call for every matching request |
| `kyverno-background-controller` | The construction crew | Does `generate` and mutate-existing work after launch |
| `kyverno-reports-controller` | The records office | Scans existing objects and files `PolicyReport` objects |
| `kyverno-cleanup-controller` | The salvage crew | Deletes objects on the schedule of a cleanup policy |

Because the crews are separate programs, one change never reaches all four. When something is slow or late, you first work out which crew owns the problem.

### Flags you can tune

A few flags are worth knowing by name. Each one belongs to one crew:

| Controller | Flag | What it controls |
| --- | --- | --- |
| Admission | `--webhookTimeout` | How many seconds the API server waits for an answer |
| Admission | `--enablePolicyException` | Whether `PolicyException` objects are honoured |
| Admission | `--exceptionNamespace` | The one namespace where exceptions are accepted |
| Background | `--genWorkers` | How many generate jobs run at the same time |
| Reports | `--backgroundScanInterval` | How often existing objects are scanned |
| Reports | `--backgroundScanWorkers` | How many scans run at the same time |
| Cleanup | `--ttlReconciliationInterval` | How often the crew looks for objects past their time to live |

Every crew also accepts a few shared flags, such as `--v` for how chatty its log is and `--loggingFormat` for the log layout.

## Read a crew's live flags

The Deployment holds the truth. Its Pod template lists the exact `args` that the program starts with. Reading them takes one command, and it is the habit to build first.

<!-- astrona:playground:renew -->

### See it in your playground

List the four Deployments and check that all of them are ready:

```sh
kubectl get deploy -n kyverno
```

You should see four rows, one for each crew, each with its Pods ready.

Now print the flags of the admission controller, one per line:

```sh
kubectl get deploy kyverno-admission-controller -n kyverno \
  -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}'
```

Look for `--enablePolicyException=false` and `--autoUpdateWebhooks=true`. The chart wrote both of them. A flag you did not set yourself is still on the list, because the chart fills in many dials for you.

Run the same loop for all four crews:

```sh
for crew in admission background reports cleanup; do
  echo "== $crew"
  kubectl get deploy "kyverno-$crew-controller" -n kyverno \
    -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}'
done
```

The four lists differ. Only the reports list has `--backgroundScanInterval`, and only the cleanup list has `--ttlReconciliationInterval`. The background list has no `--genWorkers` at all, because the chart leaves that dial alone and the program uses its own built-in default.

### Where the chart's flags come from

Some flags come from their own chart values. The reports controller's `--backgroundScanInterval=1h` comes from `features.backgroundScan.backgroundScanInterval`, and the admission controller's `--autoUpdateWebhooks=true` comes from `features.autoUpdateWebhooks.enabled`. You can check any value without touching the cluster:

```sh
helm show values kyverno/kyverno | grep -n "backgroundScanInterval"
```

For any flag that the chart has no value for, you write it into `extraArgs`. The next part shows how.

## Which crew owns the symptom

Because the crews are independent, two symptoms that look alike can have different owners:

- A launch request takes too long to answer. The inspectors own it, so look at `--webhookTimeout`.
- A generated object appears late. The construction crew owns it, so look at `--genWorkers`.
- A `PolicyReport` is out of date. The records office owns it, so look at `--backgroundScanInterval`.
- Old objects are not removed on time. The salvage crew owns it, so look at `--ttlReconciliationInterval`.

## Common pitfalls

> [!WARNING]
> - **Assuming one flag list for all four crews.** Each crew is a different program. A flag that one program does not know can stop its Pods from starting, so always read the live `args` of the right Deployment.
> - **Trusting a values file instead of the cluster.** The live Deployment tells you what runs. A file on your laptop only tells you what you meant.
> - **Reading only one Deployment.** `kubectl get pods -n kyverno` shows four Pods, and a change that reached one crew says nothing about the other three.
