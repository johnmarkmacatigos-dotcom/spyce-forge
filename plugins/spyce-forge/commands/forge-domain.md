---
description: Find, secure, and stand up a domain via the Porkbun MCP (safe flow)
argument-hint: [domain or brand idea]
allowed-tools: Bash, Read
---

Acquire a domain for: $ARGUMENTS — using the `forge-domain` skill and the bundled
Porkbun MCP (or `skills/forge-domain/scripts/domain.ps1` as a fallback).

Run the safe, agent-designed flow — never skip a step, never spend silently:

1. Do a quick naming pass: confirm the target plus 4–6 brandable alternates
   across sensible TLDs (note `.dev`/`.app` require HTTPS — fine on Vercel).
2. Check availability + real-time price for the shortlist.
3. Confirm the TLD's `apiRegisterable` is true (else it's website-only).
4. **Dry-run** the create — proceed only if `wouldSucceed` is true.
5. Surface the domain, exact cost, and balance, and get an explicit human "yes"
   before the real, idempotent registration. `agreeToTerms` must be "yes".
6. After purchase, point DNS at the hosting target (Vercel A `76.76.21.21` +
   CNAME `cname.vercel-dns.com`, or set Vercel nameservers) and add it in Vercel.

Requires `PORKBUN_API_KEY` / `PORKBUN_SECRET_API_KEY` (a dedicated, restricted
key with a monthly spend cap). See
`forge-domain/references/porkbun-domain-flow.md`.
