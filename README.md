# SPYCE Forge

**One Claude Code plugin that consolidates a whole agentic engineering stack.**

Forge replaces the fragile "install nine separate repos and hope they don't
collide" setup with a single install that bundles a working methodology, dual
grounding, three live MCP servers, an autonomy loop, a two-stage reviewer, and a
safe domain-acquisition capability — and cleanly wires up the heavier external
tools instead of vendoring (and rotting) copies of them.

> Part of the **SPYCE PROJECT**. This repo is a Claude Code *marketplace* that
> ships one plugin: `spyce-forge`.

## Why

The source tools are different *species* — a methodology plugin, MCP servers, an
orchestrator, a codebase grapher, a video pipeline. Physically merging them would
break the moment any upstream updates. So Forge **bundles what should be bundled**
and **wires up what shouldn't**:

| Capability | How Forge handles it |
|---|---|
| Methodology (research → spec → plan → TDD → review) | bundled skill `forge-operating-model` + superpowers (installed by setup) |
| External-library grounding | bundled `context7` MCP — current, version-correct docs |
| Codebase grounding | Graphify — maps your repo into a queryable graph (`/forge-map`) |
| Browser automation | bundled `playwright` MCP (one canonical server — no collision) |
| Domain acquisition + DNS | bundled official `porkbun` MCP + `forge-domain` skill |
| Autonomy loop | portable Ralph loop (PowerShell + bash) |
| Orchestration | Ruflo — one engine, two gears (plugin path / full init) |
| Code review | `forge-reviewer` subagent — functional pass, then quality pass |

## Install (Claude Code)

```
/plugin marketplace add johnmarkmacatigos-dotcom/spyce-forge
/plugin install spyce-forge@spyce-forge-marketplace
/reload-plugins
```

Instant local test, no marketplace:
```
claude --plugin-dir ./plugins/spyce-forge
```

Then once: run `/forge-setup` (wires superpowers, Graphify, Ruflo, video toolkit),
set `PORKBUN_API_KEY` / `PORKBUN_SECRET_API_KEY` for live domain ops, and restart
the session.

## Commands

`/forge-spec` · `/forge-ground` (external libs) · `/forge-map` (codebase graph) ·
`/forge-ralph` (autonomy loop) · `/forge-swarm` (orchestration) · `/forge-domain`
(acquire a domain) · `/forge-setup` (one-time wiring)

## The loadout rule

Run **one** methodology brain (Forge + superpowers) + Graphify grounding
always-on, and reach for Ruflo *per job*. Don't stack Ruflo's full init,
superpowers' SessionStart hook, and Graphify's PreToolUse hook blindly — they're
three always-on systems and will fight.

## License

MIT — see [LICENSE](./LICENSE).
