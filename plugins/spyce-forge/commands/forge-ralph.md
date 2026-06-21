---
description: Set up and explain the Ralph autonomy loop for unattended grinding
argument-hint: [feature/backlog to grind]
allowed-tools: Read, Write, Bash
---

Prepare an autonomous Ralph loop to deliver: $ARGUMENTS

1. Draft a `prd.json` from the template at
   `forge-operating-model/assets/prd.json.example` — decompose the work into the
   smallest independently-shippable stories, each with crisp `acceptance` and
   `passes:false`, plus the `qualityChecks` array for this repo.
2. Write a `prompt.md` instructing each fresh iteration to: pick the
   highest-priority failing story, implement ONLY it, run qualityChecks, commit
   ONLY if green, flip `passes:true`, and append learnings to `progress.txt`.
3. Show the run command (Windows-primary):
   `pwsh -File "${CLAUDE_PLUGIN_ROOT}/skills/forge-operating-model/assets/ralph-loop.ps1" 20`
   (bash fallback: `ralph-loop.sh`).

Never run a loop without a per-iteration quality gate. See
`forge-operating-model/references/autonomy-loop.md`.
