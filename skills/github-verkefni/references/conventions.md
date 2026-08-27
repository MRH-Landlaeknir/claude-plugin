# Issue conventions

## Definition of Done

Every issue inherits this from Þróunarhandbók §3.4 and §4.5. Do not write a custom one.

- PR passes the quality gates: no Critical findings, coverage thresholds met, warnings
  treated as errors
- PR title equals the branch name (§1.6)
- Test results are in the PR (§4.5)
- Approval recorded on the PR (§4.5)
- Evidence linked where the work produces any

## Task

The default shape. Keep it short — length is not rigour.

```markdown
## Hvað
One paragraph. What needs to happen.

## Af hverju
Why it matters. Skip when self-evident.

## Viðtökuskilyrði
- [ ] Verifiable outcome
- [ ] Verifiable outcome

## Samhengi
Links, error messages, prior discussion, related issues.
```

**Acceptance criteria must be verifiable.** "Works properly" is not a criterion. If the work
has no verifiable outcome, ask before creating — §6.4 requires rules or criteria and §6.1
requires approval before coding, so a task without them fails the handbook.

## User story (Hönnunarhandbók §6.4)

All ten elements are required. Use this for `Feature` issues that represent user-facing work.

```markdown
## Notendasaga
**As a** [user role] **I want** [goal] **so that** [benefit]

## Lýsing
Plain language a user would recognise. Not implementation.

## Hluti lausnar
Which part of the solution this belongs to.

## Reglur og skilyrði
- [ ] Rule or criterion
- [ ] Rule or criterion

## Hlutverk
Which user roles are involved.

## Sviðsmynd
The scenario in which this story is used.

## Vænt niðurstaða
What the user should end up with.

## Undantekningar
Edge cases, error paths, what happens when it goes wrong.

## Skissur
Link to Figma or equivalent.

## Annað
Anything else that matters.
```

§6.1: the description must be approved by the ábyrgðaraðili and key users **before programming
starts**. Until then the story carries `needs:approval` and cannot be 🔖 Ready.

Before programming, whoever wrote the story presents it to developers and testers so questions
can be answered and the description updated. A story nobody has walked through is not ready.

## Epic

Lives in the project's `hub_repo`. Children are sub-issues in the repos that do the work —
sub-issues are cross-repo and roll up progress automatically.

```markdown
## Markmið
What this epic delivers, and for whom.

## Umfang
In scope / out of scope. Being explicit about what is out prevents drift.

## Ferill
Which repos are involved and what each contributes.

## Skilgreining á lokið
What must be true for the epic to close. Usually more than "all children closed" —
verification, evidence, a deployment reached.
```

## Bug

```markdown
## Hvað gerist
Observed behaviour.

## Hvað ætti að gerast
Expected behaviour.

## Endurgerð
1. Step
2. Step

## Umhverfi
Environment, version, deployed image tag.

## Áhrif
Who is affected and how badly. Drives Priority.
```

Include the deployed image tag. A frozen or mismatched version explains a surprising number
of bugs, and it is cheap to record.

## Titles

- Say what changes, not what is wrong with the world: *"Fix NRO evidence generation — bad
  `*.WSE` endpoint"*, not *"NRO problem"*
- No prefixes for what a label or type already carries — no `[BUG]`, no `[EU]`
- Icelandic or English, whichever the team uses. Be consistent within a repo.
- Long enough to be recognisable in a list of forty

## Recording inference

When capture inferred something rather than being told — most often `who:` — say so in the
body:

```markdown
> **who: needs confirming** — assigned to <team> on the basis that they own networking.
> Reassign if another team owns this.
```

A wrong owner that announces itself gets fixed. A wrong owner that looks authoritative does not.

## Migrating an existing document

When a markdown register becomes issues:

- Preserve the original answer. Create resolved items **and close them** with the answer as
  the closing comment — the history is worth more than a clean issue list.
- Note the source in each body so the trail back is obvious.
- **Reconcile duplicates.** Hand-maintained registers drift into recording the same thing
  twice under different headings. Merge them and say so in the body.
- Leave the source document in place as a generated view of the open items rather than
  deleting it.
