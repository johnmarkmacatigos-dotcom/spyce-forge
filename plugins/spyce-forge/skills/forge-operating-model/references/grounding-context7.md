# Grounding — Context7

From **upstash/context7**: an MCP server that delivers **up-to-date,
version-specific documentation and real code examples** for libraries, pulled
from their actual sources. It exists to kill the single most common agent
failure mode: confidently writing code against an API that changed, was renamed,
or never existed.

## When to reach for it (more often than you think)

- You're using any third-party library, framework, or SDK — *especially* one
  that moves fast (web frameworks, AI SDKs, cloud clients, anything versioned).
- The API "feels" uncertain, or you notice yourself reconstructing a method
  signature from memory. That feeling is the trigger to verify, not guess.
- The user says "use the latest", pins a specific version, or hits an error that
  looks like an API mismatch.
- Any parallel/loop agent is writing integration code — ground each one so they
  don't independently hallucinate.

Rule of thumb: **your training data is a snapshot; production is HEAD.** When the
two might differ and it matters, pull the docs.

## How it works

Two MCP tools:
- `resolve-library-id` — turn a library name ("next.js", "supabase") into the
  Context7 ID it indexes.
- `get-library-docs` — fetch current docs/examples for that ID, optionally
  scoped to a topic and version.

In a coding agent you can also just add **"use context7"** to a prompt and the
server injects the relevant current docs into context before the model answers.

## Setup

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp@latest"]
    }
  }
}
```

(Also available as a remote/hosted MCP endpoint and via the Context7 platform; a
free tier covers typical use, with an API key for higher limits.)

## How it composes

- It's the **research-first** step (`methodology.md`) made concrete for external
  code. Spec/plan steps that touch a library should cite current docs, not
  remembered ones.
- Feed it to **every** swarm and loop agent that writes integration code. One
  hallucinated import, multiplied across parallel agents, is a bad afternoon.
- A repo can ship a `context7.json` so the library is itself indexed for others
  — the video toolkit does this, for example.

## The mental model

Treat Context7 as the team librarian. You don't memorize every library's current
API any more than a senior engineer does — you know *that you should look it up*
and you have a fast way to do so. The skill isn't recall; it's the reflex to
verify.
