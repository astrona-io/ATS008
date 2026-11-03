# Summary

Well flown, astronaut. You have finished every part of this module. This page recaps what you learned, lists your missions, lets you check yourself and ends with cleaning up your playground.

## What you learned

This module was about the four crews that make up Kyverno, and about the dials on each crew's control panel.

**[The Four Controllers and Their Flags](./course-01-the-four-controllers-and-their-flags.md):**

- Kyverno is four Deployments: admission (the inspectors), background (the construction crew), reports (the records office) and cleanup (the salvage crew).
- Each crew is its own program with its own flags, such as `--webhookTimeout`, `--genWorkers`, `--backgroundScanInterval` and `--ttlReconciliationInterval`.
- The live truth is the `args` list in the Deployment's Pod template. Read it with `kubectl get deploy ... -o jsonpath`.
- The chart already sets many flags. A flag you add through `extraArgs` comes later in the list and wins.

**[Setting Flags with Helm](./course-02-setting-flags-with-helm.md):**

- `extraArgs` is a map: `genWorkers: 5` becomes `--genWorkers=5`. A list renders as a wrong flag.
- The path is `backgroundController.extraArgs`, `reportsController.extraArgs` and `cleanupController.extraArgs`, but `admissionController.container.extraArgs` for the admission controller.
- `helm template` shows where a flag lands before you touch the cluster, and `helm upgrade --reuse-values` keeps your earlier settings.
- A flag change rolls out new Pods. A change to the Kyverno ConfigMap does not.

## Your missions

You proved these skills in graded missions:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Controller Flag Tuning Lab](./labs/lab-01/README.md) | Setting Flags with Helm | set a flag on two different controllers with Helm and read both back from the live Deployments |
| [Controller Configuration with Flags Capstone Lab](../capstone/labs/lab-01/README.md) | End of the section | set several flags on two controllers in one values file and one upgrade |

If you skipped one, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. Which crew would you tune if a <code>PolicyReport</code> is hours behind?</summary>

The reports controller. Its `--backgroundScanInterval` sets how often it scans existing objects.
</details>

<details>
<summary>2. You set <code>admissionController.extraArgs.webhookTimeout=15</code> and nothing changes. Why?</summary>

The path is wrong. The admission controller's flags sit under `admissionController.container.extraArgs`. Helm raises no error for a key that no template reads.
</details>

<details>
<summary>3. What does <code>extraArgs[0]=--genWorkers=5</code> produce with this chart?</summary>

A flag named `--0=--genWorkers=5`, which is not what you meant. Write `extraArgs.genWorkers=5` instead.
</details>

<details>
<summary>4. The chart sets <code>--backgroundScanInterval=1h</code> and you add 30m in <code>extraArgs</code>. Which value runs?</summary>

`30m`. Both lines are in the list, and the later one wins. Your `extraArgs` flags come after the chart's own.
</details>

<details>
<summary>5. Which command proves a flag really reached the Pods?</summary>

Read the live Deployment: `kubectl get deploy kyverno-background-controller -n kyverno -o jsonpath='{.spec.template.spec.containers[0].args}'`, after `kubectl rollout status` has finished.
</details>

## Clean up

The playground and each mission run their own cluster on your machine. When you are done with this module, check that none is still running.

First, see what is still running:

```sh
astrona list
```

If something from this module is still listed, remove it by its **name**, not its folder path:

```sh
astrona destroy ats-008-lab-005
astrona destroy ats-008-lab-006
astrona destroy ats-008-playground-030-01
```

Run `astrona list` again to check that everything is gone.

> *Four crews, four control panels: read the live flags first, change them through Helm, and read them back.*

<!-- astrona:playground:destroy -->
