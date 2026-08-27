---
name: github-verkefni
description: >
  Stafræn Heilsa GitHub work management — create, tag, organise and report on work across
  the org's repositories. Invoke whenever someone describes work that needs doing ("we need
  to…", "X is broken", "remind me to…", "here's what came out of standup"), asks where a
  project stands ("what's blocked", "what's left for the release", "status of X"), or wants
  a backlog cleaned up or evidence assembled. Also invoke when onboarding a new project onto
  a board. Turns a plain message into correctly tagged issues in the right repos on the right
  Project v2 board, asking at most one clarifying question. Enforces Þróunarhandbók (v4) and
  Hönnunarhandbók (v2) rules rather than inventing a parallel process. Companion to
  nytt-verkefni, which owns the Notion process record for verkþættir 1–3.
---

# GitHub verkefnastjórnun

GitHub owns **execution**. Notion, via the `nytt-verkefni` skill, owns the **Hönnunarhandbók
process record** for verkþættir 1–3.

**The rule: if a human has to _do_ it, it is a GitHub issue — never a Notion checkbox.**

The link is one-way. Manifests carry `notion_url`, boards have a Notion field, epics link
their story. Notion never mirrors task state — that is what stops the two drifting.

---

## Before anything: load the manifests

All project knowledge lives in the **private** repo `Stafraen-Heilsa/sh-portfolio-docs`.
Never guess a project's repos, owners or board number — read them.

```bash
gh repo clone Stafraen-Heilsa/sh-portfolio-docs ~/.cache/sh-portfolio-docs 2>/dev/null \
  || git -C ~/.cache/sh-portfolio-docs pull -q
ls ~/.cache/sh-portfolio-docs/projects/
```

If the clone fails the user lacks access — say so and stop. Do not improvise a manifest.

**Never write project data into this (public) repo.** Manifests, environment topology, vendor
assignments and cleanup findings belong in `sh-portfolio-docs`. This repo holds only generic,
manifest-driven mechanics.

---

## The four carriers

Nothing is stored twice.

| Concern | Carrier |
|---|---|
| What kind of work it is | Native org **Issue Type** |
| Facts about the work | **Labels** — `project:` `who:` `needs:` `risk:` `area:` |
| Structure across repos | Native **sub-issues** |
| Planning state | **Project v2 fields** |

**Issue Types = what it is. Labels = facts. Fields = state. Sub-issues = structure.**

Full vocabulary and when to use each: `references/taxonomy.md`.
Manifest shape and the §1.4 role table: `references/manifest-schema.md`.
The binding handbook rules this skill enforces: `references/handbook-rules.md`.

---

## Mode 1 — Capture *(default)*

Any message describing work to be done. This is the mode you are almost always in.

**Principle: infer everything the manifest can tell you. Ask only where confidence is low.
Ask once, batched.**

With 130 repos and a manifest, most messages need zero or one question. Interrogating the
user slot by slot is worse than the status quo they are trying to escape.

### The four required slots

| Slot | How to fill it |
|---|---|
| `project:` | Match keywords and repo names against the manifests. The §1.3 shared-prefix rule usually settles it. **Ask only if the repo belongs to several projects.** |
| repo | Named directly, or inferred from the §1.4 suffix table — "the API needs…" plus a project resolves to that project's `-api` repo. Ask with candidates when more than one is plausible. |
| `who:` | Default to the manifest's `who` for that repo, cross-checked against real team access (`gh api repos/{o}/{r}/teams`). Ask only when several teams have push or the message implies otherwise. |
| what | Title, body, acceptance criteria from the message. **Push back only here.** |

Derive silently, never ask: Issue Type, `needs:*`, `risk:*`, `area:*`.
Ask once per session, not per issue: which milestone or test event.

### Detect multiple items

A message naming a dependency is two issues, not one. Watch for "X needs to happen first",
"blocked by", "once Y is done", "and also".

