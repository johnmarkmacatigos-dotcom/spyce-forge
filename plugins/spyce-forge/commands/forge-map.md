---
description: Map the codebase into a queryable knowledge graph before designing
argument-hint: [path, default .]
allowed-tools: Bash, Read
---

Ground in the *internal* codebase before specing — the internal counterpart to
`/forge-ground` (which handles external libraries).

Build or refresh the project knowledge graph with Graphify:

- Windows / PowerShell (note: no leading slash):
  `graphify ${ARGUMENTS:-.}`
- Then query instead of grepping:
  `graphify query "<your question about the code>"`

This produces `graphify-out/graph.html`, `GRAPH_REPORT.md`, and `graph.json`.
Read `GRAPH_REPORT.md` for the architecture overview and suggested questions,
then use scoped `graphify query` calls (cheaper than reading the whole report)
to answer "where does X live / what connects A to B / what breaks if I change
this" before writing any spec or code.

If `graphify` is not installed, run the `forge-setup` skill first. Code
extraction is local (tree-sitter, no API cost); only semantic queries use a
model. See `forge-operating-model/references/grounding-codebase-graphify.md`.
