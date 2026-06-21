# SPYCE Forge

**One install for the whole agentic engineering stack.** Forge consolidates the
tools we previously wired up piecemeal into a single Claude Code plugin —
bundling what should be bundled, and cleanly wiring up what shouldn't.

It replaces the fragile "install nine separate repos and hope they don't
collide" setup with: methodology that auto-loads, two MCP servers that go live
on install, an autonomy loop and a swarm planner as slash commands, a two-stage
reviewer, and one idempotent installer for the genuinely-external pieces.

## Why this exists

The source repos are several different *species*:

| Species | Repos | How Forge handles it |
|---|---|---|
| Methodology plugin | obra/superpowers, affaan-m/ECC | superpowers installed via marketplace; ECC's ideas folded into the methodology, its code left manual |
| MCP servers | upstash/context7, microsoft/playwright-mcp, executeautomation/mcp-playwright | Context7 + **one canonical** Playwright bundled in `.mcp.json` (collision structurally removed) |
| External-library grounding | upstash/context7 | bundled MCP — current, version-specific docs on demand |
| Codebase grounding | safishamsi/graphify | installed by setup (uv + `graphifyy`); native skill + commit-hook; `/forge-map` wrapper. Maps your repo into a queryable graph (local AST, no API cost) |
| Autonomy loop | snarktank/ralph | Ralph shipped as a portable loop (PS + bash) — no external dep |
| Orchestration (one engine, two gears) | ruvnet/ruflo (claude-flow v3) | the sole orchestrator: safe **plugin path** by default (`ruflo-core@ruflo`, zero files) + opt-in `npx ruflo init`. claude-swarm dropped — Ruflo's plugin path already covers the light case |
| Domain acquisition + DNS | porkbunllc/mcp-server (official) | official `@porkbunllc/mcp-server` bundled in `.mcp.json` (docs-only until keys set); `forge-domain` skill + `/forge-domain` drive the safe check→dry-run→register→DNS flow |
| Library / workspace | microsoft/playwright, digitalsamba/claude-code-video-toolkit | Playwright reached via its MCP; video toolkit cloned by the installer |

Trying to physically merge all nine into one folder would rot the instant any
upstream updates. Forge respects each tool's update path while giving you a
single entry point.

## Components

- **Skill: `forge-operating-model`** — the always-on decision framework + Core
  Loop (research → spec → plan → execute → review), the SPYCE house rules, and
  seven bundled references (methodology, autonomy-loop, orchestration,
  grounding-context7, grounding-codebase-graphify, browser-automation,
  video-production).
- **Skill: `forge-setup`** — the one-time installer/de-conflictor.
- **Skill: `forge-domain`** — find, secure, and stand up a domain via the safe
  Porkbun flow (check → registerable? → dry-run → confirm → register → DNS→Vercel).
- **MCP servers (bundled, live on install):** `context7`, `playwright`, and the
  official **`porkbun`** domain/DNS server (docs-only until keys are set).
- **Commands:** `/forge-spec`, `/forge-ground` (external libs), `/forge-map`
  (codebase graph), `/forge-ralph`, `/forge-swarm`, `/forge-domain`, `/forge-setup`.
- **Agent: `forge-reviewer`** — two-stage (functional, then quality) review.
- **Assets:** `ralph-loop.ps1` (Windows-primary), `ralph-loop.sh`,
  `prd.json.example`, `mcp-config.example.json`.

### Dual grounding & the loadout rule

Forge grounds on two axes before any code: **Context7** for external library
reality, **Graphify** for your own codebase (`/forge-map`). Both are cheap and
additive. Orchestration is different — Ruflo and superpowers overlap. The rule:
run **one** methodology brain (Forge + superpowers) + Graphify grounding
always-on, and reach for Ruflo *per job* (plugin path for most work). Don't stack
Ruflo's full init, superpowers' SessionStart hook, and Graphify's PreToolUse hook
blindly — they're three always-on systems and will fight.

## Setup

1. Install the plugin (the bundled MCP servers activate immediately).
2. Run the one-time installer for the external pieces:
   - **Windows / PowerShell:** `pwsh -File "${CLAUDE_PLUGIN_ROOT}/skills/forge-setup/scripts/install-stack.ps1"`
   - **macOS / Linux / Git Bash:** `bash "${CLAUDE_PLUGIN_ROOT}/skills/forge-setup/scripts/install-stack.sh"`
   - or just run `/forge-setup` inside a session.
3. Restart the session so superpowers' SessionStart hook loads.

**Requirements:** Node + `npx` (for the MCP servers), `git` (for clone steps),
the `claude` CLI (for plugin installs), and — for live domain ops — a Porkbun
API key pair (`PORKBUN_API_KEY` / `PORKBUN_SECRET_API_KEY`; use a dedicated,
spend-capped key). The installer skips gracefully if anything is missing.

## Usage

- Starting a build? `/forge-spec build the withdrawal settlement flow` — grounds
  and specs before any code.
- About to touch a fast-moving library? `/forge-ground react-native 0.73`.
- Working in an existing repo? `/forge-map` — builds a queryable graph of the
  codebase so you query instead of grepping (PowerShell: `graphify .`).
- Need a domain? `/forge-domain stacklore.dev` — checks, dry-runs, and (on your
  explicit yes) registers via Porkbun, then points DNS at Vercel.
- Big backlog to grind unattended? `/forge-ralph`.
- Parallelizable refactor? `/forge-swarm`.
- Before committing? Ask for a review — the `forge-reviewer` agent runs.

## Notes

- All terminal output is PowerShell-safe; file-write guidance is BOM-free.
- No secrets are written; no version-controlled files are edited; external repos
  clone to `$HOME/spyce-forge-tools` (override with `FORGE_TOOLS_DIR`).
- Rename the plugin by editing the single `name` field in
  `.claude-plugin/plugin.json`.

_Part of the SPYCE PROJECT. v0.3.0._
