---
name: forge-domain
description: >
  Acquire and stand up a domain end-to-end using the power of the Forge stack.
  Use this skill when the user wants to "get a domain", "buy/register a domain",
  "check if a domain is available", "find a brandable domain", "point my domain
  at Vercel", "set up DNS", or names a specific domain to secure (e.g.
  stacklore.dev). It drives the official Porkbun MCP server (bundled in this
  plugin) through a safe, agent-designed flow — check availability + price,
  confirm the TLD is API-registerable, dry-run, then register idempotently with
  explicit human confirmation — and then wires DNS to the hosting target
  (Vercel for Deployr/Stacklore sites). Prefer this over ad-hoc registrar
  clicking whenever a domain needs to be found, secured, or connected.
metadata:
  version: "0.1.0"
---

# Forge Domain

Turn "I need a domain" into a repeatable capability. This skill takes a brand or
idea to a registered, DNS-configured, live domain — safely, because spending real
money is irreversible and must never be a silent side effect.

## Two ways to drive it (prefer the MCP)

1. **Porkbun MCP (preferred, bundled).** This plugin's `.mcp.json` registers the
   official `@porkbunllc/mcp-server`. With no keys set it runs in **docs-only
   mode** (safe). Set `PORKBUN_API_KEY` and `PORKBUN_SECRET_API_KEY` (use a
   dedicated, restricted key — see Guardrails) to unlock live availability,
   registration, and DNS tools. Write tools auto-attach an idempotency key.
2. **Fallback script.** For shells/CI without the MCP, use
   `scripts/domain.ps1` (Windows-primary) or `scripts/domain.sh`. Same flow via
   verified `api.porkbun.com/api/json/v3` endpoints.

## The naming pass (do this before checking)

- **Brandable > descriptive.** Short, sayable, spellable on first hear. Avoid
  hyphens and number/letter homophones.
- **TLD strategy.** `.com` is still the default trust signal. `.dev`, `.app`,
  `.io` read as technical/credible for tooling brands — note **`.dev` and `.app`
  are HSTS-preloaded, so they *require* HTTPS** (fine on Vercel, which issues
  certs automatically). Match the TLD to the audience.
- **Generate a shortlist** (the target + 4–6 alternates across TLDs) so a single
  "taken" answer doesn't stall the acquisition.

## The safe acquisition flow (never skip a step)

Full endpoint detail is in `references/porkbun-domain-flow.md`. The sequence:

1. **Check availability + price** for the shortlist. Carry the exact quote
   forward — `cost` later must match it.
2. **Confirm `apiRegisterable`** for the TLD. Some TLDs (`.us`, `.ca`, `.eu`,
   `.au`) have eligibility rules the API can't submit and are website-only.
3. **Dry-run the create** (`dryRun: true`). This runs every preflight —
   availability, price match, eligibility, funds, spend cap — and charges
   nothing. Only proceed if `wouldSucceed` is true.
4. **Confirm with the human, then register.** Registration spends money. Surface
   the domain, the exact cost, and the balance, and get an explicit "yes" before
   the real `create`. Send an `Idempotency-Key` so a retry never double-charges.
   `agreeToTerms` must be `"yes"`; the account email + phone must be verified
   before the first registration.
5. **Verify** the domain now belongs to the account.

## Stand it up (DNS → Vercel)

For a Deployr/Stacklore site on Vercel, after registration either:

- **Point nameservers** to Vercel (cleanest if Vercel manages DNS), or
- **Keep Porkbun DNS** and add records: an `A` record `@ → 76.76.21.21` and a
  `CNAME` `www → cname.vercel-dns.com` (confirm the current target in the Vercel
  dashboard, which can change). Then add the domain in the Vercel project and let
  it issue the certificate.

## Guardrails (set these once, they cap the blast radius)

- **Dedicated restricted key.** Create a Porkbun API key scoped to the domains
  and (if known) the egress IP the agent uses. A leaked key then only touches
  those domains from that IP.
- **Monthly spend cap + low-balance alert** on the API settings page. A create
  that would exceed the cap is blocked with `MONTHLY_SPEND_LIMIT_EXCEEDED`.
- **Never commit keys.** They live in `PORKBUN_API_KEY` /
  `PORKBUN_SECRET_API_KEY` env vars, never in version control.

## House rules

PowerShell-safe commands; secrets in env only; confirm before any spend; the
dry-run is the real availability/funds check — treat anything from this session
(which has no registrar credentials) as advisory, not authoritative.
