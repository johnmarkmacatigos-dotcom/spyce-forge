# Grounding II — the codebase (Graphify)

Context7 grounds you in *external* reality (current library APIs). **Graphify
grounds you in *internal* reality** — your own codebase, docs, and assets — by
turning the whole project into a queryable knowledge graph instead of something
you grep file-by-file. The two together are the full "research first" step of
the Core Loop: external docs + internal map before any spec.

Use Graphify whenever you are working in an existing or unfamiliar repo and need
to answer "where does X live", "what connects A to B", "what breaks if I change
this", or "what's the architecture here" — before designing anything.

## What it is

- A Python tool (PyPI package **`graphifyy`**, double-y; CLI command is
  `graphify`). YC S26.
- `graphify .` maps code, docs, PDFs, images, and video into three artifacts in
  `graphify-out/`: `graph.html` (interactive), `GRAPH_REPORT.md` (key concepts +
  surprising connections + suggested questions), and `graph.json` (the full
  graph, queryable).
- **Code extraction is local** (tree-sitter AST, *no* API calls / no cost).
  Only the semantic enrichment and `query` calls use a model — and when driven
  as the assistant's skill, that's the host model, so no separate key is needed.
  Standalone backends honor `ANTHROPIC_API_KEY` (default model
  `claude-sonnet-4-6`), `GEMINI_API_KEY`, `OPENAI_API_KEY`, Bedrock, or Ollama.

## How to use it (PowerShell-safe)

> On Windows PowerShell call it **`graphify .`** — *not* `/graphify .`. The
> leading slash is a path separator in PowerShell and will break the command.

1. **Build / refresh the graph:** `graphify .`
2. **Query instead of grepping:** `graphify query "what connects auth to the database?"`
   — returns a scoped subgraph, far cheaper than reading the whole report.
   Also: `graphify path <a> <b>`, `graphify explain <node>`.
3. **Architecture page with Mermaid call-flow:** `graphify export callflow-html`.
4. **Keep it fresh automatically:** `graphify hook install` adds a post-commit
   hook that rebuilds the graph (AST only, no API cost) and a git merge driver
   that union-merges `graph.json` so parallel commits never leave conflict
   markers. Re-run after any graphify upgrade (it embeds the interpreter path).

## How it integrates with Claude Code

`graphify install` (auto-detected on Windows; `graphify claude install` to be
explicit) writes a `graphify` skill into the workspace and installs a
**PreToolUse hook** that fires before search-style Bash calls and before reading
source files one-by-one, nudging toward `graphify query`. This is the native
integration — the forge-setup installer runs it for you. The Forge `/forge-map`
command is a convenience wrapper around `graphify .`.

## When NOT to reach for it

- A brand-new empty repo (nothing to map yet).
- A one-file, fully-in-context change where grep would be instant anyway.
- Throwaway scripts. The graph earns its keep on real, multi-module codebases —
  exactly the SPYCE PROJECT repos (SPYCE, Deployr, Aether, OneGo, Relayr).

## Privacy note

`graphify query`/`path`/`explain` and MCP `query_graph` calls log
timestamp+question (not full responses) to `~/.cache/graphify-queries.log`. Set
`GRAPHIFY_QUERY_LOG_DISABLE=1` to opt out.
