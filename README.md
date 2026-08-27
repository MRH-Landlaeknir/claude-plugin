# Stafræn Heilsa — Claude Skills

Project workflow skills for Stafræn Heilsa / Embætti landlæknis.

## Install

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Stafraen-Heilsa/claude-plugin/main/install.ps1 | iex
```

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/Stafraen-Heilsa/claude-plugin/main/install.sh | bash
```

Restart Claude Code after installing. Re-run the same command to update.

---

## The two skills

They split along one line: **Notion holds the process record, GitHub holds the execution.**

```
nytt-verkefni  (Notion)                    github-verkefni  (GitHub)
─────────────────────────                  ──────────────────────────
1 Skilgreining  ┐
2 Greining      ├─ process record,
3 Hugmyndir     ┘  checklists, stakeholders
      └── produces "Listi af notendasögum" ──►  epics + issues
                                           4 Hönnun og þróun
                                             capture / status / triage / evidence
```

**The rule: if a human has to _do_ it, it is a GitHub issue — never a Notion checkbox.**

The link is one-way, which is what stops the two systems drifting.

---

## `nytt-verkefni` — project hub in Notion

Three modes:

1. **Project Kickoff** (`/kickofftool`) — intake a new project aligned with the
   Hönnunarhandbók 4-phase UCD process. Reads dropped documents first, extracts known facts,
   asks only what is missing, then creates the full Notion project structure.
2. **Design Sprint** — visual brainstorming for UI/UX decisions. Generates interactive mockups
   via `frontend-design`, saves decisions to Hugmyndir.
3. **Artifact Push** — pushes session output to the right Notion sub-page. Offered at the end
   of productive sessions.

Every project gets the same 8-page Notion structure: Overview, Skilgreining, Greining,
Hugmyndir, Hönnun og þróun, Tékklistar, Backlog, Notes.

---

## `github-verkefni` — work management in GitHub

Turns a plain message into correctly tagged issues in the right repos on the right Project v2
board, asking at most one clarifying question.

| Mode | For |
|---|---|
| **Capture** *(default)* | "We need to…", "X is broken", standup notes → tagged issues |
| **Status** | "What's blocked and on whom", "what ships in the next release" |
| **Plan** | A spec or story list → an epic with cross-repo sub-issues |
| **Triage** | Untagged or legacy issues get the taxonomy |
| **Evidence** | Þróunarhandbók §4.5 traceability for a milestone |
| **Onboard** | Add a project to a board. Once per project. |

Four carriers, nothing stored twice:

**Issue Types = what it is. Labels = facts. Fields = state. Sub-issues = structure.**

Labels are `project:` (routing) · `who:` (who must do it) · `needs:` (what it waits on —
**any `needs:` label means blocked**) · `risk:` (healthcare and compliance) · `area:`
(per project).

`who:` and `needs:` are deliberately separate axes. An issue can be `who:<supplier>` +
`needs:infra-setup`: the supplier owns the work, an infra team has to unblock it. That pairing
is the point.

Repo roles are **derived** from the Þróunarhandbók §1.4 suffix table rather than invented, and
milestones follow the §1.6 release-train naming, so branch, PR, milestone and release all
agree — which is what makes §4.5 traceability machine-followable.

### Additional requirements

| What | Why |
|---|---|
| `gh` with `repo`, `read:org`, `project` scopes | Everything |
| Access to `Stafraen-Heilsa/sh-portfolio-docs` (private) | Project manifests live there |
| `python` with `pyyaml` | Manifest parsing in the scripts |

Project data — manifests, deployment topology, vendor assignments, cleanup findings — lives in
the **private** `sh-portfolio-docs`, never in this repo. This repo holds only generic,
manifest-driven mechanics.

---

## Requirements

| What you need | Required for |
|---|---|
| **Notion MCP** connected in Claude settings | `nytt-verkefni`, all modes |
| **`gh` CLI** authenticated | `github-verkefni`, all modes |
| **`superpowers`** plugin | Design sprint only |
| **`frontend-design`** plugin | Design sprint only |

If `superpowers` or `frontend-design` are missing, the design sprint falls back to text-based
brainstorming. Everything else is unaffected.

---

## Handbooks

Based on **Hönnunarhandbók Stafrænar Heilsu**, Edition 2, April 2026, and **Þróunarhandbók
Stafrænar Heilsu**, Edition 4, April 2026. Requirements in both are binding in tenders,
contracts and projects — the skills enforce them rather than inventing a parallel process.
