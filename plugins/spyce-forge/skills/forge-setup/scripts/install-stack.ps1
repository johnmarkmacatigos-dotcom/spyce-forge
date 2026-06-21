<#
.SYNOPSIS
  install-stack.ps1 — one-time, idempotent wiring for the SPYCE Forge stack.

.DESCRIPTION
  Bundled MCP servers (Context7, Playwright, Porkbun) and the methodology load
  with the plugin itself, so this script installs only genuinely external pieces:
  superpowers, Graphify (codebase grounding), Ruflo (the orchestrator, safe plugin
  path by default), and the video toolkit. ECC and Ruflo's full invasive init are
  NOT auto-run. Nothing here is destructive.

.PARAMETER ToolsDir
  Where to clone external tool repos. Default: $HOME/spyce-forge-tools.
.PARAMETER WithEcc
  Opt in to printing ECC's manual clone command (still not auto-run).
.PARAMETER WithRufloFullInit
  Opt in to printing Ruflo's invasive full-init command (still not auto-run).
.EXAMPLE
  pwsh -File install-stack.ps1
#>
[CmdletBinding()]
param(
  [string]$ToolsDir = $(if ($env:FORGE_TOOLS_DIR) { $env:FORGE_TOOLS_DIR } else { Join-Path $HOME 'spyce-forge-tools' }),
  [switch]$WithEcc,
  [switch]$WithRufloFullInit
)
$ErrorActionPreference = 'Stop'
function Write-Step { param($n, $msg) Write-Host "`n[$n] $msg" -ForegroundColor Cyan }
function Write-Ok   { param($msg) Write-Host "    OK  $msg" -ForegroundColor Green }
function Write-Skip { param($msg) Write-Host "    --  $msg" -ForegroundColor DarkGray }
function Write-Note { param($msg) Write-Host "    >>  $msg" -ForegroundColor Yellow }
function Test-Cmd { param($name) [bool](Get-Command $name -ErrorAction SilentlyContinue) }

Write-Host "==================================================" -ForegroundColor Magenta
Write-Host " SPYCE Forge — stack installer" -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta

Write-Step 0 "Preflight"
$haveClaude = Test-Cmd 'claude'; $haveGit = Test-Cmd 'git'; $haveNode = Test-Cmd 'node'; $haveUv = Test-Cmd 'uv'
if ($haveClaude) { Write-Ok "claude CLI found" } else { Write-Note "claude CLI not found — plugin steps skipped." }
if ($haveGit)    { Write-Ok "git found" }        else { Write-Note "git not found — clone steps skipped." }
if ($haveNode)   { Write-Ok "node found (npx-backed MCP servers ready)" } else { Write-Note "node not found — bundled MCP servers need Node + npx." }
New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
Write-Ok "Tools workspace: $ToolsDir"

Write-Step 1 "Superpowers (methodology marketplace plugin)"
if ($haveClaude) {
  try {
    & claude /plugin marketplace add obra/superpowers-marketplace
    & claude /plugin install superpowers@superpowers-marketplace
    Write-Ok "superpowers installed (self-updates via its SessionStart hook)"
  } catch {
    Write-Note "Run manually:  /plugin marketplace add obra/superpowers-marketplace ; /plugin install superpowers@superpowers-marketplace"
  }
} else { Write-Skip "skipped (no claude CLI)" }

Write-Step 2 "MCP sanity check (Context7 + Playwright + Porkbun ship with this plugin)"
Write-Ok "Bundled servers: context7, playwright (one canonical = no collision), porkbun (docs-only until keys set)"
Write-Note "Domain ops: set PORKBUN_API_KEY / PORKBUN_SECRET_API_KEY (a dedicated, spend-capped key) to unlock live registration/DNS."
if ($haveClaude) {
  try {
    $mcp = (& claude mcp list 2>$null) | Out-String
    if (([regex]::Matches($mcp, 'playwright')).Count -gt 1) { Write-Note "Multiple 'playwright' MCP entries — remove the duplicate." } else { Write-Ok "No Playwright collision detected" }
  } catch { Write-Skip "could not query 'claude mcp list' (non-fatal)" }
} else { Write-Skip "skipped (no claude CLI)" }

