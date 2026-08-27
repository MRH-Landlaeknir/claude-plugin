# Stafræn Heilsa — Claude Skill Installer (Windows)
# Run this once to install, re-run to update

$BASE = "https://raw.githubusercontent.com/Stafraen-Heilsa/claude-plugin/main/skills"

function Install-Skill {
    param([string]$Name, [string[]]$Files)

    $dir = "$env:USERPROFILE\.claude\skills\$Name"
    $raw = "$BASE/$Name"

    Write-Host "Installing $Name..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$dir\references" | Out-Null
    New-Item -ItemType Directory -Force -Path "$dir\scripts" | Out-Null

    Invoke-WebRequest -Uri "$raw/SKILL.md" -OutFile "$dir\SKILL.md"
    Write-Host "  + SKILL.md" -ForegroundColor Green

    foreach ($f in $Files) {
        $target = Join-Path $dir ($f -replace '/', '\')
        $parent = Split-Path $target -Parent
        if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
        try {
            Invoke-WebRequest -Uri "$raw/$f" -OutFile $target
            Write-Host "  + $f" -ForegroundColor Green
        } catch {
            Write-Host "  ! $f failed" -ForegroundColor Red
        }
    }
    Write-Host ""
}

Install-Skill -Name "nytt-verkefni" -Files @(
    "references/honnunarhandbok.md",
    "references/throdunarhandbok.md",
    "references/throdunarhandbok-vidaukar.md"
)

Install-Skill -Name "github-verkefni" -Files @(
    "references/taxonomy.md",
    "references/manifest-schema.md",
    "references/handbook-rules.md",
    "references/queries.md",
    "references/conventions.md",
    "scripts/sync-labels.sh"
)

Write-Host "Done! Skills installed to: $env:USERPROFILE\.claude\skills\" -ForegroundColor Green
Write-Host "Restart Claude Code to activate." -ForegroundColor Yellow
Write-Host ""
Write-Host "github-verkefni also needs:" -ForegroundColor Yellow
Write-Host "  - gh authenticated with: repo, read:org, project"
Write-Host "  - access to the private Stafraen-Heilsa/sh-portfolio-docs repo"
Write-Host "  - python with pyyaml (pip install pyyaml)"
