---
name: forge-operating-model
description: >
  The SPYCE Forge operating system for autonomous engineering work. Use this skill
  whenever a task is bigger than a single quick edit — building or shipping a feature
  or app (SPYCE, Deployr, Aether, OneGo, Relayr, Stacklore or anything else),
  running a long unattended job, coordinating parallel workstreams, writing code
  against an unfamiliar or fast-moving library, mapping or navigating an existing
  codebase, automating a browser, or producing a
  video. Trigger it even when the user does not name a technique: phrases like
  "build X", "ship this feature", "let it run until it's done", "do this in
  parallel", "use the latest docs for Y", "map the codebase", "where does X
  live", "test/automate the site", "scrape", "fill
  the form", or "make a video" all mean this skill should engage. It is the decision
  framework plus the bundled methodology that consolidates superpowers, ECC, Ralph,
  Ruflo, Context7, Graphify, Playwright (+ Playwright-MCP), the Porkbun domain
  toolkit, and the
  video toolkit into
  one model. Prefer this skill over ad-hoc approaches for any multi-step engineering
  task.
metadata:
  version: "0.2.0"
  author: "John Mark Macatigos / SPYCE PROJECT"
---

# Forge Operating Model

A single operating model for doing serious engineering work as an autonomous
agent. It answers two questions on every task: **how should I work**, and
**which capability do I reach for**.

Think of it as a small engineering org compressed into one agent:
a **methodology** (how a good engineer thinks), an **autonomy loop** (a junior
who can grind unattended), an **orchestrator** (a tech lead who parallelizes),
a **librarian** (who always has current docs), and a **pair of hands** (a
browser and a video studio).

This is the consolidated form of the nine frameworks. The MCP librarian
(Context7) and the browser hands (Playwright) ship live with this plugin — no
extra setup. The external orchestrators (the superpowers marketplace plugin,
the video toolkit) are wired up by the **forge-setup** skill. Domain
acquisition + DNS ship via the bundled Porkbun MCP (see the `forge-domain` skill).

## The cardinal rule: don't jump to code

The single highest-leverage habit across every framework here is the same:
when you sense the user is *building* something, **do not immediately start
writing code.** Step back, understand the real goal, ground yourself in current
reality, then plan. Code is the last 20%, not the first move. Skipping this is
the most common way agents waste a user's time and tokens.

**But match the process to the task size.** This rule is for *substantial*
work — a feature, an app, anything that won't fit cleanly in one pass. A
one-line rename, a typo fix, a single obvious edit, or a direct question does
**not** earn spec-and-plan ceremony: just do it. Over-processing a trivial task
wastes exactly the time the cardinal rule is trying to save. The heading says
"don't jump to code," not "never write code without a spec."

## Decision framework — what to reach for

Read the task, then route. These compose; a big build often uses all of them.

| Signal in the task | Reach for | Reference |
|---|---|---|
| Trivial single edit, typo, rename, direct question | **Just do it** — no machinery | — |
| Any non-trivial build ("build", "add a feature", "ship") | The **Core Loop** below | `references/methodology.md` |
| "Let it run", "keep going until done", overnight/unattended, big backlog | **Autonomy loop** (Ralph) | `references/autonomy-loop.md` |
| Independent subtasks, "in parallel", large refactor across many files | **Orchestration** (Ruflo) | `references/orchestration.md` |
| Unfamiliar/fast-moving *external* library, "use the latest", version-specific API | **External grounding** (Context7) | `references/grounding-context7.md` |
| Existing/unfamiliar *codebase*, "where does X live", "what connects A to B", "what breaks if…", architecture | **Codebase grounding** (Graphify) | `references/grounding-codebase-graphify.md` |
| "Automate the site", scrape, fill a form, e2e test, login flow | **Browser automation** (Playwright) | `references/browser-automation.md` |
| "Get/buy/check a domain", "register", "point DNS at Vercel", a named domain to secure | **Domain acquisition** (Porkbun) | `forge-domain` skill |
| "Make a video", narration, screen capture, demo reel | **Video production** | `references/video-production.md` |

When several apply, the usual order is: **ground → spec → plan → (loop or
swarm) → execute with browser/video tools as hands → review.**

## The Core Loop (methodology)

This is the superpowers/ECC backbone — the way to work on *any* substantial
task. Full detail and the "instincts" + memory + security model live in
`references/methodology.md`; here is the load-bearing sequence.

1. **Research first.** Before proposing a design, find out what's actually
   true. Read the relevant code, run the failing thing, and ground yourself on
   *both* axes: pull *current* docs for any external library via Context7, and
   map the *internal* codebase with Graphify (`graphify .`, then
   `graphify query "…"` instead of grepping) when working in a real, multi-module
   repo. An hour of reality beats a day of confident guessing. Never design
   against remembered APIs or a half-remembered file layout.
