#!/bin/bash
# Stafræn Heilsa — Claude Skill Installer (macOS / Linux)
# Run this once to install, re-run to update

BASE="https://raw.githubusercontent.com/Stafraen-Heilsa/claude-plugin/main/skills"

install_skill() {
    local name="$1"; shift
    local dir="$HOME/.claude/skills/$name"
    local raw="$BASE/$name"

    echo "Installing $name..."
    mkdir -p "$dir/references" "$dir/scripts"

    curl -fsSL "$raw/SKILL.md" -o "$dir/SKILL.md" && echo "  + SKILL.md"

    for f in "$@"; do
        mkdir -p "$dir/$(dirname "$f")"
        if curl -fsSL "$raw/$f" -o "$dir/$f"; then
            echo "  + $f"
        else
            echo "  ! $f failed" >&2
        fi
    done

    # scripts must be executable
    chmod +x "$dir"/scripts/*.sh 2>/dev/null
    echo ""
}

install_skill nytt-verkefni \
    references/honnunarhandbok.md \
    references/throdunarhandbok.md \
    references/throdunarhandbok-vidaukar.md

install_skill github-verkefni \
    references/taxonomy.md \
    references/manifest-schema.md \
    references/handbook-rules.md \
    references/queries.md \
    references/conventions.md \
    scripts/sync-labels.sh

echo "Done! Skills installed to: $HOME/.claude/skills/"
echo "Restart Claude Code to activate."
echo ""
echo "github-verkefni also needs:"
echo "  - gh authenticated with: repo, read:org, project"
echo "  - access to the private Stafraen-Heilsa/sh-portfolio-docs repo"
echo "  - python with pyyaml (pip install pyyaml)"
