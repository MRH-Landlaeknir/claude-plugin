# The handbook rules this skill enforces

This skill does not invent a process. It enforces rules that are already binding in tenders,
contracts and projects. When a choice looks arbitrary, it is usually a handbook requirement.

## Þróunarhandbók (Edition 4, April 2026)

### §1.2 — Repository organisation
Mono-repo is **not permitted**. One repository per independently released unit. `main` is the
only long-lived branch. No direct changes to `main` — everything goes through a Pull Request
with code review. Repositories are created by the Directorate, not by suppliers.

*Consequence:* work is inherently multi-repo, which is why epics use cross-repo sub-issues.

### §1.3 — Repository naming
Lowercase and hyphens. **Same prefix for every repository of one solution.** No temporary
names (`-new`, `-old`, `-temp`), no version numbers in names.

*Consequence:* project membership is largely derivable from the prefix. A repo whose prefix
disagrees with its project is a signal it belongs somewhere else.

### §1.4 — Repository suffixes
The suffix table in `manifest-schema.md`. **This is the role vocabulary** — do not invent one.

### §1.5 — How external parties work
Suppliers work in **forks** and have no write access to `main`. Deliveries arrive as Pull
Requests. Suppliers must delete all forks when the work ends.

*Consequence:* a vendor often **cannot be assigned** an issue in the upstream repo. `who:*`
labels are the durable ownership fact; GitHub assignees are best-effort. Never treat an empty
assignee as unowned.

### §1.6 — Branch naming
| Type | Pattern | Environment |
|---|---|---|
| Feature | `feature/*` | Not released |
| Hotfix | `hotfix/YYYY.MM.DD-DESCRIPTION` | Pre-production, Production |
| QA | `qa/YYYY.MM.DD-rcNN` | Pre-production only |
| Release | `release/YYYY.MM.DD[-hotfixN]` | Pre-production, Production |

**The PR title must equal the branch name.** `-rc` versions are never permitted in Production.

*Consequence:* milestones use the same naming, so branch → PR → milestone → release all agree.
That agreement is what makes §4.5 traceability machine-followable.

### §3.4 — Quality gates
Clean-as-you-code: the PR is compared against the current codebase, so suppliers are not
charged with pre-existing problems elsewhere. **Critical findings block approval.** Unit tests
must meet coverage thresholds. **Warnings are treated as errors** — because unhandled warnings
accumulate into technical debt that is hard to repay once the context is lost.

*Consequence:* this is the Definition of Done on every task. Do not write a custom one.

### §4.5 — Traceability
Traceability must be assured between branches, Pull Requests, test results, approvals, and QA
and production releases. Achieved through consistent naming, test results in the PR, approvals
recorded on the PR, build history in the PR, and QA/Release name agreement.

*Consequence:* this is the specification for Evidence mode. Traceability documentation is part
of the acceptance process, so assembling it is a real deliverable, not reporting garnish.

### §12.3 — Documentation in repositories
Every README must contain, at minimum: what the solution does and **its role in the larger
context**, technical description, overview of how the parts work together, external
dependencies, documented deviations from the handbook, developer setup, database setup.

*Consequence:* `role_description` in the manifest is the same content the handbook already
requires. Generating and checking that README section is compliance work, not overhead.

### §12.4 — Sensitive data
Encryption keys, certificates, credentials, `client_id`, API keys and network configuration
(IP whitelisting, VPN) must **never** appear in documentation or code.

*Consequence:* never put these in an issue body, a manifest or a report. When a blocker
concerns credentials, describe the blocker, not the credential.

---

## Hönnunarhandbók (Edition 2, April 2026)

### The four verkþættir
Never begin a later phase before the prior one is complete.

| | Phase | Purpose |
|---|---|---|
| 1 | **Skilgreining** (Define) | Purpose, goals, measurable effects, user groups, stakeholders |
| 2 | **Greining** (Discover) | Needs analysis — processes, roles, tasks, requirements |
| 3 | **Hugmyndir** (Innovate) | Concepts, rough interface structure, user story list |
| 4 | **Hönnun og þróun** (Develop) | Full design and development, story by story |

Phases 1–3 are `nytt-verkefni`'s territory in Notion. This skill owns phase 4. The handoff is
the **user story list** that Hugmyndir produces.

### §6.1 — Approval before coding
User story descriptions must be **approved by the ábyrgðaraðili and key users before
programming starts**. Fully designed screens must exist as design documents at the start of
development.

*Consequence:* the `needs:approval` label, and why capture refuses work with no acceptance
criteria.

### §6.4 — User story contents
Every user story needs all of: short title; description; *"As a [user role], I want [some
goal] so that [reason/benefit]"*; context of use; rules or criteria; sketch; user roles;
scenario; desired outcome; exceptions; other important information.

### Story handover
Before programming starts, the story is presented to developers and testers by whoever wrote
it, so questions can be answered and the description updated. A story nobody has walked
through is not ready.

### Priority
User stories are prioritised by value and by how they build the process the solution supports.
The stories that deliver most user value and underpin the process rank highest.
