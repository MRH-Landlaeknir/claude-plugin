#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# sync-labels.sh — apply the github-verkefni label taxonomy to a project's repos
#
#   ./sync-labels.sh <manifest.yml>            # dry run (default)
#   ./sync-labels.sh <manifest.yml> --apply    # actually write
#
# Idempotent. Creates missing labels and corrects colour/description drift on
# existing ones. NEVER deletes a label — deleting destroys its assignments on
# every issue that carries it. Removal is a separate, deliberate operation.
#
# Label families (see references/taxonomy.md):
#   project:*  routing — which project board this issue belongs to
#   who:*      who must do the work
#   needs:*    what it is waiting on. ANY needs:* label means blocked.
#   risk:*     healthcare and compliance flags
#   area:*     project-specific domain areas, declared in the manifest
#
# Work type is NOT a label — it is a native org-level Issue Type.
#
# Windows note: python's print() emits CRLF on stdout, and a stray CR silently
# corrupts any value interpolated into a URL. The manifest is therefore read
# through a single python call that reconfigures stdout to LF.
# ---------------------------------------------------------------------------
set -euo pipefail

MANIFEST="${1:?usage: sync-labels.sh <manifest.yml> [--apply]}"
APPLY=false
[[ "${2:-}" == "--apply" ]] && APPLY=true

ORG=Stafraen-Heilsa

C_PROJECT=0052CC   # blue
C_WHO=8250DF       # purple
C_NEEDS=D93F0B     # orange-red
C_RISK=B60205      # dark red
C_AREA=0E8A16      # green

# One python call emits "id <x>", "repo <x>", "area <x>", "who <x>" lines.
# Member repos only — dependencies belong to other projects and must not have
# this project's taxonomy pushed onto them.
read_manifest() {
  python - "$MANIFEST" <<'PY'
import sys, yaml
sys.stdout.reconfigure(newline="\n")
d = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
print("id", d["id"])
for r in d["repos"]:
    print("repo", r["name"])
for a in d.get("areas", []):
    print("area", a)
# who: values in play for this project — the repos' owners plus anything the
# manifest names in who_extra (typically the infra teams, which are reachable
# from any project). Other teams get a label created on demand at capture time
# rather than cluttering every repo up front.
who = {r["who"] for r in d["repos"] if r.get("who")}
who |= set(d.get("who_extra", []))
who |= {"internal", "external"}
for w in sorted(who):
    print("who", w)
PY
}

MANIFEST_DATA=$(read_manifest)
field() { awk -v k="$1" '$1==k{$1="";sub(/^ /,"");print}' <<<"$MANIFEST_DATA"; }

PROJECT_ID=$(field id)
mapfile -t REPOS < <(field repo)
mapfile -t AREAS < <(field area)
mapfile -t WHOS  < <(field who)

[[ -n "$PROJECT_ID" && ${#REPOS[@]} -gt 0 ]] || {
  echo "manifest did not yield a project id and repos" >&2; exit 1; }

# needs: and risk: are universal — identical in every project so org-wide
# queries work across project boundaries.
NEEDS=(
  "infra-setup:Waiting on infrastructure work — cluster, network, ingress, DNS"
  "access:Waiting on credentials, permissions or an account"
  "vendor:Waiting on an external supplier"
  "decision:Waiting on a decision from a responsible owner"
  "spec:Waiting on a specification or acceptance criteria"
  "upstream:Waiting on an upstream system or partner country"
  "security-review:Waiting on a security review or assessment"
  "legal:Waiting on legal, DPA or procurement"
  "test-env:Waiting on a test environment or test data"
  "data:Waiting on data — migration, seeding or a dataset"
  "approval:Waiting on approval by abyrgdaradili or key users (Honnunarhandbok 6.1)"
)
RISKS=(
  "personal-data:Touches personal or health data — DPIA may apply"
  "clinical-safety:Carries clinical safety implications — needs sign-off"
  "security:Security-relevant change"
  "audit-evidence:Produces evidence required for audit or conformance"
  "breaking-change:Breaks an interface or contract for a consumer"
)

declare -a NAMES COLORS DESCS
add() { NAMES+=("$1"); COLORS+=("$2"); DESCS+=("$3"); }

add "project:$PROJECT_ID" "$C_PROJECT" "Belongs to the $PROJECT_ID project — routes to its board"
for w in "${WHOS[@]}";  do add "who:$w"          "$C_WHO"   "Work owned by $w"; done
for n in "${NEEDS[@]}"; do add "needs:${n%%:*}"  "$C_NEEDS" "${n#*:}"; done
for r in "${RISKS[@]}"; do add "risk:${r%%:*}"   "$C_RISK"  "${r#*:}"; done
for a in "${AREAS[@]}"; do add "area:$a"         "$C_AREA"  "Domain area: $a"; done

echo "manifest : $MANIFEST"
echo "project  : $PROJECT_ID"
echo "repos    : ${#REPOS[@]}"
echo "labels   : ${#NAMES[@]} per repo"
$APPLY || echo "MODE     : DRY RUN — pass --apply to write"
echo

created=0; updated=0; unchanged=0; failed=0
for repo in "${REPOS[@]}"; do
  echo "-- $repo"
  # Do not swallow this. A failed fetch makes every label look missing, and the
  # dry run then reports a full create set that is pure noise.
  if ! existing=$(gh api "repos/$ORG/$repo/labels?per_page=100" \
        --jq '.[]|"\(.name)\t\(.color)\t\(.description // "")"' 2>&1); then
    echo "   ! cannot read labels — skipping"
    echo "     ${existing:0:160}"
    failed=$((failed+1))
    continue
  fi
  for i in "${!NAMES[@]}"; do
    name="${NAMES[$i]}"; color="${COLORS[$i]}"; desc="${DESCS[$i]}"
    line=$(awk -F'\t' -v n="$name" '$1==n' <<<"$existing")
    if [[ -z "$line" ]]; then
      echo "   + $name"
      if $APPLY; then
        gh label create "$name" --repo "$ORG/$repo" --color "$color" --description "$desc" >/dev/null
      fi
      created=$((created+1))
    else
      cur_color=$(cut -f2 <<<"$line"); cur_desc=$(cut -f3 <<<"$line")
      if [[ "${cur_color,,}" != "${color,,}" || "$cur_desc" != "$desc" ]]; then
        echo "   ~ $name (drift)"
        if $APPLY; then
          gh label edit "$name" --repo "$ORG/$repo" --color "$color" --description "$desc" >/dev/null
        fi
        updated=$((updated+1))
      else
        unchanged=$((unchanged+1))
      fi
    fi
  done
done

echo
echo "created=$created  corrected=$updated  unchanged=$unchanged  failed=$failed"
$APPLY || echo "(dry run — nothing written)"
[[ $failed -eq 0 ]]
