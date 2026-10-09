# Writing style for this repo

All study text here (course pages, lab docs, READMEs, comments in YAML and
scripts) is for people learning a technical subject, often for a
certification exam. Many of them are not native English speakers and have no
university degree.

## Plain English

Write the text in Plain English for a general adult audience (18+) without a
university degree. The content must be highly accessible and easy to
understand for non-technical readers, without feeling childish.

Strict guidelines:

1. Target a Flesch-Kincaid Grade Level of 8 or 9 (equivalent to a standard
   newspaper article).
2. Avoid all technical jargon, acronyms, and corporate buzzwords. If a
   technical term is necessary, explain it immediately using an everyday
   analogy.
3. Keep sentences conversational and direct. Split long sentences into two.
4. Use short paragraphs (max 3-4 sentences per paragraph) and clear
   subheadings to make the text scannable.
5. Use the active voice (e.g., "We did this" instead of "This was done by us").

## How this applies to course material

- **Know which file you are in.** A module has a short landing page and a few
  deep-dive parts. The landing page is a map: goals, what to know first, the
  order of the parts, where it fits. The real teaching goes in the parts. A lab
  has a task, a step-by-step solution and a short intro. Keep each file to its
  job. Do not add "Prerequisite: ... Next: ..." navigation lines to pages;
  the landing page and the course outline already give the order.
- **Keep each part short.** One idea per part, about 5 to 8 minutes of
  reading and at most about 8 command blocks, so a learner can finish it with
  the playground in one sitting of about 15 minutes. Split at a natural seam
  where each half ends with something the learner has seen work. Never split
  only to hit a number. When you split, renumber the files, fix every "Part N"
  reference in the module, the wrap-up links and `astrona.yaml`.
- **Every heading gets an intro.** A `##` section that has `###`
  subsections starts with one to three sentences that say what the section
  is about and why it matters, before the first `###`. Never put a `###`
  directly under a `##`.
