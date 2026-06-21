# Autonomy loop — the Ralph pattern

From **snarktank/ralph** (building on Geoffrey Huntley's "Ralph" pattern). Use
this when there's a backlog of work and the user wants the agent to **keep going
unattended until it's done** — overnight builds, grinding through a PRD, "just
make it work and tell me in the morning."

## The core idea: fresh context every iteration

The loop spawns a **brand-new agent instance on every iteration** with a clean
context window. This is counterintuitive but it's the whole trick: a stuffed,
degraded context produces worse code, so instead of one marathon session you run
many short, sharp ones. The only things that carry between iterations are:

- **Git history** — the actual committed work.
- **`progress.txt`** — an append-only log of learnings and gotchas.
- **`prd.json`** — the task list, each story flagged `passes: true/false`.

That's the memory. Everything else resets. (Compare `methodology.md` -> Memory.)

## The per-iteration algorithm

Each fresh instance does exactly this and then exits:

1. Create/checkout the feature branch (from the PRD's `branchName`).
2. Pick the **highest-priority story where `passes: false`**.
3. Implement **that one story only**.
4. Run quality checks — typecheck, tests, lint.
5. **Commit only if checks pass.**
6. Mark the story `passes: true` in `prd.json`.
7. Append what was learned to `progress.txt`.
8. Exit. The shell loop spawns the next fresh instance. Repeat until all stories
   pass or the iteration cap is hit.

The quality gate in step 4-5 is load-bearing: without it, an autonomous loop
will cheerfully commit broken code forever. Never run the loop without it.

## Right-sizing stories (the make-or-break detail)

Each story must fit comfortably in **one context window.** If it doesn't, the
agent runs out of room mid-task and ships garbage. Calibrate like this:

**Right-sized:**
- Add a database column + migration.
- Add one UI component to an existing page.
- Update one server action with new logic.
- Add a filter dropdown to a list.

**Too big — split before running:**
- "Build the entire dashboard."
- "Add authentication."
- "Refactor the API."

Turning a vague request into a list of right-sized stories *is* the PRD step
below, and it's where most of the human judgment lives.

## Workflow

1. **Write a PRD.** Describe the feature; answer clarifying questions; produce a
   markdown PRD of user stories.
2. **Convert to `prd.json`.** Structure the stories for autonomous execution —
   each with priority, acceptance criteria, and `passes: false`. See
   `assets/prd.json.example`.
3. **Run the loop.** `assets/ralph-loop.sh` is a portable version. It takes a
   max-iteration count (default 10) and, each iteration, invokes your coding CLI
   on a prompt file with the algorithm above.

```bash
./ralph-loop.sh 20          # up to 20 iterations
```

## Keep the agent docs current

After each iteration the loop should update `AGENTS.md`/`CLAUDE.md` with any new
convention or gotcha discovered. This is treated as critical: it's how the
*next* fresh instance avoids relearning what this one just learned.

## When NOT to use the loop

- Tasks that need a human decision mid-flight (design taste, product calls).
- Anything without a reliable automated quality gate — if `passes` can't be
  checked by a script, the loop can't self-verify.
- A single small task that fits one window — just do it directly.

## Unattended means no irreversible actions

When the loop runs while no one is watching, keep it inside a reversible
sandbox: work on a feature branch, commit there, and stop. Never let an
unattended loop merge to main, deploy, run destructive migrations against real
data, or send anything outward. The human reviews the branch in the morning —
that review is the real merge gate.

## Loop vs Swarm

Ralph is **sequential depth** (one fresh agent after another, each building on
committed work). The swarm (`orchestration.md`) is **parallel breadth** (many
agents at once on independent slices). They combine: a swarm can fan out
independent stories, and a Ralph loop can grind a dependent chain. Pick
sequential when later work depends on earlier commits; parallel when slices are
independent.
