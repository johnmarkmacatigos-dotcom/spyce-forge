---
description: Plan parallel multi-agent orchestration for independent subtasks
argument-hint: [large or parallelizable task]
allowed-tools: Read, Grep, Glob
---

Plan a swarm decomposition for: $ARGUMENTS

1. Break the work into a dependency graph: which slices are truly independent
   (parallelizable) vs. which must be sequenced. If the repo is large or
   unfamiliar, run `/forge-map` first so the decomposition is grounded in the
   real structure, not a guess.
2. For each parallel slice, define a self-contained brief an isolated agent could
   execute without shared context, plus its quality gate.
3. Identify the merge/integration step and how conflicts get resolved.
4. Estimate cost/benefit vs. sequential, then pick the Ruflo gear:
   - **Plugin path** (`ruflo-core@ruflo`) — the light, zero-footprint default for
     most parallel jobs.
   - **Full init** (`npx ruflo init`) — only when the job is big enough that many
     coordinated agents + self-learning pay off, and heed the hook-conflict
     warning before stacking it on superpowers + Graphify.

Ruflo is the single orchestration engine (two gears, no second tool to choose).
See `forge-operating-model/references/orchestration.md`. Wired by `forge-setup`.
