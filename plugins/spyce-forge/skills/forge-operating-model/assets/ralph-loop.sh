#!/usr/bin/env bash
# ralph-loop.sh — a portable autonomous "Ralph" loop.
# Each iteration is a FRESH agent instance with clean context. Memory lives in
# git history, progress.txt, and prd.json. See references/autonomy-loop.md.
#
# Usage: ./ralph-loop.sh [max_iterations]   (default 10)
# Requires: a coding CLI (e.g. `claude`) and `jq`.

set -euo pipefail

MAX_ITERS="${1:-10}"
PROMPT_FILE="${PROMPT_FILE:-prompt.md}"   # the per-iteration instructions
PRD_FILE="${PRD_FILE:-prd.json}"
AGENT_CLI="${AGENT_CLI:-claude}"          # override to your tool, e.g. amp

remaining() {
  # count stories still failing
  jq '[.stories[] | select(.passes == false)] | length' "$PRD_FILE"
}

if [[ ! -f "$PRD_FILE" ]]; then
  echo "No $PRD_FILE found. Create one (see prd.json.example) first." >&2
  exit 1
fi

for ((i = 1; i <= MAX_ITERS; i++)); do
  left="$(remaining)"
  echo "=== Iteration $i/$MAX_ITERS — $left stories remaining ==="
  if [[ "$left" -eq 0 ]]; then
    echo "All stories pass. Done."
    exit 0
  fi

  # Spawn a fresh instance. The prompt file must instruct the agent to:
  #   1. pick highest-priority story where passes:false
  #   2. implement ONLY that story
  #   3. run qualityChecks; commit ONLY if green
  #   4. set passes:true in prd.json
  #   5. append learnings to progress.txt and update AGENTS.md/CLAUDE.md
  "$AGENT_CLI" -p "$(cat "$PROMPT_FILE")" || {
    echo "Iteration $i failed; learnings should be in progress.txt. Continuing." >&2
  }
done

echo "Hit max iterations ($MAX_ITERS). $(remaining) stories still failing." >&2
