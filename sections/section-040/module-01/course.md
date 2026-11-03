# Kyverno's RBAC Model

Kyverno is not one program. It is four crews, and each crew flies under its own registration papers (a service account). What each crew is allowed to do comes from clearance cards, which Kubernetes calls ClusterRoles. A crew that can touch everything is a danger. A crew that is missing one card cannot finish its job.

This module shows how the four crews get their cards, and how you add one more card the safe way, so the next `helm upgrade` does not take it away.

The module has two parts. **ServiceAccounts, Aggregated ClusterRoles and the View Role** names the four service accounts and shows how a master card collects every card that carries a stamp. **Granting Extra Permissions Safely** shows a `generate` rule that cannot build its target, and fixes it with a new, stamped ClusterRole.

## Learning objectives

After this module you can:

- Name the four Kyverno controllers and their service accounts.
- Explain how ClusterRole aggregation builds a controller's permissions from labelled ClusterRoles.
- Match each `rbac.kyverno.io/aggregate-to-<controller>-controller` label to the controller it extends.
- Explain what the built-in `view` role binding gives the controllers.
- Diagnose a `generate` rule that fails for lack of permission, and fix it with a new ClusterRole instead of editing a shipped one.
- Prove the result with `kubectl auth can-i --as=system:serviceaccount:kyverno:...`.

## Before you start

You need `kubectl` and a feel for `ClusterRole` and `ClusterRoleBinding`. A `ClusterRole` is a clearance card: a list of allowed actions (verbs) on kinds of objects. A `ClusterRoleBinding` hands that card to a service account.

## Where you practise

Your playground is a training solar system with Kyverno installed by Helm as release `kyverno` in the `kyverno` namespace. The `ClusterPolicy` `generate-default-quota` should create a `ResourceQuota` named `default-quota` in every new namespace. On purpose, the playground removes the chart's default permission for the background controller to create `ResourceQuota` objects, so the rule has nothing to build with until you grant it. The playground also gives you a helper called `can_do` that asks the clearance office whether a controller may do something.

The module ends with a graded mission that starts a fresh cluster in the same state.

Launch your playground now, and keep it running next to you while you read the parts:

<!-- astrona:playground -->
