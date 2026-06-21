#!/usr/bin/env bash
# install-stack.sh — one-time, idempotent wiring for the SPYCE Forge stack.
# Bash fallback for macOS / Linux / Git Bash. Mirrors install-stack.ps1.
# Bundled MCP servers (Context7, Playwright, Porkbun) + methodology load with the
# plugin; this installs only external pieces. ECC and Ruflo full-init are NOT auto-run.
#
# Usage: ./install-stack.sh [--with-ecc] [--with-ruflo-full-init]
# Env:   FORGE_TOOLS_DIR overrides the clone location.
set -uo pipefail
TOOLS_DIR="${FORGE_TOOLS_DIR:-$HOME/spyce-forge-tools}"
WITH_ECC=0; WITH_RUFLO_FULL=0
for a in "$@"; do [[ "$a" == "--with-ecc" ]] && WITH_ECC=1; [[ "$a" == "--with-ruflo-full-init" ]] && WITH_RUFLO_FULL=1; done
c_cyan="\033[36m"; c_green="\033[32m"; c_grey="\033[90m"; c_yellow="\033[33m"; c_mag="\033[35m"; c_off="\033[0m"
step(){ printf "\n${c_cyan}[%s] %s${c_off}\n" "$1" "$2"; }
ok(){ printf "    ${c_green}OK  %s${c_off}\n" "$1"; }
skip(){ printf "    ${c_grey}--  %s${c_off}\n" "$1"; }
note(){ printf "    ${c_yellow}>>  %s${c_off}\n" "$1"; }
have(){ command -v "$1" >/dev/null 2>&1; }

printf "${c_mag}==================================================\n SPYCE Forge — stack installer\n==================================================${c_off}\n"

step 0 "Preflight"
have claude && ok "claude CLI found" || note "claude CLI not found — plugin steps skipped."
have git    && ok "git found"        || note "git not found — clone steps skipped."
have node   && ok "node found"        || note "node not found — bundled MCP servers need Node + npx."
mkdir -p "$TOOLS_DIR"; ok "Tools workspace: $TOOLS_DIR"

step 1 "Superpowers (methodology marketplace plugin)"
if have claude; then
  if claude /plugin marketplace add obra/superpowers-marketplace && claude /plugin install superpowers@superpowers-marketplace; then
    ok "superpowers installed (self-updates via its SessionStart hook)"
  else note "Run manually:  /plugin marketplace add obra/superpowers-marketplace ; /plugin install superpowers@superpowers-marketplace"; fi
else skip "skipped (no claude CLI)"; fi

step 2 "MCP sanity check (Context7 + Playwright + Porkbun ship with this plugin)"
ok "Bundled: context7, playwright (one canonical = no collision), porkbun (docs-only until keys set)"
note "Domain ops: set PORKBUN_API_KEY / PORKBUN_SECRET_API_KEY (a dedicated, spend-capped key) to unlock /forge-domain."
if have claude; then
  pw="$(claude mcp list 2>/dev/null | grep -ic playwright || true)"
  [[ "${pw:-0}" -gt 1 ]] && note "Multiple 'playwright' MCP entries — remove the duplicate." || ok "No Playwright collision detected"
else skip "skipped (no claude CLI)"; fi

step 3 "Graphify (codebase -> queryable knowledge graph)"
if ! have uv; then
  note "uv not found; installing..."
  curl -LsSf https://astral.sh/uv/install.sh | sh >/dev/null 2>&1 || note "uv install failed — https://astral.sh/uv"
  export PATH="$HOME/.local/bin:$PATH"
fi
if have uv; then
  if uv tool install graphifyy; then
    ok "graphifyy installed (CLI: graphify)"
    if have graphify; then graphify install && ok "Graphify skill + PreToolUse hook registered"; note "Per repo:  graphify .  then  graphify hook install"; fi
  else note "graphify install issue"; fi
else skip "skipped (no uv)"; fi

step 4 "Ruflo (the orchestrator = claude-flow v3)"
if have claude; then
  if claude /plugin marketplace add ruvnet/ruflo && claude /plugin install ruflo-core@ruflo; then
    ok "ruflo-core installed via plugin path (slash commands, ZERO workspace files)"
    note "Optional extras: ruflo-swarm@ruflo, ruflo-rag-memory@ruflo"
  else note "Run manually:  /plugin marketplace add ruvnet/ruflo ; /plugin install ruflo-core@ruflo"; fi
else skip "plugin path skipped (no claude CLI)"; fi
if [[ "$WITH_RUFLO_FULL" -eq 1 ]]; then
  note "FULL INIT is INVASIVE (writes CLAUDE.md, .claude/, settings, hooks, a daemon)."
  note "Run inside the target repo only:  npx ruflo@latest init wizard"
else skip "full 'npx ruflo init' NOT run (invasive). Re-run with --with-ruflo-full-init to print it."; fi

step 5 "Video toolkit"
if have git; then
  if [[ -d "$TOOLS_DIR/claude-code-video-toolkit" ]]; then skip "already present"; else
    git clone --depth 1 https://github.com/digitalsamba/claude-code-video-toolkit.git "$TOOLS_DIR/claude-code-video-toolkit" && ok "cloned"; fi
else skip "skipped (no git)"; fi

step 6 "ECC (intentionally manual)"
if [[ "$WITH_ECC" -eq 1 ]]; then
  note "Review before running:  git clone https://github.com/affaan-m/ECC.git \"$TOOLS_DIR/ECC\""
else skip "not installed. Re-run with --with-ecc to print the manual clone command."; fi

printf "\n${c_mag}==================================================${c_off}\n"
printf "${c_green} Done. Restart your Claude Code session. Loadout: ONE brain${c_off}\n"
printf "${c_green} (Forge + superpowers) + Graphify; Ruflo per job; Porkbun keys for /forge-domain.${c_off}\n"
printf "${c_mag}==================================================${c_off}\n"
