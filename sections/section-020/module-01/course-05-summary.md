# Summary

Kyverno teaches mission control's registry desk a set of new forms, called custom resource definitions (CRDs). You write some of them. Kyverno's crews write the others.

## What you learned

- **The Kyverno CRD map.** You listed every form with `kubectl get crd | grep kyverno.io`, learned that the report cards live in the `wgpolicyk8s.io` group, and read versions and fields with `kubectl get crd ... -o jsonpath` and `kubectl explain`. See [The Kyverno CRD Map](./course-01-the-kyverno-crd-map.md).
- **Policy exceptions.** A `PolicyException` is a signed waiver. It does nothing until the admission controller runs with `--enablePolicyException=true`, and it only counts when it sits on the planet named by `--exceptionNamespace`. See [Policy Exceptions](./course-02-policy-exceptions.md).
- **Cleanup policies and global context entries.** `CleanupPolicy` and `ClusterCleanupPolicy` need `match` and `schedule`, and `conditions` is optional. `GlobalContextEntry` caches data once for many rules. See [Cleanup Policies and Global Context Entries](./course-03-cleanup-policies-and-global-context.md).
- **Generated CRDs.** `PolicyReport` and `ClusterPolicyReport` are the cards you read, `EphemeralReport` objects are scratch notes, and `UpdateRequest` is the construction crew's queue. See [Generated CRDs: Reports and Queues](./course-04-generated-crds-reports-and-queues.md).

## Missions

| Mission | What it asks | Lab name |
| --- | --- | --- |
| PolicyException CRD Lab | Switch waivers on, write one waiver for one Pod, prove another Pod is still refused | `ats-008-lab-003` |

## Check yourself

- Which two forms list the objects that Kyverno found wrong, and in which API group do they live?
- You filed a `PolicyException` and the Pod is still refused. Name two causes.
- Which command tells you the versions of a form that your cluster serves?
- Which family do `PolicyException` and `EphemeralReport` belong to?

When you have finished, clean up the playground. List what is running, then destroy it:

```sh
astrona list
astrona destroy ats-008-playground-020-01
```

<!-- astrona:playground:destroy -->
