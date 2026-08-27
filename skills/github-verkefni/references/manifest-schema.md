# Manifest schema

One YAML per project in `Stafraen-Heilsa/sh-portfolio-docs/projects/<id>.yml`.
The source of truth for which repos belong to a project and what role each plays.

```yaml
id: <slug>                       # matches the project:<id> label
name: <English name>
name_is: <Icelandic name>
status: active                   # active | paused | maintenance | sunset
phase: honnun-og-throun          # skilgreining | greining | hugmyndir | honnun-og-throun | rekstur
owner_team: <github team slug>
hub_repo: Stafraen-Heilsa/<repo> # where Epics live — usually the project's -docs repo
notion_url: <url|null>
board: <project v2 number|null>
architecture_systems: [SYS-###]  # cross-link to sh-architecture-docs

milestone_source: release-trains # release-trains | test-events | <other>
milestones: [...]

areas: [...]                     # becomes the area:* label family for this project

repos:
  - name: <repo>
    role: <suffix>               # derived from the name; see the table below
    role_override: true          # only when the name breaks §1.4
    role_description: >
      What this repo does and its role in the larger context.
    criticality: critical        # critical | high | normal | low
    lifecycle: active            # active | superseded | deprecated
    who: <who: value>
    areas: [...]                 # inference hints for capture, not restrictions
    depends_on_external: [...]
    deployment:
      environments: [test, ppt, prod]
      argo_tracked: true         # false if deployed outside the standard pattern
      note: <anything unusual>

depends_on:                      # surfaced here, owned elsewhere
  - name: <repo or party>
    kind: shared-service | hekla-core-service | external-party | external-tooling
    description: >
    surfaced_as: blocking-dependency

cleanup:                         # findings that become issues at onboard time
  - repo: <repo>
    finding: >
    action: <verb>
    who: <who: value>
```

## `role` — derived, not invented

From the Þróunarhandbók §1.4 suffix table. Read the repo name; only override when the name
breaks the convention.

| Suffix | Meaning |
|---|---|
| `-service` | Backend service behind the firewall |
| `-api` | Backend service reachable from the internet |
| `-ui-web` | Web interface |
| `-ai-service` / `-ai-api` | AI service, behind / outside the firewall |
| `-database`, `-database-APEX`, `-database-pipeline` | Database code |
| `-infra` | Infrastructure code (Kubernetes, Argo CD) |
| `-package-nuget` / `-package-npm` / `-package-maven` | Published packages |
| `-jobs` | Scheduled or background processing |
| `-docs`, `-docs-android`, `-docs-ios` | Documentation |
| `-ui-android` / `-ui-ios` | Native apps |
| `-cli` | Console application |
| `-automation-actions` / `-automation-pa` | CI/CD or Power Automate automation |
| `-dashboard-powerbi` / `-dashboard-web` | Dashboards |
| `-config` | Configuration files only |
| `-fhir` | FHIR standardisation and implementations |

Compound suffixes go general → specific (`-database-fhir`, not `-fhir-database`).

A repo with no matching suffix needs `role_override: true` and is **handbook drift** — record
it in `cleanup` rather than quietly accommodating it.

## `role_description` is not busywork

Þróunarhandbók §12.3 already requires every README to state the repo's *"hlutverk í stærra
samhengi"*. The manifest is the machine-readable source; the README section is a rendering
of it. Keeping them aligned is a compliance check, not an extra chore.

## Verify before you write

Scoping a project means checking, not asking-and-recording. Every one of these is verifiable
in under a minute, and each has caught a wrong assumption in practice:

```bash
# What is actually deployed, per environment
gh api repos/Stafraen-Heilsa/el-{test,ppt,prod}-k8s-apps-argo-infra/git/trees/HEAD?recursive=1 \
  --jq '.tree[]|select(.type=="tree")|.path' | grep -E '^deployments/[^/]+$'

# Real activity, not "last updated" (which a rename or tag will bump)
gh api "repos/Stafraen-Heilsa/<repo>/commits?since=<date>" --jq 'length'

# Who genuinely has push access
gh api repos/Stafraen-Heilsa/<repo>/teams --jq '.[]|"\(.slug)(\(.permission))"'

# Pinned image versions — a stale tag reveals a frozen service
gh api repos/Stafraen-Heilsa/el-prod-k8s-apps-argo-infra/contents/deployments/<repo>/values.yaml \
  --jq '.content' | base64 -d
```

Things that have actually turned up this way: a service believed dead running in production;
a service believed live never deployed anywhere; production running a fraction of the cron
jobs pre-production runs; a repo deployed outside the pattern automation reads.

State plainly when a check contradicts what someone believed. That is the value.
