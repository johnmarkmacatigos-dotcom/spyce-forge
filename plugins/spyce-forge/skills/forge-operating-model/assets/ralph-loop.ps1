<#
.SYNOPSIS
  ralph-loop.ps1 — a portable autonomous "Ralph" loop for Windows / PowerShell.

.DESCRIPTION
  Each iteration is a FRESH agent instance with clean context. Memory lives in
  git history, progress.txt, and prd.json. See ../references/autonomy-loop.md.

  The per-iteration prompt (prompt.md) must instruct the agent to:
    1. pick the highest-priority story where passes == false
    2. implement ONLY that story
    3. run qualityChecks; commit ONLY if green
    4. set passes == true in prd.json
    5. append learnings to progress.txt and update AGENTS.md / CLAUDE.md

.PARAMETER MaxIterations
  Maximum number of iterations. Default 10.

.EXAMPLE
  .\ralph-loop.ps1 20

.NOTES
  Requires: a coding CLI (default `claude`) and the PowerShell 7+ host.
  Override the CLI with $env:AGENT_CLI, the prompt with $env:PROMPT_FILE,
  and the PRD with $env:PRD_FILE.
#>

[CmdletBinding()]
param(
  [int]$MaxIterations = 10
)

$ErrorActionPreference = 'Stop'

$PromptFile = if ($env:PROMPT_FILE) { $env:PROMPT_FILE } else { 'prompt.md' }
$PrdFile    = if ($env:PRD_FILE)    { $env:PRD_FILE }    else { 'prd.json' }
$AgentCli   = if ($env:AGENT_CLI)   { $env:AGENT_CLI }   else { 'claude' }

function Get-Remaining {
  # Count stories still failing, using native JSON parsing (no jq dependency).
  $prd = Get-Content -Raw -Path $PrdFile | ConvertFrom-Json
  return @($prd.stories | Where-Object { $_.passes -eq $false }).Count
}

if (-not (Test-Path $PrdFile)) {
  Write-Error "No $PrdFile found. Create one (see prd.json.example) first."
  exit 1
}

for ($i = 1; $i -le $MaxIterations; $i++) {
  $left = Get-Remaining
  Write-Host "=== Iteration $i/$MaxIterations — $left stories remaining ===" -ForegroundColor Cyan

  if ($left -eq 0) {
    Write-Host "All stories pass. Done." -ForegroundColor Green
    exit 0
  }

  # Spawn a fresh instance with the per-iteration prompt.
  try {
    & $AgentCli -p (Get-Content -Raw -Path $PromptFile)
  }
  catch {
    Write-Warning "Iteration $i failed; learnings should be in progress.txt. Continuing."
  }
}

$still = Get-Remaining
Write-Warning "Hit max iterations ($MaxIterations). $still stories still failing."
exit 1
