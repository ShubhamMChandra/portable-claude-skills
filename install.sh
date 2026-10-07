#!/usr/bin/env bash
# Install this repo's skills and agents, plus the pinned third-party skills they
# reference, into the user-level Claude Code directories.
#
#   ~/.claude/skills/<name>/   this repo's skills + selected Matt Pocock skills
#   ~/.claude/agents/          this repo's agents
#   ~/.claude/commands/        selected slash commands from alirezarezvani/claude-skills
#   ~/.claude-skills/          alirezarezvani/claude-skills reference library (read on demand)
#
# Additive and idempotent: it replaces only the entries it installs and never
# deletes anything else under ~/.claude. Safe to run on every session start.
#
# Usage:
#   bash install.sh                 # everything
#   PCS_SKIP_LIBRARY=1 bash install.sh   # skip the ~/.claude-skills library and its commands
set -euo pipefail

# Third-party sources are pinned so a new upstream commit never reaches your
# sessions unreviewed. Bump a SHA deliberately, then re-run install.sh.
MATT_REPO="https://github.com/mattpocock/skills"
MATT_SHA="6fd947921b935b7e1e69293a200400f0fdd5c15f"
MATT_SKILLS=(
  productivity/grilling productivity/grill-me productivity/writing-for-agents
  engineering/codebase-design engineering/domain-modeling engineering/diagnosing-bugs
  engineering/tdd engineering/triage engineering/to-spec engineering/to-tickets
  engineering/improve-codebase-architecture engineering/setup-matt-pocock-skills
  misc/setup-pre-commit misc/migrate-to-shoehorn
)

LIBRARY_REPO="https://github.com/alirezarezvani/claude-skills"
LIBRARY_SHA="19392f7a08264ed00486a251f5b2098321771f94"
LIBRARY_TEAMS=(
  engineering-team engineering product-team marketing-skill c-level-advisor
  project-management business-growth finance ra-qm-team markdown-html
)
# `tdd` is left out on purpose: Matt Pocock's `tdd` skill owns that name.
LIBRARY_COMMANDS=(
  a11y-audit changelog code-to-prd competitive-matrix financial-health focused-fix
  google-workspace okr persona pipeline plugin-audit prd project-health retro rice
  saas-health seo-auditor sprint-health sprint-plan tech-debt user-story
)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
LIBRARY_DIR="${HOME}/.claude-skills"

log() { printf '[portable-claude-skills] %s\n' "$*"; }

# Replace one installed directory without touching its siblings.
install_dir() {
  local source="$1" target="$2"
  rm -rf "$target"
  cp -R "$source" "$target"
}

# Shallow-fetch a single pinned commit, optionally limited to some top-level dirs.
fetch_pinned() {
  local url="$1" sha="$2" dest="$3"
  shift 3
  rm -rf "$dest"
  git init -q "$dest"
  git -C "$dest" remote add origin "$url"
  git -C "$dest" fetch -q --depth 1 --filter=blob:none origin "$sha"
  if (($# > 0)); then
    git -C "$dest" sparse-checkout set --cone "$@"
  fi
  git -C "$dest" checkout -q FETCH_HEAD
}

mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/agents" "$CLAUDE_DIR/commands"

log "installing this repo's skills and agents"
for skill in "$REPO_DIR"/skills/*/; do
  install_dir "$skill" "$CLAUDE_DIR/skills/$(basename "$skill")"
done
cp "$REPO_DIR"/agents/*.md "$CLAUDE_DIR/agents/"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

log "installing Matt Pocock skills @ ${MATT_SHA:0:7}"
fetch_pinned "$MATT_REPO" "$MATT_SHA" "$work/matt" skills
for skill in "${MATT_SKILLS[@]}"; do
  install_dir "$work/matt/skills/$skill" "$CLAUDE_DIR/skills/$(basename "$skill")"
  cp "$work/matt/LICENSE" "$CLAUDE_DIR/skills/$(basename "$skill")/LICENSE"
done

if [[ "${PCS_SKIP_LIBRARY:-0}" == "1" ]]; then
  log "PCS_SKIP_LIBRARY=1: skipping ~/.claude-skills and its commands"
  exit 0
fi

log "installing alirezarezvani/claude-skills library @ ${LIBRARY_SHA:0:7} into ~/.claude-skills"
fetch_pinned "$LIBRARY_REPO" "$LIBRARY_SHA" "$work/library" "${LIBRARY_TEAMS[@]}" commands
marker="$LIBRARY_DIR/.installed-by-portable-claude-skills"
if [[ -d "$LIBRARY_DIR" && ! -f "$marker" ]]; then
  # A library this script didn't create (e.g. an older manual install): keep it aside.
  backup="${LIBRARY_DIR}.bak-$(date +%Y%m%d%H%M%S)"
  log "moving existing ~/.claude-skills to $backup"
  mv "$LIBRARY_DIR" "$backup"
fi
rm -rf "$LIBRARY_DIR"
mkdir -p "$LIBRARY_DIR"
echo "$LIBRARY_SHA" > "$marker"
cp "$work/library/LICENSE" "$LIBRARY_DIR/LICENSE"
for team in "${LIBRARY_TEAMS[@]}"; do
  cp -R "$work/library/$team" "$LIBRARY_DIR/$team"
done

# Upstream commands use paths relative to the library root (`product-team/skills/...`).
# Installed globally they run from any repo, so anchor those paths at ~/.claude-skills.
teams_pattern="$(IFS='|'; echo "${LIBRARY_TEAMS[*]}")"
for command in "${LIBRARY_COMMANDS[@]}"; do
  # The second expression fixes an upstream stale path (focused-fix moved under skills/).
  sed -E -e "s#(^|[^A-Za-z0-9_./~-])(${teams_pattern})/#\1~/.claude-skills/\2/#g" \
    -e "s#~/\.claude-skills/engineering/focused-fix#~/.claude-skills/engineering/skills/focused-fix#g" \
    "$work/library/commands/$command.md" > "$CLAUDE_DIR/commands/$command.md"
done

log "done: $(ls "$CLAUDE_DIR/skills" | wc -l | tr -d ' ') skills, $(ls "$CLAUDE_DIR/agents" | wc -l | tr -d ' ') agents, $(ls "$CLAUDE_DIR/commands" | wc -l | tr -d ' ') commands"