Link them with sub-issues (parent/child) or a "blocked by" reference in the body, and put the
`needs:*` label on the **blocked** item — not the blocker.

### Show a draft, then create

For one item, state what you inferred in a sentence and create it.
For several, show **one table** — title, repo, type, who, needs, area — and let the user
correct it in plain language ("3 and 5 are Apró, 4 is really in portal-api") before anything
is created.

### The one thing to refuse

If the work has **no verifiable outcome**, ask for acceptance criteria. Hönnunarhandbók §6.4
requires rules or criteria and §6.1 requires approval before coding — a task without them
fails the handbook, not merely good taste. This is the only deliberate friction.

### Creating

```bash
gh issue create --repo Stafraen-Heilsa/<repo> --title "<title>" --body "<body>" \
  --label "project:<id>" --label "who:<team>" --label "area:<area>"
gh project item-add <board> --owner Stafraen-Heilsa --url <issue-url> --format json --jq '.id'
gh project item-edit --id <item> --project-id <PID> --field-id <F> --single-select-option-id <O>
```

Set Status to **⛔ Blocked** whenever any `needs:*` label is present. Field and option IDs are
per board — query them, never hardcode. See `references/queries.md`.

---

## Mode 2 — Status

Answer from labels first; they work without a board and across every project.

```bash
# What is blocked in a project, and on whom
gh search issues --owner Stafraen-Heilsa --label "project:<id>" --state open \
  --json number,title,labels,repository \
  --jq '.[]|select([.labels[].name]|any(startswith("needs:")))'

# Everything anywhere waiting on infrastructure
gh search issues --owner Stafraen-Heilsa --label "needs:infra-setup" --state open
```

Report **who owns it** and **what it waits on** as separate facts — that pairing is the point
of the two label families. An item can be `who:<supplier>` + `needs:infra-setup`: the supplier
owns it, an infra team must unblock it.

---

## Mode 3 — Plan

A spec, a Notion story list, or a `nytt-verkefni` handoff becomes an `Epic` in the project's
`hub_repo`, with children as sub-issues in the repos that do the work.

User stories use the Hönnunarhandbók §6.4 template in `references/conventions.md` — all ten
required elements, including *"As a [role], I want [goal] so that [benefit]"*.

---

## Mode 4 — Triage

Untagged or legacy issues. Apply the taxonomy, route to the board, set fields.

When a repo has pre-existing labels, **remap, never wipe**. `gh label delete` destroys the
label's assignments on every issue carrying it; `gh label edit --name` preserves them. Agree
retirements with the team that created them — do not silently tidy someone's vocabulary away.

---

## Mode 5 — Evidence

Assemble Þróunarhandbók §4.5 traceability for a milestone: branches → PRs → test results →
approvals → QA/PROD releases. §1.6 requires the PR title to equal the branch name, which is
what makes the chain machine-followable.

Write the result to the Evidence and Last verified fields.

---

## Mode 6 — Onboard

Adding a project. Runs once per project.

1. Write `projects/<id>.yml` in `sh-portfolio-docs`. **Verify every claim** against the org
   and the Argo/GitOps repos — deployment reality routinely contradicts assumption. Do not
   record a repo as dead, live or owned without checking.
2. Create the org Project v2 board and its fields.
3. `scripts/sync-labels.sh projects/<id>.yml` then `--apply`.
4. Record the board number in the manifest.

Match conventions that already exist in the org rather than imposing new ones — check how
other boards name their Status and Priority options first.

---

## Guardrails

- **Verify, don't assume.** Deployment state, repo liveness and ownership are all checkable.
  Check them. Say plainly when something contradicts what the user believed.
- **Flag inferences.** If `who:` was a guess, say so in the issue body so it can be corrected.
- **Never delete labels.** Removal is a separate deliberate act.
- **Scripts dry-run first.** Show the diff before writing.
- **Never write project data to this public repo.**
- Labels, Issue Types and field names in English for tooling; issue content in Icelandic or
  English as the team prefers.