Write-Step 3 "Graphify (codebase -> queryable knowledge graph)"
if (-not $haveUv) {
  if (Test-Cmd 'winget') {
    Write-Note "uv not found; installing via winget..."
    try { & winget install --silent --accept-package-agreements --accept-source-agreements astral-sh.uv; $haveUv = Test-Cmd 'uv' } catch { Write-Note "winget install of uv failed: $($_.Exception.Message)" }
  } else { Write-Note "uv not found and winget unavailable. Install uv, then re-run. https://astral.sh/uv" }
}
if ($haveUv) {
  try {
    & uv tool install graphifyy
    Write-Ok "graphifyy installed (CLI: graphify)"
    if (Test-Cmd 'graphify') {
      & graphify install
      Write-Ok "Graphify skill + PreToolUse hook registered for Claude Code"
      Write-Note "Per repo:  graphify .  (build graph)  and  graphify hook install  (auto-rebuild on commit)"
      Write-Note "PowerShell reminder: 'graphify .'  — NOT '/graphify .' (slash is a path separator)."
    }
  } catch { Write-Note "graphify install issue: $($_.Exception.Message)" }
} else { Write-Skip "skipped (no uv)" }

Write-Step 4 "Ruflo (the orchestrator = claude-flow v3)"
if ($haveClaude) {
  try {
    & claude /plugin marketplace add ruvnet/ruflo
    & claude /plugin install ruflo-core@ruflo
    Write-Ok "ruflo-core installed via plugin path (slash commands, ZERO workspace files)"
    Write-Note "Optional extras: ruflo-swarm@ruflo, ruflo-rag-memory@ruflo"
  } catch { Write-Note "Run manually:  /plugin marketplace add ruvnet/ruflo ; /plugin install ruflo-core@ruflo" }
} else { Write-Skip "plugin path skipped (no claude CLI)" }
if ($WithRufloFullInit) {
  Write-Note "FULL INIT is INVASIVE (writes CLAUDE.md, .claude/, settings, hooks, a daemon)."
  Write-Note "Run inside the target repo only:  npx ruflo@latest init wizard"
  Write-Note "Heed the hook-conflict rule before stacking on superpowers + Graphify."
} else { Write-Skip "full 'npx ruflo init' NOT run (invasive). Re-run with -WithRufloFullInit to print it." }

Write-Step 5 "Video toolkit (NARRATE -> SCORE -> GENERATE -> COMPOSE -> RENDER)"
if ($haveGit) {
  $videoDir = Join-Path $ToolsDir 'claude-code-video-toolkit'
  if (Test-Path $videoDir) { Write-Skip "already present at $videoDir" }
  else { git clone --depth 1 https://github.com/digitalsamba/claude-code-video-toolkit.git $videoDir; Write-Ok "cloned to $videoDir" }
} else { Write-Skip "skipped (no git)" }

Write-Step 6 "ECC (intentionally manual — ideas already folded into the methodology)"
if ($WithEcc) {
  Write-Note "ECC makes large claims; review before running. Manual clone:"
  Write-Note "  git clone https://github.com/affaan-m/ECC.git `"$ToolsDir/ECC`""
} else { Write-Skip "not installed. Re-run with -WithEcc to print the manual clone command." }

Write-Host "`n==================================================" -ForegroundColor Magenta
Write-Host " Done. Restart your Claude Code session to load everything." -ForegroundColor Green
Write-Host " Loadout: ONE brain (Forge + superpowers) + Graphify grounding;" -ForegroundColor Green
Write-Host " Ruflo per job; set Porkbun keys to enable /forge-domain." -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Magenta
