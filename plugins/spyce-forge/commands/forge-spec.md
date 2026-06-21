---
description: Spec-first kickoff for a build — ground, then spec, before any code
argument-hint: [what you want to build]
allowed-tools: Read, Grep, Glob, Bash
---

Engage the `forge-operating-model` Core Loop for: $ARGUMENTS

Do NOT write implementation code yet. Instead:

1. **Ground in reality.** Read the relevant existing code and run the relevant
   thing. For any external/fast-moving library involved, pull current docs via
   the Context7 MCP server — never design against remembered APIs.
2. **Extract the spec in digestible chunks.** Restate what the user is really
   trying to do, in pieces short enough to sign off on. Surface assumptions and
   open questions. Get explicit agreement before designing.
3. Only after the spec is agreed, write a plan a careless junior could follow,
   with true red/green TDD baked in, YAGNI, and DRY.

Honor the SPYCE PROJECT house rules: backend-before-frontend deploy order,
PowerShell-safe + BOM-free commands, free-tier-first infra, no secrets in client
bundles, complete working code over sketches.