2. **Extract a spec, in digestible chunks.** Tease out what the user is really
   trying to do. Show the spec back in pieces short enough to actually read and
   sign off on — not a wall of text. Get explicit agreement before designing.
3. **Write a plan a careless junior could follow.** Assume the implementer has
   no context, no taste, and an aversion to testing. Bake in **true red/green
   TDD** (write the failing test first), **YAGNI**, and **DRY**.
4. **Execute task by task, reviewing as you go.** Implement one slice, prove it
   with a test, inspect the result, then continue. For long or parallel work,
   hand slices to the autonomy loop or the orchestrator.
5. **Verify and review.** Run typecheck + tests. A change isn't done until the
   checks are green and the diff has been read with fresh eyes. Use the
   `forge-reviewer` subagent for a two-stage (functional, then quality) pass.

Two cross-cutting habits from ECC ride along the whole loop:

- **Instincts** — a few always-on rules you never violate (e.g. "never commit
  secrets", "tests before commits", "read before edit"). They are cheap, always
  loaded, and they catch the dumb mistakes. See `references/methodology.md`.
- **Memory** — persist what you learned so the *next* context window isn't
  starting blind. In a loop this is `progress.txt` + git history; in a repo it
  is an `AGENTS.md`/`CLAUDE.md` you keep current.

## SPYCE PROJECT house rules (always on)

These are non-negotiable for this operator and override generic defaults:

- **Deploy order is sacred.** Backend first → wait for green → then frontend.
  Test in the real client (e.g. Pi Browser for SPYCE) before moving on.
- **PowerShell-safe commands.** This environment is Windows + PowerShell. Never
  emit bash-only syntax for the user's terminal. For file writes that must be
  BOM-free, use `[System.IO.File]::WriteAllText(path, text, (New-Object System.Text.UTF8Encoding $false))` — never `Set-Content` (it injects a BOM).
- **Free-tier infrastructure first.** Default to Vercel / Supabase / Render /
  Cloudinary / MongoDB Atlas free tiers; flag the first scaling constraint
  rather than reaching for paid infra unprompted.
- **Secrets never ship.** API keys live in environment variables
  (`ANTHROPIC_API_KEY`, never `NEXT_PUBLIC_*`), never in version control,
  never in client bundles. Route model calls through an auth-gated serverless
  proxy.
- **Complete working code over sketches.** Deliver the best solution; run the
  tests; fix the errors before handing it over.

## Setup (one-time)

The two MCP servers that do most of the heavy lifting **ship with this plugin**
and are live on install — Context7 (current, version-specific library docs) and
Playwright (a real browser driven by the accessibility tree). There is exactly
one Playwright server registered under the canonical name `playwright`, which
removes the historical two-server name collision.

Everything else (the superpowers marketplace plugin, **Graphify** for codebase
grounding, the Ralph loop, orchestration via **Ruflo**, domain acquisition,
the video toolkit) is wired up by the **forge-setup** skill — run it once. A standalone, editable MCP config for non-plugin contexts is at
`assets/mcp-config.example.json`. The autonomy loop ships as both
`assets/ralph-loop.ps1` (PowerShell, primary on Windows) and
`assets/ralph-loop.sh` (bash), with a PRD template at `assets/prd.json.example`.

## How the references fit together

- `references/methodology.md` — the full superpowers/ECC working model:
  research-first, spec-then-plan, subagent-driven TDD, instincts, memory,
  security posture.
- `references/autonomy-loop.md` — the Ralph pattern: fresh context per
  iteration, one small story at a time, git + `progress.txt` as memory,
  quality gates before commit.
- `references/orchestration.md` — the orchestration pattern (engine: Ruflo): decompose into a
  dependency graph, run agents in parallel, gate quality, summarize cost.
- `references/grounding-context7.md` — how and when to pull live *external*
  library docs so you stop hallucinating APIs.
- `references/grounding-codebase-graphify.md` — Graphify: map your own codebase
  into a queryable graph and query it instead of grepping.
- `references/browser-automation.md` — Playwright as the agent's hands;
  CLI+SKILLS vs official MCP vs the community ExecuteAutomation server.
- `references/video-production.md` — the NARRATE → SCORE → GENERATE → COMPOSE →
  RENDER pipeline for turning work into a watchable video.

## Anti-patterns to refuse

- Writing code before researching reality or agreeing on a spec.
- Designing against an API from memory when current docs are one tool call away.
- Stuffing a giant task into one context window instead of slicing it.
- Marking work "done" without green tests and a read-through of the diff.
- Running an unattended loop with no per-iteration quality gate.
- Emitting bash-only or BOM-injecting commands into a PowerShell environment.
