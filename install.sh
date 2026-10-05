#!/usr/bin/env bash
# Install the Dynatrace AI Skills Package.
#
# This package builds on the official Dynatrace skills
# (https://github.com/Dynatrace/dynatrace-for-ai) and does NOT work without them.
# The installer refuses to proceed until those skills are present.
#
# Usage:
#   ./install.sh                    # install all skills
#   ./install.sh dt-rcf dt-slo-burn # install only the named skills
#   ./install.sh --check            # only verify the dynatrace-for-ai prerequisite
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="$(cat "$REPO_DIR/VERSION" 2>/dev/null || echo unknown)"
TARGET="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"

# dynatrace-for-ai skills this package reads at runtime.
REQUIRED=(
  dt-dql-essentials
  dt-obs-tracing
  dt-obs-services
  dt-obs-logs
  dt-obs-problems
  dt-obs-frontends
  dt-obs-kubernetes
  dt-obs-aws
  dt-obs-azure
  dt-obs-gcp
  dt-obs-predictive-analytics
  dt-app-dashboards
  dt-app-notebooks
)

# Every place dynatrace-for-ai can land: manual copy, skills.sh (npx skills add),
# or the Claude Code plugin cache.
search_roots() {
  printf '%s\n' "$TARGET" "$HOME/.claude/skills" "$HOME/.agents/skills"
  local d
  for d in "${CLAUDE_CONFIG_DIR:-}" "$HOME/.claude"; do
    [[ -n "$d" && -d "$d/plugins" ]] && find "$d/plugins" -maxdepth 6 -type d -name skills 2>/dev/null
  done
}

skill_present() {
  local root
  while IFS= read -r root; do
    [[ -f "$root/$1/SKILL.md" ]] && return 0
  done < <(search_roots | sort -u)
  return 1
}

check_prereqs() {
  local missing=() s
  for s in "${REQUIRED[@]}"; do
    skill_present "$s" || missing+=("$s")
  done
  if (( ${#missing[@]} )); then
    cat >&2 <<EOF

✋ Prerequisite missing: Dynatrace for AI skills
   These skills were not found: ${missing[*]}

   This package depends on https://github.com/Dynatrace/dynatrace-for-ai and
   will not work without it. Install it FIRST, using any one of:

     npx skills add dynatrace/dynatrace-for-ai
     claude plugin install dynatrace@claude-plugins-official
     git clone https://github.com/Dynatrace/dynatrace-for-ai.git && \\
       cp -r dynatrace-for-ai/skills/* "$TARGET/"

   Then re-run: ./install.sh

EOF
    return 1
  fi
  echo "✓ dynatrace-for-ai skills found (${#REQUIRED[@]}/${#REQUIRED[@]})"
}

echo "Dynatrace AI Skills Package v$VERSION"
check_prereqs || exit 1
[[ "${1:-}" == "--check" ]] && exit 0

if (( $# )); then
  selected=("$@")
else
  selected=()
  for d in "$REPO_DIR"/skills/*/; do selected+=("$(basename "$d")"); done
fi

mkdir -p "$TARGET"
for s in "${selected[@]}"; do
  [[ "$s" == */* || "$s" == .* ]] && { echo "✗ invalid skill name: $s" >&2; exit 1; }
  [[ -d "$REPO_DIR/skills/$s" ]] || { echo "✗ unknown skill: $s" >&2; exit 1; }
  [[ -d "$TARGET/$s" ]] && echo "  overwriting $s" || echo "  installing  $s"
  rm -rf "${TARGET:?}/$s"
  cp -R "$REPO_DIR/skills/$s" "$TARGET/$s"
done
echo "✓ Installed ${#selected[@]} skill(s) to $TARGET — restart Claude Code or run /skills to see them."