- **Every module stands on its own.** Never refer to other sections or
  modules: no "see section 040", "as module 3 showed", "you met this in
  section 000", and no links to pages in another module. If the reader needs
  a fact from elsewhere, state the fact directly in one or two sentences.
  This also goes for parts of the same module: never write "Part 2 shows",
  "from Part 1" or "as in Part 3". Say the fact itself ("the commands below
  need `PolicyException` switched on in the admission controller"). The wrap-up page is the one
  exception: it recaps each part and links to it.
  The landing page does not have a "Where this fits" section.
- **Write words out in full.** Do not use informal short forms in prose:
  write "communications", "configuration", "repository", "administrator",
  "for example" and "that is", never "comms", "config", "repo", "admin",
  "e.g." or "i.e.". Names in code, commands and file paths stay as they are.
- **Exam terms stay.** The product's own names are what the reader must learn
  (for example a resource kind, a field, a command). Keep them, but explain
  each one in plain words, with an everyday analogy, the first time it appears
  in a file. Spell out acronyms on first use, with a short plain meaning.
- **Analogies come from space, and the reader is an astronaut.** When a term
  needs an everyday picture, use space: spaceships, planets, solar systems,
  space stations, mission control, signals, docking, star charts, airlocks,
  even the Death Star. Talk to the reader as an astronaut (for example "your
  first mission", "astronaut, check your flight log"), but not in every
  sentence. Requests are **signals** that ships send to each other. Use one
  analogy per hard idea, keep it short, and keep it the same everywhere (if
  the repository has an analogy glossary, use it). The analogy helps the reader; it
  never replaces the real term, and it never changes code or output.
- **Show one real example before the rule.** Start with a concrete case the
  reader can run, then give the general rule.
- **Say which part does the work.** Readers often mix up the parts of a system
  that sit close together. Whenever something happens, say which component
  did it.
- **Never change code to fit the style.** Commands, configuration files, field
  names, resource names, log lines and command output stay exactly as they
  are. They were run and checked on a real system. Never make up command
  output. If you shorten it, say that you did.
- **Prose only.** The grade-level and sentence rules apply to explanations.
  They do not apply to code blocks, tables of field names or reference lists
  (those may stay short and dense).
- **Keep the page furniture the same.** Hands-on steps are normal page
  content, not boxes: a short `###` subsection (for example "See it in your
  playground") with one sentence saying what to do, the command, the real
  output, and one or two sentences saying what it shows. A `> [!TIP]` box is
  only for a real tip: advice the reader can reuse beyond this one step (a
  habit, a shortcut, how to spot a problem, an exam habit). Everything else
  is a normal sentence: notes about the current step ("if the log line is
  old, run it again"), background facts, optional extra steps, and plain
  information. Never a command snippet, never two in a row, and most pages
  need zero or one tip. Each part ends with a
  `## Common pitfalls` `> [!WARNING]` block for that part only. Use a Mermaid
  diagram for a flow, an order or a state change, keep it under about 12
  boxes, and follow it with one sentence that says what it shows.
- **Labs come right after the part they practise.** Do not collect all
  graded labs at the end of a module. In `astrona.yaml`, put each lab (its
  `question.md` reading and the `lab` entry) right after the reading part it
  tests. If a part teaches a gradeable skill and no lab covers it, create a
  new lab. That part then ends with a `## Your mission: <lab title>` section:
  one sentence on what the reader can now do, one on what the mission asks,
  then pause the playground (`astrona stop <playground name>`), the
  `astrona run` and `astrona submit` commands, and finally
  `astrona destroy <lab name>` plus `astrona start <playground name>`. The
  wrap-up lists the missions and ends with cleaning up the playground
  (`astrona list`, `astrona destroy <playground name>`).
- **Renew the playground before hands-on work.** Every reading part that
  runs commands has `<!-- astrona:playground:renew -->` exactly once, on its
  own line, right before the first hands-on step (the first "Save this as"
  or the first command block), so the playground timer is reset before the
  learner needs the playground. Not on landing pages (they carry
  `<!-- astrona:playground -->`), wrap-up pages or pages without commands.
- **Mermaid without HTML.** The platform renders Mermaid with HTML labels
  switched off, so `<br/>` and any other HTML tag break the drawing. Rules:
  - One line per box, no `<br/>`, no HTML. Keep the box to the thing's name
    (`"kyverno-admission-controller"`, `"API server"`, `"ClusterPolicy"`).
  - Put the logic on the arrows: `A -->|"AdmissionReview"| K`,
    `H -->|"extraArgs"| D`, `R -->|"aggregates"| P`. Keep edge labels short.
  - Quote every label. Prefer `flowchart TB`; use `LR` only for a short chain.
  - Sequence diagrams: short participant aliases (`participant A as api-server`)
    and short message text.
  - Anything longer (cluster names, full hostnames) goes in the sentence under
    the diagram.
- **No links to outside sources.** Course pages, labs and playground docs do
  not link to or point at outside websites (the one exception is the
  `resources` field of a lab entry in `astrona.yaml`) (official docs, GitHub, blogs,
  RFCs), and they have no "Reference" or "Official docs" lists. Everything the
  reader needs is explained on the page itself. Not affected: addresses the
  reader actually uses in a command or browser (`http://127.0.0.1:9080`,
  `curl https://httpbin.org`), and the Mission Briefing's contributors and
  "report a mistake" links.
- **Configuration goes to a file first.** Whenever the reader should apply
  YAML (course parts, playground docs, labs), use three separate steps:
  1. "Save this as `policyexception-smoke-test.yaml`:" followed by a plain
     ` ```yaml ` block with only the YAML. No `cat > file <<'EOF'`, no
     `kubectl apply -f - <<EOF`, no shell around it.
  2. "Apply it:" followed by a ` ```sh ` block with only
     `kubectl apply -f policyexception-smoke-test.yaml`.
  3. "Then check the result:" followed by the check commands, if any.
  The file name says the kind and the object. If a value must come from the
  reader's cluster (an IP address), use a placeholder like `<PARTNER>` in the
  YAML and say how to get the value (`echo $PARTNER`); never put shell
  variables inside YAML. Apply an object the first time its YAML appears; do
  not show it once "to read" and paste it again later. Never tell the reader
  to apply something from the playground's `examples/` folder: they start the
  playground with `astrona run`, so that folder is not on their machine.
- **Helpers have readable names.** Shell helper functions and variables use
  names that say what they do (`check_route`, `count_versions`,
  `$SERVICE_URL`), never single letters.

## About this repo (ATS008 only)

Everything above is general and can be copied to other course repositories. This
section is only true for this one.

### What the student is trying to learn

- **The goal:** pass the **Installation, Configuration, and Upgrades** domain
  of the **Kyverno Certified Associate (KCA)** exam. It is 18% of the exam
  (the `weight` in `astrona.yaml`).
- **What the exam really tests:** running Kyverno itself, not writing
  policies. The student must install it with Helm into its own namespace,
  read and change its custom resource definitions, set flags on each of its
  four controllers, extend its permissions safely, size it for high
  availability and upgrade it without breaking live policies. So the student
  must *do* things, and every explanation should lead to a command they can
  run and a way to check that it worked (`helm get values -a`, the live
  Deployment `args`, `kubectl auth can-i`, `helm history`).
- **The six exam topics:** Helm installation and configuration, Kyverno's
  custom resource definitions, controller configuration with flags, Kyverno
  role-based access control (RBAC), high availability, and upgrading. The
  course has one section per topic, in that order.
- **The sections:**

  | Section | Title | Exam topic |
  | --- | --- | --- |
  | 010 | Helm-based Installation and Configuration | Installation with Helm |
  | 020 | Kyverno Custom Resource Definitions (CRDs) | Custom resource definitions |
  | 030 | Controller Configuration with Flags | Controller flags |
  | 040 | Configuring Kyverno RBAC, Roles, and Permissions | RBAC and permissions |
  | 050 | High Availability Installations | High availability |
  | 060 | Upgrading Kyverno | Upgrades |

  A section quiz (`sections/section-0N0/quiz.md`) and a final domain quiz
  (`sections/final-domain-quiz.md`) are listed in `astrona.yaml` too.
- **The version:** most labs install the **latest `kyverno/kyverno` Helm
  chart** with no version pin (when this file was written that was chart
  `3.9.1` with Kyverno `v1.19.1`). The two section 020 labs install
  **Kyverno v1.13.2** from the release `install.yaml` manifest instead. Do
  not teach fields, defaults or API versions from other versions without
  saying so, and check chart keys against `helm show values kyverno/kyverno`.
- **The main sources:** the Kyverno installation pages
  (<https://kyverno.io/docs/installation/>), the chart's `values.yaml`
  (`helm show values kyverno/kyverno`) and the Helm command reference. Check
  every page against them.

### Space analogy glossary

Use these pictures for these terms, in every course page, lab and
playground. Keep them consistent so the astronaut builds one picture of the
universe. Most pages written before these rules have no space analogies yet;
add them when you rework a page, using this table.

**The universe**

| Term | Space picture |
| --- | --- |
| The learner | An astronaut (a cadet on their first missions) |
| Kubernetes cluster | A solar system |
| Namespace | A planet in that solar system |
| Pod | A spaceship |
| Deployment / replicas | A squadron order: "keep this many identical ships flying" |
| Node | A space dock where ships are parked |
| Kubernetes API server | Mission control's registry desk: every launch request goes through it |
| Request to create or change an object | A launch request filed at the registry desk |
| Service account | The ship's registration papers |
| `kind` cluster on your laptop | A training solar system in the simulator |
| Lab | A mission |

**Installing with Helm**

| Term | Space picture |
| --- | --- |
| Helm | The shipyard crane that assembles a whole station from a kit |
| Helm chart | A station kit: every part, plus the assembly plan |
| Helm repository | The kit depot you order kits from |
| Release | One assembled station, with its own name and flight record |
| Revision | One entry in that flight record (each install or upgrade adds one) |
| `values.yaml` / `--set` | The order form for the kit / a single change written on the form |
| `helm get values -a` | Reading back the complete order form, including every default |
| Manifest install (`install.yaml`) | Building the station by hand from a parts list: no flight record |
| Dedicated `kyverno` namespace | Kyverno's own planet, where nothing else is parked |

**Kyverno and its controllers**

| Term | Space picture |
| --- | --- |
| Kyverno | The solar system's inspection authority: it checks launch requests against rule books |
| Admission webhook | The registry desk's call line to the inspectors before it accepts a request |
| Admission controller | The inspectors at the launch gate: they answer every call, and any of them can |
| Background controller | The construction crew that builds and repairs things after launch (`generate`, mutate existing) |
| Reports controller | The records office: it patrols existing ships and files inspection reports |
| Cleanup controller | The salvage crew that removes old ships on a schedule |
| Controller flag (`--genWorkers=5`) | A dial on one crew's control panel |
| `extraArgs` | Extra dial settings written on the order form for one crew |
| Kyverno ConfigMap (`config.*`) | The station notice board: crews read changes live, no restart |
| `excludeGroups` | The list of crews the inspectors wave through without checking |

**Custom resource definitions**

| Term | Space picture |
| --- | --- |
| Custom resource definition (CRD) | A new kind of form that mission control's registry learns to accept |
| `ClusterPolicy` / `Policy` | A rule book for the whole solar system / for one planet |
| `PolicyException` | A signed waiver that lets one named ship skip one rule |
| `--exceptionNamespace` | The one planet allowed to issue waivers |
| `CleanupPolicy` / `ClusterCleanupPolicy` | A salvage schedule for one planet / for the whole solar system |
| `GlobalContextEntry` | A shared star chart kept at the station, so inspectors read one copy instead of each asking |
| `PolicyReport` / `ClusterPolicyReport` | The inspection report card for a planet / for the solar system |
| Intermediate reports (`EphemeralReport`, older `AdmissionReport`, `BackgroundScanReport`) | Inspectors' scratch notes, merged into the report card and thrown away |
| `UpdateRequest` | A work order waiting in the construction crew's queue |

**Permissions (RBAC) and high availability**

| Term | Space picture |
| --- | --- |
| RBAC (role-based access control) | The security clearance system |
| `ClusterRole` / `ClusterRoleBinding` | A clearance card listing allowed actions / handing that card to a crew's papers |
| ClusterRole aggregation and the `rbac.kyverno.io/aggregate-to-...` label | A master card that automatically includes every card with a certain stamp |
| Built-in `view` role | A visitor pass: look at everything, touch nothing |
| `kubectl auth can-i --as=...` | Asking the clearance office "may this crew do that?" |
| Leader election | Only the captain gives orders; the other ships stand by |
| `Lease` and `holderIdentity` | The captain's baton, and the name of the ship holding it |
| Anti-affinity / topology spread | Do not park every ship of a squadron at the same dock |
| Upgrade / rollback | Refitting the station in orbit / returning to an earlier refit |
| Release notes | The bulletin that comes with each new station model |

### The sample apps and starting state the labs use

There is no shared sample app and no playground in this course. Each graded
lab starts a fresh `kind` cluster and seeds only what its task needs. Use
these names exactly as the bootstrap scripts create them:

| Lab | Starting state (from `bootstrap/`) |
| --- | --- |
| 010 module lab, 010 and 050 capstones, 050 module lab | `kyverno` Helm repository added; Kyverno **not** installed |
| 020 module lab | Kyverno v1.13.2 from `install.yaml`; namespace `checkout`; `ClusterPolicy` `require-owner-label` (rule `check-owner-label`, Pods need an `owner` label) |
| 020 capstone | As above, plus `ClusterPolicy` `require-cost-center-label` (rule `check-cost-center-label`, Deployments in `checkout`) |
| 030 module lab and capstone | Kyverno installed with Helm at default values |
| 040 module lab | Kyverno installed with Helm; `ClusterPolicy` `generate-default-quota` (generates `ResourceQuota` `default-quota` in each new namespace) |
| 040 capstone | Kyverno installed with Helm; `ClusterPolicy` `generate-network-policy` (generates `NetworkPolicy` `default-deny`) |
| 060 module lab | Kyverno installed with Helm at default values (revision 1) |
| 060 capstone | As above, plus namespace `finance` and `ClusterPolicy` `require-cost-center-label` |

Learner-created names the graders check include `smoke-test`, `no-owner-pod`,
`batch-worker`, `unlabeled-worker`, `nightly-batch`, `carts`,
`checkout-svc`, `orders`, `billing-svc`, `kyverno-generate-resourcequota`,
`kyverno-generate-networkpolicy` and `~/policy-backup.yaml`. Keep them.

### Environment facts the text must respect

- **Helm release and namespace:** always release `kyverno` in namespace
  `kyverno`. The four Deployments (and their service accounts) are
  `kyverno-admission-controller`, `kyverno-background-controller`,
  `kyverno-reports-controller` and `kyverno-cleanup-controller`.
- **`extraArgs` is a map in the current chart, not a list.** Write
  `backgroundController.extraArgs.genWorkers=5` or, in a values file,
  `extraArgs:` with `genWorkers: 5` under it. The chart turns each key into
  `--key=value`. A list (`extraArgs[0]=--genWorkers=5`) renders as
  `--0=--genWorkers=5` (checked with `helm template` on chart 3.9.1). The
  admission controller's map sits one level deeper:
  `admissionController.container.extraArgs`.
- **The chart already sets some flags.** For example the admission
  controller gets `--enablePolicyException=false` and the cleanup controller
  `--ttlReconciliationInterval=1m` by default; a flag from `extraArgs` comes
  later in the list and wins.
- **`config.excludeGroups` defaults to `system:nodes` only** in chart 3.9.1
  and in the v1.13.2 manifest. Older material listed two defaults; the
  010 capstone grader still checks for both entries, so the task asks for both.
- **`PolicyException` on v1.13.2 is `kyverno.io/v2`** (CRD
  `policyexceptions.kyverno.io`). The `policies.kyverno.io` group does not
  exist on v1.13.2; on newer versions it holds a different exception kind
  for the new policy types.
- **Intermediate reports:** v1.13.2 and the current chart have
  `ephemeralreports` and `clusterephemeralreports`
  (`reports.kyverno.io/v1`), not `admissionreports` or
  `backgroundscanreports`.
- **`cleanupController.enabled: false`** removes the cleanup Deployment
  completely (checked with `helm template`).
- **No recorded command output exists yet** in this repository. Do not write
  output blocks from memory; describe in one sentence what to look for until
  someone records real output from a lab run.
- **Outbound internet:** the bootstrap scripts reach
  `https://kyverno.github.io/kyverno/` and the GitHub release
  `install.yaml`. These addresses are used in commands, so they are allowed
  on the page.

### Where things are in this repo

| What | Where |
| --- | --- |
| Course outline the platform reads: every reading page and lab, in order. Never list `solution.md` here | `astrona.yaml` |
| Overview, sections table, how to run things | `README.md` |
| Section overview and its module | `sections/section-0N0/README.md` |
| Module reading: landing page, deep-dive parts, wrap-up | `sections/section-0N0/module-01/course.md`, `course-0N-*.md` |
| Graded lab: task, walkthrough, setup, grader | `.../labs/lab-01/` (`question.md`, `solution.md`, `bootstrap/`, `validation/`) |
| One graded integration lab per section | `sections/section-0N0/capstone/labs/lab-01/` |
| Section quiz and final domain quiz | `sections/section-0N0/quiz.md`, `sections/final-domain-quiz.md` |

There is no `sections/intro/` Mission Briefing and no playground yet. Labs
have no `solution/apply.sh` yet either.

A lab folder holds:

| Path | Purpose |
| --- | --- |
| `config.yaml` | Lab definition; `metadata.docs` has `question: "question.md"` and `solution: "solution.md"` |
| `README.md` | Short intro with `estimated_duration` front matter and the run, submit and destroy commands |
| `question.md` | The exam-style task. Starts with `# Question` and `Solve this question on: \`terminal\`` |
| `solution.md` | Step-by-step walkthrough |
| `bootstrap/01-*.sh`, `02-*.sh` | Helm repository, Kyverno install and seeded policies, never the graded objects |
| `validation/validate-completed.sh` | Grading: reads the live cluster (Helm release, Deployment `args`, objects, admission results) |

### Lab metadata in `astrona.yaml`

`astrona.yaml` has one entry per section under `modules:` (`module-010`,
`module-020` and so on, plus `module-070` for the final quiz). Each
section's `content` lists, in order: the section `README.md`, then the
module's landing page, its parts, and right after the part a lab tests, a
`Question` reading (`labs/lab-01/question.md`) followed by the `type: lab`
entry; the module's wrap-up page comes next, then the section quiz. The
section capstone closes the section.

Every `type: lab` entry (module labs and capstones) carries these fields, in
this order:

```yaml
      - type: reading
        title: Question
        path: sections/section-010/module-01/labs/lab-01/question.md
      - type: lab
        title: "Helm Install with Custom Values Lab"
        path: sections/section-010/module-01/labs/lab-01
        difficulty: beginner
        estimated_duration: 15m
        topic: helm-install
        task_kind: build
        tags: [helm, helm-set, dedicated-namespace, admission-controller, replicas, resource-requests]
        learning_goals:
          - Install Kyverno with Helm into its own kyverno namespace
          - Set the admission controller's replicas and resource requests with --set
        resources:
          - name: "Kyverno installation methods"
            url: https://kyverno.io/docs/installation/methods/
```

- `difficulty`: `beginner`, `intermediate` or `advanced`.
- `estimated_duration`: realistic time to solve it, for example `15m`, `30m`, `45m`.
- `topic`: exactly one of `helm-install`, `crds`, `controller-flags`,
  `rbac`, `high-availability`, `upgrades`.
- `task_kind`: exactly one of `build` (write the configuration from
  scratch), `troubleshooting` (find and fix what is broken) or `migration`
  (move a working setup to a new version or layout, for example a Helm
  upgrade). The platform filters labs by it, so it is a field of its own,
  never a tag.
- `tags`: 4 to 8 ids, only from the tag list below. Add a new tag to the list
  first if nothing fits.
- `learning_goals`: 2 or 3 plain sentences, each starting with a verb, saying
  what the learner proves in this lab.
- `resources`: 1 to 4 documentation pages, each with a `name` and a `url`
  that loads. This is the **only** place outside links are allowed: the
  platform shows them as optional further reading next to the lab.

**Tag list** (lower case, hyphens, never synonyms):

- Helm: `helm`, `helm-repo`, `helm-set`, `values-file`, `helm-upgrade`,
  `reuse-values`, `helm-history`, `helm-get-values`, `list-values`
- Install layout: `dedicated-namespace`, `crds-install`, `manifest-install`,
  `controller-toggle`, `exclude-groups`, `configmap`
- Controllers: `admission-controller`, `background-controller`,
  `reports-controller`, `cleanup-controller`, `extra-args`, `controller-flags`
- Custom resources: `crds`, `clusterpolicy`, `policyexception`,
  `cleanup-policy`, `global-context`, `policy-reports`, `update-request`
- Permissions: `rbac`, `service-accounts`, `clusterrole-aggregation`,
  `generate-rules`, `auth-can-i`
- Availability and sizing: `replicas`, `resource-requests`,
  `leader-election`, `leases`
- Upgrades: `upgrades`, `policy-backup`, `post-upgrade-checks`
- Tools: `kubectl-patch`, `rollout-status`, `jsonpath`

### Running things

```bash
# Lab or capstone (graded against the live cluster)
astrona run --git ssh://git@github.com/astrona-io/ATS008.git -c sections/section-010/module-01/labs/lab-01
astrona submit -c sections/section-010/module-01/labs/lab-01
astrona destroy ats-008-lab-001   # takes metadata.name from config.yaml, not the path

# Authors: run a local, uncommitted copy
astrona run -c sections/section-010/module-01/labs/lab-01
astrona validate -c sections/section-010/module-01/labs/lab-01
```

Lab names (`metadata.name`) are numbered in course order:

| Lab | Name |
| --- | --- |
| 010 module lab / capstone | `ats-008-lab-001` / `ats-008-lab-002` |
| 020 module lab / capstone | `ats-008-lab-003` / `ats-008-lab-004` |
| 030 module lab / capstone | `ats-008-lab-005` / `ats-008-lab-006` |
| 040 module lab / capstone | `ats-008-lab-007` / `ats-008-lab-008` |
| 050 module lab / capstone | `ats-008-lab-009` / `ats-008-lab-010` |
| 060 module lab / capstone | `ats-008-lab-011` / `ats-008-lab-012` |

Keep those names. A new lab takes the next free number. Lab bootstrap
scripts do not pin a kube context: astrona sets `KUBECONFIG` for the lab.
Every lab must pass `astrona validate`. `astrona validate` currently flags
the `metadata.docs` keys `question` and `solution`; leave them as they are
until the maintainer decides the standard.

A lab's `question.md` and `solution.md` must match what its `validation/`
scripts actually check.

Test clusters on the maintainer's machine: one at a time. Podman has 10 GiB
and also runs the platform stack; parallel clusters run it out of memory.
Never touch clusters you did not create.

### Where to find trusted sources

Check facts here before writing them down. Prefer these over memory.

- **Installing and customizing:**
  <https://kyverno.io/docs/installation/methods/>,
  <https://kyverno.io/docs/installation/customization/> (including role-based
  access control and the `rbac.kyverno.io/aggregate-to-...` labels)
- **Chart values:** `helm show values kyverno/kyverno`, and the chart README
  <https://github.com/kyverno/kyverno/blob/main/charts/kyverno/README.md>
- **Custom resources:** <https://kyverno.io/docs/exceptions/>,
  <https://kyverno.io/docs/policy-types/cleanup-policy/>,
  <https://kyverno.io/docs/policy-reports/>
- **High availability and scaling:**
  <https://kyverno.io/docs/high-availability/>,
  <https://kyverno.io/docs/installation/scaling/>
- **Upgrading:** <https://kyverno.io/docs/installation/upgrading/>
- **Helm commands:** <https://helm.sh/docs/helm/helm_install/>,
  <https://helm.sh/docs/helm/helm_upgrade/>,
  <https://helm.sh/docs/helm/helm_get_values/>,
  <https://helm.sh/docs/helm/helm_history/>
- **Kubernetes:** <https://kubernetes.io/docs/reference/access-authn-authz/rbac/>
  (aggregated ClusterRoles), <https://kubernetes.io/docs/concepts/architecture/leases/>
- **The exam itself:** the KCA page on the Linux Foundation / CNCF training
  site lists the official curriculum. The domain weight (18%) and topic list
  above come from this repository's README and `astrona.yaml` and have not
  been re-checked against it.

### Skills to use here

The `astrona-course-*` skills do most authoring jobs in this repository: planning
(`domain-plan`), creating the tree (`domain-scaffold`), building modules
(`domain-build`), deep-dive parts (`deep-dive`), labs and playgrounds (`lab`),
lab docs (`lab-docs`), challenges (`create-challenge`), quizzes
(`generate-assessment`) and fact-checking (`review-accuracy`).
