---
name: forge-setup
description: >
  One-time installer and de-conflictor for the SPYCE Forge stack. Use this skill
  when the user asks to "set up forge", "install the stack", "wire up my tools",
  "install superpowers / context7 / playwright / ralph / swarm / the video
  toolkit", or when a forge capability is referenced but its external dependency
  is not yet installed. It registers the superpowers marketplace plugin, confirms
  the bundled Context7 + Playwright MCP servers, sets up the Ralph loop, and
  prepares Graphify, Ruflo, and the video toolkit — in the correct order, with the
  known Playwright name-collision avoided and ECC intentionally left manual.
metadata:
  version: "0.1.0"
---

# Forge Setup

Run the one-time wiring for the consolidated stack. Most of the heavy lifting is
already bundled in this plugin; this skill installs only the genuinely external
pieces and prevents the two known failure modes.

## What is already live (no action needed)

- **Context7 MCP** and **Playwright MCP** ship in this plugin's `.mcp.json`.
  They are active the moment the plugin is installed. Do **not** add a second
  Playwright MCP server — exactly one is registered, under the name `playwright`.
  Adding `executeautomation/mcp-playwright` under a colliding name is the #1
  historical break; the orchestration/browser references explain when the
  community server is worth it (separate name only).
- **The methodology** (`forge-operating-model`) loads automatically on build
  tasks.
- **The Ralph loop** ships as `ralph-loop.ps1` (Windows-primary) and
  `ralph-loop.sh` with a `prd.json` template — no external install.

## What this skill installs

Run the bundled installer. On Windows / PowerShell (the operator's default):

```powershell
pwsh -File "${CLAUDE_PLUGIN_ROOT}/skills/forge-setup/scripts/install-stack.ps1"
```

On macOS / Linux / Git Bash:

```bash
bash "${CLAUDE_PLUGIN_ROOT}/skills/forge-setup/scripts/install-stack.sh"
```

The installer is **idempotent** and **non-destructive** — it checks before it
acts and never overwrites existing config. It performs, in order:

1. **Superpowers** (methodology marketplace plugin, the source of `/brainstorm`,
   `/write-plan`, `/execute-plan` and 20+ skills):
   - `claude /plugin marketplace add obra/superpowers-marketplace`
   - `claude /plugin install superpowers@superpowers-marketplace`
   - This self-updates via its own SessionStart hook; do not vendor its skills.
2. **MCP sanity check** — confirms `context7`, `playwright`, and `porkbun`
   resolve, and warns loudly if a second Playwright server is registered anywhere.
   The Porkbun server runs **docs-only** until `PORKBUN_API_KEY` /
   `PORKBUN_SECRET_API_KEY` are set (see the `forge-domain` skill).
3. **Graphify** (codebase grounding — the internal counterpart to Context7):
   - Ensures `uv` is present (Windows: `winget install astral-sh.uv`), then
     `uv tool install graphifyy` (PyPI package is `graphifyy`, double-y).
   - Runs `graphify install` to register Graphify's skill + PreToolUse hook for
     Claude Code, and prints the per-repo `graphify hook install` command.
   - Code extraction is local/AST (no API cost); only semantic queries use a model.
4. **Ruflo** (the orchestrator = claude-flow v3) — installs the **safe,
   non-invasive plugin path** by default:
   - `claude /plugin marketplace add ruvnet/ruflo`
   - `claude /plugin install ruflo-core@ruflo`
   - Gives slash commands with **zero** workspace files; optional extras
     `ruflo-swarm@ruflo`, `ruflo-rag-memory@ruflo`. The full
     `npx ruflo@latest init wizard` (98 agents, daemon, hooks, writes
     `CLAUDE.md`/`.claude/`) is **printed as opt-in only, not auto-run** — it is
     invasive and must be a deliberate per-repo decision. Ruflo is the single
     orchestration engine (light plugin path vs heavy full init); there is no
     second swarm tool to choose between.
5. **Video toolkit** — clones `digitalsamba/claude-code-video-toolkit` into the
   tools workspace so the NARRATE→…→RENDER pipeline has its scaffolding.
6. **ECC** — intentionally **not** auto-installed. Its good ideas (instincts +
   memory) are already folded into `forge-operating-model`. If the user
   explicitly wants ECC's code, the installer prints the manual clone command
   with a review warning, and stops there.

## The hook-conflict rule (important)

Superpowers (SessionStart hook), Graphify (PreToolUse hook), and Ruflo's full
init (its own routing hooks) are three always-on systems. Do **not** stack all
three plus Forge blindly. Sane default: Forge methodology + superpowers as the
single brain, Graphify as the cheap always-on grounding hook, and reach for
Ruflo *per job* (plugin path for most work) rather than running its full init globally.
See `forge-operating-model/references/orchestration.md`.

## Verifying

After install, a fresh session should: start any feature request by clarifying
requirements instead of jumping to code (superpowers + methodology active), be
able to pull current library docs (Context7), and be able to drive a browser
(Playwright). If the agent jumps straight to code, re-run step 1 and restart the
session.

## Notes for this operator

- All terminal output is PowerShell-safe.
- The tools workspace defaults to `$HOME/spyce-forge-tools` (override with
  `-ToolsDir` / `$FORGE_TOOLS_DIR`); cloned repos never touch project trees.
- Nothing here writes secrets or edits version-controlled files.
