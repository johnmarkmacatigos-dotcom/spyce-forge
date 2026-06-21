---
description: Pull current, version-specific docs before coding against a library
argument-hint: [library or API]
allowed-tools: Read, Bash
---

Before writing any code that touches: $ARGUMENTS

Use the Context7 MCP server to fetch current, version-specific documentation for
the exact library/version in this project (check the lockfile/manifest for the
version). Summarize the parts that affect the task — the real signatures,
breaking changes, and gotchas — then proceed. See
`forge-operating-model/references/grounding-context7.md`. Never rely on
remembered APIs when live docs are one call away.
