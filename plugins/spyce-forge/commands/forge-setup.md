---
description: Run the one-time installer that wires up the external stack pieces
allowed-tools: Bash, Read
---

Engage the `forge-setup` skill and run the bundled installer.

Windows / PowerShell (primary):
`pwsh -File "${CLAUDE_PLUGIN_ROOT}/skills/forge-setup/scripts/install-stack.ps1"`

macOS / Linux / Git Bash:
`bash "${CLAUDE_PLUGIN_ROOT}/skills/forge-setup/scripts/install-stack.sh"`

The Context7 + Playwright MCP servers already ship with this plugin and are live
on install — do not add a second Playwright server. The installer is idempotent
and non-destructive; ECC is left manual by design.
