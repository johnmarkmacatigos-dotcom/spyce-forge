# Orchestration — the swarm pattern

The reusable **method** for tasks that split into **independent subtasks that can
run at the same time** — large refactors touching many files, "do these five
things in parallel", breadth-first exploration. The pattern is tool-agnostic;
Forge's standard *engine* for it is **Ruflo** (see "The engine" section below).

## The four phases

```
You: "Refactor auth from Express middleware to Next.js API routes"

Phase 1    Decompose    -> a planner model turns the task into a dependency
                           graph of subtasks
Phase 2    Execute      -> parallel agents run independent subtasks, with a
                           live dashboard of progress
Phase 2.5  Quality gate -> a reviewer model inspects every agent's output
                           before anything is accepted
Phase 3    Summarize    -> results, cost per agent, and a session replay
```

1. **Decomposition.** A strong planner model reads the codebase and breaks the
   task into a **dependency graph**, not just a flat list. Edges in the graph
   say what must finish before what can start. This is the difference between
   real orchestration and "spawn five agents and hope."
2. **Parallel execution.** Independent nodes run concurrently. Nodes with
   unmet dependencies wait. A dashboard surfaces what each agent is doing so the
   run is observable rather than a black box.
3. **Quality gate (Phase 2.5).** Before any subtask output is merged, a reviewer
   pass checks it. This is the same principle as Ralph's per-iteration gate, but
   applied across parallel outputs — it stops one bad agent from poisoning the
   whole result.
4. **Summary.** You get a consolidated result plus **cost accounting** (parallel
   agents burn tokens fast, so this matters) and a replay of the session for
   debugging.

## When parallelism actually helps

Parallel agents win when subtasks are genuinely independent. They hurt when:
- Subtasks share state or files and will collide (merge conflicts, race on the
  same module). Serialize those — that's what the dependency graph is for.
- The task is small. Orchestration overhead (decompose + gate + summarize) isn't
  worth it for a 15-minute job.
- You can't define a quality gate per subtask. Without Phase 2.5 you're just
  multiplying unreviewed output.

## Cost is a first-class concern

N parallel agents cost roughly N× the tokens of one. The summary's cost
accounting exists because this adds up. Before fanning out wide, sanity-check
that the wall-clock speedup is worth the spend — and prefer a few well-scoped
agents over a swarm of tiny ones.

## How it composes with the rest

- Use the **methodology** to produce the spec and plan first; the decomposition
  in Phase 1 is only as good as the plan it starts from.
- Give each parallel agent **Context7** access so none of them hallucinate APIs.
- Independent slices -> swarm (parallel). A dependent chain -> Ralph loop
  (sequential). A big build often does both: swarm the independent foundation,
  then loop the dependent feature work on top.

## Practical setup

The *pattern* is the reusable asset: decompose into a dependency graph -> run
independent nodes in parallel -> gate every output -> summarize with cost. Forge
implements it through **Ruflo** (installed by `forge-setup`) — see "The engine"
below — but the same shape works with whatever subagent mechanism your harness
provides.


---

## The engine: Ruflo (the pattern above is tool-agnostic)

The decompose → parallelize → gate → summarize pattern is the *method*; **Ruflo**
(ruvnet/ruflo, = claude-flow v3) is the *engine* Forge standardizes on. It covers
both intensity levels itself, so there's no second swarm tool to choose between:

| | **Ruflo plugin path** (`ruflo-core@ruflo`) | **Ruflo full init** (`npx ruflo init`) |
|---|---|---|
| Footprint | **Zero** workspace files — slash commands only | Writes `.claude/`, `.claude-flow/`, `CLAUDE.md`, settings, hooks, a daemon |
| Power | Coordinated commands + a few skills/agents | Full loop — ~98 agents, swarms, self-learning memory, federation |
| Reach for it | Most parallel jobs; the light, safe default | Big, long-running, many-agent jobs where hand-decomposition is the bottleneck |

Both are wired by the **forge-setup** skill (plugin path installed by default; full
init printed as opt-in). Optional extra plugins: `ruflo-swarm@ruflo`,
`ruflo-rag-memory@ruflo`.

### The hook-conflict rule (read before stacking)

Ruflo's full init, superpowers' SessionStart hook, and Graphify's PreToolUse hook
are **three separate always-on systems**. Stack them blindly and they talk over
each other. Sane default loadout:

- **One methodology brain:** Forge's `forge-operating-model` + superpowers. Not three.
- **Always-on grounding hook:** Graphify (cheap, AST-only, genuinely additive).
- **Orchestration per job:** reach for Ruflo's plugin path for most parallel work;
  reserve the full `npx ruflo init` for a deliberate, per-repo decision, and verify
  its hooks aren't double-firing against superpowers/Graphify before trusting the
  routing.
