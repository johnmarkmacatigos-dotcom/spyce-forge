# Video production — the AI-native pipeline

From **digitalsamba/claude-code-video-toolkit**: an AI-native video production
workspace for Claude Code. Use when the user wants to turn work, a concept, or a
script into a watchable video — a demo reel, a sprint-review clip, an explainer,
a product walkthrough.

## The pipeline: NARRATE -> SCORE -> GENERATE -> COMPOSE -> RENDER

The toolkit's banner names the five stages, and they're a clean mental model for
*any* AI video, with or without this specific repo:

1. **NARRATE** — turn a script into voiceover. The toolkit leans on open-source
   TTS (e.g. Qwen3-TTS) so you own the voice track and run it at cost.
2. **SCORE** — add music. Open-source music generation (e.g. ACE-Step) produces
   a backing track to length.
3. **GENERATE** — create visuals: images/B-roll via open-source image models
   (e.g. FLUX.2), plus screen capture (the repo bundles a `playwright/` dir to
   drive the browser for recordings — see `browser-automation.md`).
4. **COMPOSE** — assemble narration, score, and visuals on a timeline
   (moviepy-style programmatic editing).
5. **RENDER** — produce the final MP4. The `examples/hello-world` renders an MP4
   with no API keys at all, which is the fastest way to confirm the chain works.

## Setup

```bash
git clone https://github.com/digitalsamba/claude-code-video-toolkit.git
cd claude-code-video-toolkit
python3 -m pip install -r tools/requirements.txt   # optional AI tools
claude                                             # open Claude Code here
```

Then inside the agent:
- `/setup` — interactive (~5 min): configure cloud GPU provider, file transfer,
  and voice. Mostly free.
- `/video` — scaffold a project from a template and walk the whole workflow.

**Requirements:** Node.js 18+, Claude Code, Python 3.9+ for the AI tools, FFmpeg
optional. **Cost model:** open models run on your own cloud GPU (e.g. Modal's
free monthly compute) with object storage on a free-tier bucket (e.g.
Cloudflare R2). A few short videos a month land in the free tiers.

## The strategic point

The toolkit is the "studio" hands of the stack: it closes the loop from *built*
to *shown*. For a founder, that's the difference between shipping a feature and
shipping a feature *plus* the launch clip, the changelog video, and the demo —
on the same agent, in the same session. Treat it as the publishing end of the
pipeline: methodology builds it, browser automation verifies it, video shows it.

## How it composes

- **Browser automation** is the screen-capture source for GENERATE, and any data
  the agent gathered (scraped metrics, build results) is the raw material for the
  NARRATE script — bridge the two: turn the numbers into sentences first, then
  voice them. Also sanity-check that video is the right medium; sometimes the
  user really wants a one-page summary, and the cardinal rule says ask.
- **Context7** keeps the toolkit's own libraries (moviepy, the model SDKs)
  current — the repo even ships a `context7.json`.
- A **Ralph loop** or **swarm** can batch-render a series (e.g. one clip per
  feature) once the template and pipeline are dialed in.
