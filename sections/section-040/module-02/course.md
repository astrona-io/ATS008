# Permissions for the Cleanup, Reports and Admission Controllers

Each Kyverno crew carries only the clearance cards it needs for its own job. That is good for safety, and it has a price: when you ask a crew to do something new, such as salvage a kind of object or patrol a custom resource, it may have no card for it. The crew then fails quietly, and you must know where to look.

This module shows what each of the four crews may do by default, what breaks when a card is missing, and how to add the card with an aggregation label, with the chart values, or both.

The module has three parts. **What Each Controller May Do by Default** reads the four master cards. **When a Controller Lacks a Permission** shows the failures and fixes one of them with a stamped ClusterRole. **Chart Values for Permissions and Least Privilege** sets the same grants through the Helm chart and audits what the crews hold.

## Learning objectives

After this module you can:

- Say what the admission, background, reports and cleanup controllers may do by default.
- Name the four aggregation labels and the controller each one extends.
- Explain what fails when a controller lacks a permission: a cleanup policy, reports for a custom resource, a mutate-existing rule and a generate rule.
- Grant a permission with a ClusterRole that carries an aggregation label, and prove it with `kubectl auth can-i --as=system:serviceaccount:kyverno:...`.
- Use the chart values `clusterRole.extraResources` and `coreClusterRole.extraResources`, and say how they differ.
- Check that no controller holds more than it needs.

## Before you start

You need to know what a `ClusterRole` and a service account are: a ClusterRole is a clearance card, and a service account is a crew's registration papers. You also need to know that Kyverno runs as four controllers: admission (the inspectors at the launch gate), background (the construction crew), reports (the records office) and cleanup (the salvage crew), each under its own service account in the `kyverno` namespace.

## Where you practise

Your playground is a training solar system with Kyverno installed by Helm at default values. The namespace `debris` holds old ConfigMaps for the salvage crew. The custom resource kind `Beacon` has one object in the namespace `harbor`, and the `ClusterPolicy` `beacons-need-owner` should check it. No extra permissions are granted, so two crews have jobs they cannot finish. The playground also gives you a helper called `can_do` that asks the clearance office whether a controller may do something.

The module ends with a graded mission that starts a fresh cluster where the salvage crew cannot delete anything yet.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
