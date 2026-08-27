# Taxonomy

The complete vocabulary, and the rule for which carrier holds which fact.

**Issue Types = what it is. Labels = facts. Fields = state. Sub-issues = structure.**

If you find yourself recording the same fact in two carriers, one of them is wrong.

---

## Issue Types (native, org-level)

Set on the issue itself. No per-repo sync — they exist org-wide by definition, and are
filterable with `is:issue type:Bug`.

| Type | Use for |
|---|---|
| `Epic` | Cross-repo parent. Lives in the project's `hub_repo`; children are sub-issues elsewhere. |
| `Feature` | New capability. A user story is a Feature. |
| `Bug` | Something behaves wrongly. |
| `Task` | Work with a definite outcome that is neither feature nor defect. |
| `Chore` | Maintenance, upgrades, cleanup. |
| `Spike` | Time-boxed investigation. The deliverable is an answer, not code. |
| `Security` | Security-relevant work. |
| `Compliance` | Regulatory, audit or conformance work. |
| `Docs` | Documentation. |

`Security` and `Compliance` are separate types rather than labels so that one org-wide query
answers "what regulated work is open" — which matters in healthcare.

---

## Labels

Namespaced `family:value`. Applied by `scripts/sync-labels.sh` from the manifest.

### `project:*` — routing

`project:<manifest id>`

Load-bearing, and always present. A shared repo belongs to several projects at once, so the
repo alone cannot determine which board an issue goes to.

It also means the whole system works **without Projects v2** — useful if the board is
unavailable or a token lacks `project` scope:

```bash
gh search issues --owner Stafraen-Heilsa --label "project:<id>" --label "needs:infra-setup" --state open
```

### `who:*` — who must do it

Mirrors the org's **team slugs**, so it can drive assignment and supplier-scoped views.

Two values are universal:

- `who:internal` — the Directorate's own technical team
- `who:external` — parties outside the org entirely: partner countries, other institutions,
  national services

Everything else is a team slug. **Discover them, don't hardcode them** — teams change:

```bash
gh api orgs/Stafraen-Heilsa/teams --jq '.[]|"\(.slug) — \(.description // "")"'
```

Each project's manifest names the values it uses, via its repos' `who` and its `who_extra`
list (usually the infra teams, which any project can need).

**This matters more than the GitHub assignee.** Þróunarhandbók §1.5 has vendors working in
forks without write access, so they often cannot be assigned at all. The label is the durable
ownership fact; the assignee is best-effort.

Only the values a project actually uses are synced. Others are created on demand at capture
time rather than cluttering every repo.

### `needs:*` — what it is waiting on

**Any `needs:*` label means the item is blocked.** There is deliberately no separate `blocked`
label, so there is exactly one source of truth. Board automation sets Status to ⛔ Blocked
from the presence of any of these.

| Label | Waiting on |
|---|---|
| `needs:infra-setup` | Infrastructure — cluster, network, ingress, DNS |
| `needs:access` | Credentials, permissions, an account |
| `needs:vendor` | An external supplier |
| `needs:decision` | A decision from a responsible owner |
| `needs:spec` | A specification or acceptance criteria |
| `needs:upstream` | An upstream system or partner |
| `needs:security-review` | Security review or assessment |
| `needs:legal` | Legal, DPA or procurement |
| `needs:test-env` | A test environment or test data |
| `needs:data` | Data — migration, seeding, a dataset |
| `needs:approval` | Approval by ábyrgðaraðili or key users (Hönnunarhandbók §6.1) |

### `who:` and `needs:` are independent axes

This is the distinction the whole blocker-reporting design rests on:

> **`who:` is who owns it. `needs:` is what it is stuck on.**

An issue can be `who:<supplier>` + `needs:infra-setup` — the supplier owns the work, but an
infra team has to unblock it. Collapsing these into one field loses exactly the information a blockers digest
exists to surface. Always report them as two facts.

### `risk:*` — healthcare and compliance flags

`risk:personal-data` · `risk:clinical-safety` · `risk:security` · `risk:audit-evidence` ·
`risk:breaking-change`

`risk:audit-evidence` marks work that *produces* evidence needed for audit or conformance,
which is what makes evidence collection automatable rather than narrative.

### `area:*` — project-specific

Declared per project in the manifest's `areas:` list. Keeps the core taxonomy fixed while
letting each project carry its own domain vocabulary.

Areas are synced project-wide, not per repo. The manifest's per-repo `areas` are **inference
hints for capture**, not restrictions.

Where a project already invented its own area vocabulary, absorb it rather than replacing it.

---

## Project v2 fields

H = human-maintained, B = bot-maintained.

| Field | Values | |
|---|---|---|
| Status | 🆕 New · 📋 Backlog · 🔖 Ready · 🏗 In progress · ⛔ Blocked · 👀 In review · 🔍 Verifying · ✅ Done | H; B forces ⛔ Blocked on any `needs:*` |
| Priority | 🌋 Urgent · 🏔 High · 🏕 Medium · 🏝 Low | H |
| Phase | Skilgreining · Greining · Hugmyndir · Hönnun og þróun · Rekstur | H — mirrors Notion |
| Test event / Target release | per manifest `milestone_source` | H |
| Team | mirrors `who:*` | B — grouping needs a field; labels can only filter |
| Environment reached | none · test · stage · ppt · prod | B, from the Argo/GitOps repos |
| Evidence | URL | B |
| Last verified | date | B |
| Notion | URL | B, from manifest |

The emoji Status and Priority vocabularies were already in use on existing org boards. They
were adopted rather than replaced with something like `P0–P3`: familiar beats novel, and
matching what a team already built is cheaper than retraining them.

**No Effort/Size field by default.** Add it only where a team genuinely estimates. Dead
metadata is worse than none.

A field marked B is only reliable if the automation can actually see the source. A service
deployed outside the standard Argo `deployments/` pattern will be silently reported as
deployed nowhere — such exceptions must be declared in the manifest.

---

## Milestones

Release trains, named identically across repos so a cross-repo query works.

Per Þróunarhandbók §1.6: `release/YYYY.MM.DD`, `qa/YYYY.MM.DD-rcNN`. Milestones follow that
naming, so branch, PR, milestone and release all agree — which is what §4.5 traceability
requires.

Projects on a different cadence declare `milestone_source` in the manifest and name
milestones after their own events instead.
