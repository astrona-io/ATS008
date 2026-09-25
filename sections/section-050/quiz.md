# Section 050 Knowledge Check: High Availability Installations

Test your understanding of per-controller replica semantics, leader election, the documented HA install command, and general node-spreading hygiene.

---

## Scenario-Based Questions

### Question 1
Which Kyverno controller has NO leader election governing its main job of processing incoming AdmissionReview requests, meaning all of its replicas can serve traffic simultaneously?
*   **A)** The background controller.
*   **B)** The reports controller.
*   **C)** The admission controller.
*   **D)** The cleanup controller.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Kyverno's own documentation states the admission controller "does not use leader election for inbound webhook requests," so AdmissionReview traffic is distributed and processed by every available replica. It only uses leader election for a secondary job — certificate and webhook-configuration management.
*   **Why others are incorrect:**
    *   *Options A and B* — the background and reports controllers both require leader election for their core work; only one replica processes at a time regardless of replica count.
    *   *Option D* — the cleanup controller is hybrid: leader-elected for certificate/webhook management, but its cleanup-invocation handling is not.
</details>

---

### Question 2
What is Kyverno's documented minimum recommended replica count for the admission controller in a production installation?
*   **A)** 1
*   **B)** 2
*   **C)** 3
*   **D)** 5

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Kyverno's documentation recommends a minimum of 3 replicas for the admission controller in production, backed by benchmark data showing 3 replicas keep p99 latency under 650ms at 500 concurrent virtual users, versus over 1 second with a single replica.
*   **Why others are incorrect:**
    *   *Options A and B* are below the documented minimum.
    *   *Option D* is higher than what the documentation specifies as the baseline recommendation.
</details>

---

### Question 3
You set `backgroundController.replicas=5`, expecting background scans to run roughly five times faster. What actually happens?
*   **A)** Background scan throughput increases roughly 5x, since all replicas process resources concurrently.
*   **B)** Only one replica — the elected leader — handles the actual background-scan/generate work at any given time; the other four are standby replicas providing failover, not extra throughput.
*   **C)** Kyverno rejects any `replicas` value above 2 for the background controller.
*   **D)** Each replica handles scans for a different, non-overlapping set of namespaces automatically.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** The background controller uses leader election for its core work — "only a single replica of the background controller will handle the final resource generation," regardless of how many replicas are running. Extra replicas exist purely so a new leader can take over quickly if the current one fails.
*   **Why others are incorrect:**
    *   *Option A* describes the admission controller's behavior, not the background controller's.
    *   *Option C* invents a restriction that doesn't exist.
    *   *Option D* invents automatic namespace-sharding behavior Kyverno does not implement this way.
</details>

---

### Question 4
What do extra replicas of the reports controller and cleanup controller actually provide?
*   **A)** Proportionally faster report aggregation and cleanup execution.
*   **B)** Failover — if the current leader Pod fails, a standby replica takes over quickly — not additional processing throughput.
*   **C)** Nothing; extra replicas of these controllers are silently ignored by Kyverno.
*   **D)** Automatic horizontal sharding of PolicyReport objects across replicas.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Like the background controller, the reports controller relies on leader election for its core processing — only one replica is ever actively working. Extra replicas exist for resilience against a Pod or node failure, not to speed up processing.
*   **Why others are incorrect:**
    *   *Option A* is the admission-controller model, not this one.
    *   *Option C* is wrong — the replicas are real and do take over on failover, they're just not all active simultaneously.
    *   *Option D* invents a sharding mechanism that doesn't exist.
</details>

---

### Question 5
What are the documented HA `helm install` replica values for the admission, background, cleanup, and reports controllers respectively?
*   **A)** 3, 3, 3, 3
*   **B)** 1, 1, 1, 1
*   **C)** 3, 2, 2, 2
*   **D)** 2, 3, 3, 3

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: C**

*   **Why C is correct:** Kyverno's documented HA install command sets `admissionController.replicas=3`, `backgroundController.replicas=2`, `cleanupController.replicas=2`, and `reportsController.replicas=2` — reflecting that only the admission controller benefits from a third replica's extra throughput.
*   **Why others are incorrect:**
    *   *Option A* over-provisions the three leader-elected controllers for no throughput benefit.
    *   *Option B* is below the documented HA minimums across the board.
    *   *Option D* has the asymmetry backwards — it under-provisions the one controller (admission) that actually benefits from extra replicas.
</details>

---

### Question 6
You want to confirm which specific Pod is currently acting as leader for the background controller's leader-elected work. What is the correct command?
*   **A)** `kubectl get pods -n kyverno -l app.kubernetes.io/component=background-controller`
*   **B)** `kubectl get lease -n kyverno` (then inspect the relevant lease's `holderIdentity`)
*   **C)** `kubectl get events -n kyverno --field-selector reason=LeaderElection`
*   **D)** `kubectl top pod -n kyverno`

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** Leader election in Kubernetes is implemented via `Lease` objects; the current leader's identity is recorded in the lease's `holderIdentity` field, which `kubectl describe lease <name> -n kyverno` displays directly.
*   **Why others are incorrect:**
    *   *Option A* only lists Pods that exist — it does not indicate which one currently holds leadership.
    *   *Option C* is not a standard, guaranteed event stream for this purpose.
    *   *Option D* shows resource usage, not leadership state.
</details>

---

### Question 7
Kyverno's documented benchmarks compare 1 admission-controller replica against 3 replicas under 500 concurrent virtual users. What did 3 replicas demonstrate?
*   **A)** No measurable difference in latency or CPU usage compared to 1 replica.
*   **B)** p99 latency stayed under roughly 650ms (versus over 1 second with 1 replica), and peak per-pod CPU usage dropped from roughly 3033m to roughly 1182m.
*   **C)** p99 latency got worse with 3 replicas due to coordination overhead.
*   **D)** CPU usage per pod increased with more replicas, since each still had to process every request.

<details>
<summary><b>Reveal Correct Answer & Teacher's Explanation</b></summary>

**Correct Answer: B**

*   **Why B is correct:** This is the documented evidence for the admission controller's horizontal scaling model — spreading requests across 3 active replicas both improved tail latency and reduced the peak CPU any single Pod had to sustain under load.
*   **Why others are incorrect:**
    *   *Option A* contradicts the documented benchmark data.
    *   *Option C* is the opposite of what was measured.
    *   *Option D* misunderstands horizontal scaling — requests are distributed across replicas, not duplicated to every replica.
</details>
