# Summary

Well flown, astronaut. You have finished every part of this module. This page recaps what you learned, lists your mission, lets you check yourself and ends with cleaning up your playground.

## What you learned

This module was about the doors on the registry desk and the badge that the crew behind them shows.

**[Webhook configurations and failure policy](./course-01-webhook-configurations-and-failure-policy.md):**

- The API server calls Kyverno through webhook configurations. Kyverno writes and updates them itself, so a hand edit is lost.
- Each door has `rules`, `failurePolicy`, `timeoutSeconds` and selectors.
- `Fail` refuses a launch when nobody answers, and `Ignore` lets it through. Kyverno policies default to `Fail`.
- A policy can set its own value in `webhookConfiguration`. `features.forceFailurePolicyIgnore.enabled` makes every door fail open.

**[Choosing which launches use the webhooks](./course-02-choosing-which-launches-use-the-webhooks.md):**

- `config.webhooks` holds the `namespaceSelector` and `objectSelector`, and the admission controller copies them into the doors.
- A list you set replaces the default, so write `kube-system` again when you add a namespace.
- The `--webhookTimeout` flag sets how long the desk waits. A flag change restarts the Pod, and a ConfigMap change does not.

**[Certificates for the webhooks](./course-03-certificates-for-the-webhooks.md):**

- Two secrets hold the badge: `kyverno-svc.kyverno.svc.kyverno-tls-ca` and `kyverno-svc.kyverno.svc.kyverno-tls-pair`.
- In the default mode Kyverno renews the badge. With `createSelfSignedCert` nobody does, and with `certManager` cert-manager does.
- Deleting the `tls-pair` secret makes Kyverno issue a new badge with a new serial number. Leave the CA secret alone.

## Your missions

You proved these skills in a graded mission:

| Mission | After the part | What you proved |
| --- | --- | --- |
| [Webhooks, Failure Policy and Certificates Lab](./labs/lab-01/README.md) | Certificates for the webhooks | change the webhook selector and failure policy through Helm and replace the admission certificate |

If you skipped it, go back to it now.

## Check yourself

Try to answer each question before you open the answer.

<details>
<summary>1. The admission controller is down, and a policy has <code>failurePolicy: Fail</code>. What happens to a matching launch?</summary>

The API server refuses it, because nobody answers the door. With `Ignore` the launch goes through unchecked.
</details>

<details>
<summary>2. You edit a Kyverno webhook configuration with <code>kubectl edit</code>. What happens?</summary>

The admission controller writes the configuration again, so your edit is lost. Change the policy or the Helm values.
</details>

<details>
<summary>3. You set <code>config.webhooks</code> with only <code>mission-ops</code> in the <code>NotIn</code> list. What changed for <code>kube-system</code>?</summary>

It is no longer skipped, because the list you set replaces the default. Write both namespaces.
</details>

<details>
<summary>4. Which change replaces the admission controller Pod: a new <code>config.webhooks</code> or a new <code>webhookTimeout</code>?</summary>

The `webhookTimeout` flag. A flag is read at start. The `config.webhooks` value changes the ConfigMap, which the controller reads live.
</details>

<details>
<summary>5. You delete the secret <code>kyverno-svc.kyverno.svc.kyverno-tls-pair</code>. How can you prove the badge was replaced?</summary>

Read the certificate with `openssl x509 -noout -serial` before and after. The serial number is different.
</details>

## Clean up

The playground and each mission run their own cluster on your machine. When you are done with this module, check that none is still running.

First, see what is still running:

```sh
astrona list
```

If something from this module is still listed, remove it by its **name**, not its folder path:

```sh
astrona destroy ats-008-lab-017
astrona destroy ats-008-playground-030-03
```

Run `astrona list` again to check that everything is gone.

> *The doors are written by the crew, the badge is theirs too: set the rules in Helm, and never touch the stamp.*

<!-- astrona:playground:destroy -->
