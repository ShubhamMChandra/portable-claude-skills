#!/usr/bin/env bash
# lane-watcher.sh <task-id> [interval-seconds]
#
# Bridges an external execution lane (an agentic-CLI dispatch tracked by a
# companion runtime) into the owning session's background tasks: run this via
# a backgrounded shell from the REPO DIRECTORY the lane was dispatched from,
# immediately after dispatch. It polls the companion's status until the lane
# leaves running state, then exits — the task-completion notification wakes
# the owning session, which collects the result and updates its registry.
#
# Written for the Codex companion runtime; adapt COMPANION discovery and the
# status-line grep for other runtimes. The status output it expects contains
# a line like: "- <task-id> | <status> | ...".
#
# Exit codes: 0 lane terminal (line printed), 2 companion missing,
# 3 task never seen (dead dispatch or wrong repo dir), 4 watch timeout.

TASK="$1"
INT="${2:-45}"
MAX=$((4 * 3600))
ELAPSED=0
MISS=0

[ -z "$TASK" ] && { echo "usage: lane-watcher.sh <task-id> [interval-seconds]"; exit 1; }

COMPANION=$(ls -d "$HOME/.claude/plugins/cache/openai-codex/codex/"*/scripts/codex-companion.mjs 2>/dev/null | sort -V | tail -1)
[ -z "$COMPANION" ] && { echo "lane-watcher: companion runtime not found in plugin cache"; exit 2; }
# node needs a native-style path on Windows: with MSYS path conversion
# disabled, a POSIX /c/... path silently 404s inside node.
command -v cygpath >/dev/null 2>&1 && COMPANION=$(cygpath -m "$COMPANION")

while [ "$ELAPSED" -lt "$MAX" ]; do
  LINE=$(node "$COMPANION" status "$TASK" 2>/dev/null | grep -F -- "$TASK" | head -1)
  if [ -z "$LINE" ]; then
    MISS=$((MISS + 1))
    if [ "$MISS" -ge 5 ]; then
      echo "lane-watcher: $TASK not found after $MISS checks — dead dispatch or wrong repo dir (companion state is per-repo)"
      exit 3
    fi
  else
    MISS=0
    case "$LINE" in
      *"| running"* | *"| pending"* | *"| queued"* | *"| starting"*) : ;;
      *)
        echo "lane-watcher terminal: $LINE"
        echo "collect: node \"$COMPANION\" result $TASK"
        exit 0
        ;;
    esac
  fi
  sleep "$INT"
  ELAPSED=$((ELAPSED + INT))
done

echo "lane-watcher: $TASK still not terminal after ${MAX}s — inspect the lane manually"
exit 4
