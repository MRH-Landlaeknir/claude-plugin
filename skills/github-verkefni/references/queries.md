# Query cookbook

Everything here is verified working against `gh` with `repo`, `read:org` and `project` scopes.

## Gotchas that will waste your time

- The GraphQL field for one board is **`projectV2(number: N)`** — singular. `projectsV2` is a
  connection and does not accept `number`; you get a confusing "field doesn't exist" error.
- `search/issues` **includes pull requests** on the REST `/issues` endpoint. Use
  `search/issues?q=...+is:issue` and read `total_count`. Grouping a 100-item page gives you a
  sample, not a count — for per-repo totals, query per repo.
- Creating org **Issue Types** needs `admin:org` and fails with a bare `404` first. Do it in
  Org Settings → Planning → Issue types instead of asking for that scope.
- In Actions, the default `GITHUB_TOKEN` **cannot write org Projects v2** at all. A GitHub App
  token or PAT is required regardless of workflow permissions.

## Status

```bash
# Blocked in a project, and on whom
gh search issues --owner Stafraen-Heilsa --label "project:<id>" --state open \
  --json number,title,labels,repository --jq '.[]
  | select([.labels[].name]|any(startswith("needs:")))
  | "\(.repository.name)#\(.number)  \(.title)
     waiting on: \([.labels[].name]|map(select(startswith("needs:")))|join(", "))
     owned by : \([.labels[].name]|map(select(startswith("who:")))|join(", "))"'

# Anything org-wide waiting on infrastructure
gh search issues --owner Stafraen-Heilsa --label "needs:infra-setup" --state open

# Everything one team owns, across all projects
gh search issues --owner Stafraen-Heilsa --label "who:<team>" --state open

# True issue count for one repo (excludes PRs)
gh api "search/issues?q=repo:Stafraen-Heilsa/<repo>+is:issue&per_page=1" --jq '.total_count'
```

## Boards

```bash
# All boards in the org
gh api graphql -f query='query{organization(login:"Stafraen-Heilsa"){
  projectsV2(first:30){totalCount nodes{number title closed updatedAt items{totalCount}}}}}'

# One board's fields and every single-select option id
gh api graphql -f query='query{organization(login:"Stafraen-Heilsa"){projectV2(number:11){
  id fields(first:30){nodes{
    ... on ProjectV2Field{id name}
    ... on ProjectV2SingleSelectField{id name options{id name}}}}}}}'

# Board contents with field values
gh api graphql -f query='query{organization(login:"Stafraen-Heilsa"){projectV2(number:11){
  items(first:100){totalCount nodes{
    content{... on Issue{number title state}}
    fieldValues(first:20){nodes{... on ProjectV2ItemFieldSingleSelectValue{
      name field{... on ProjectV2FieldCommon{name}}}}}}}}}}'
```

## Creating a board

```bash
ORG_ID=$(gh api graphql -f query='query{organization(login:"Stafraen-Heilsa"){id}}' --jq '.data.organization.id')

gh api graphql -f query="mutation{createProjectV2(input:{ownerId:\"$ORG_ID\",title:\"<title>\"}){
  projectV2{id number url}}}"

# Replace the default Status options
gh api graphql -f query="mutation{updateProjectV2Field(input:{fieldId:\"<status-field-id>\",
  singleSelectOptions:[{name:\"📋 Backlog\",color:GRAY,description:\"...\"}]}){
  projectV2Field{... on ProjectV2SingleSelectField{options{name}}}}}"

# Add a field
gh api graphql -f query="mutation{createProjectV2Field(input:{projectId:\"<pid>\",
  dataType:SINGLE_SELECT,name:\"Priority\",
  singleSelectOptions:[{name:\"🌋 Urgent\",color:RED,description:\"...\"}]}){
  projectV2Field{... on ProjectV2FieldCommon{name}}}}"
```

`description` is required on every single-select option. Valid colours: `GRAY` `BLUE` `GREEN`
`YELLOW` `ORANGE` `RED` `PINK` `PURPLE`.

## Adding and editing items

```bash
ITEM=$(gh project item-add <board> --owner Stafraen-Heilsa --url <issue-url> --format json --jq '.id')
gh project item-edit --id "$ITEM" --project-id <pid> --field-id <fid> --single-select-option-id <oid>

# Find an existing item by issue number
gh api graphql -f query='query{organization(login:"Stafraen-Heilsa"){projectV2(number:11){
  items(first:100){nodes{id content{... on Issue{number}}}}}}}' \
  --jq '.data.organization.projectV2.items.nodes[]|select(.content.number==<n>)|.id'
```

## Deployment reality

```bash
# What is deployed per environment
for e in test ppt prod; do
  gh api "repos/Stafraen-Heilsa/el-$e-k8s-apps-argo-infra/git/trees/HEAD?recursive=1" \
    --jq '.tree[]|select(.type=="tree")|.path' | grep -E '^deployments/[^/]+$'
done

# Pinned image version — a stale tag means a frozen service
gh api repos/Stafraen-Heilsa/el-prod-k8s-apps-argo-infra/contents/deployments/<repo>/values.yaml \
  --jq '.content' | base64 -d
```

Not every service follows the `deployments/` pattern. Check the manifest's
`deployment.argo_tracked` before concluding a service is undeployed.

## Sub-issues

```bash
gh api repos/Stafraen-Heilsa/<repo>/issues/<n>/sub_issues                    # list
gh api -X POST repos/Stafraen-Heilsa/<repo>/issues/<n>/sub_issues -F sub_issue_id=<id>
```

`sub_issue_id` is the issue's **database id**, not its number:
`gh api repos/{o}/{r}/issues/{n} --jq '.id'`. Works across repositories.

## Scripting notes

- `((counter++))` returns 1 when the counter is 0 and **kills the script under `set -e`**.
  Use `counter=$((counter+1))`.
- Python's `print()` emits CRLF on Windows. A stray `\r` in a repo name silently corrupts the
  API URL. Use `sys.stdout.reconfigure(newline="\n")`.
- Never put `|| true` on a fetch whose emptiness changes behaviour — it turns a hard failure
  into a plausible-looking wrong answer.
- Make anything that creates issues **idempotent by title**, so a partial run can be re-run
  safely. Partial runs happen.
