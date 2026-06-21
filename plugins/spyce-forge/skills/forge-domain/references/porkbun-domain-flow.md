# Porkbun domain flow — verified endpoints (API v3.6)

Base URL: `https://api.porkbun.com/api/json/v3`
Auth: headers `X-API-Key` / `X-Secret-API-Key`, **or** `apikey` / `secretapikey`
in the JSON body. All write endpoints are POST. Read endpoints accept GET.
Docs: <https://porkbun.com/llms/guides/register-a-domain> · official MCP:
`npx -y @porkbunllc/mcp-server`.

> Availability checks are rate-limited (~1 per 10s). Batch the shortlist with
> delays, or use the MCP's bulk path.

## 1. Check availability + price

```
POST /domain/checkDomain/{domain}
body: {"apikey":"pk1_…","secretapikey":"sk1_…"}
```
Returns availability and the **registration price in USD**. Carry the quote
forward — `/domain/create` wants `cost` in **integer US cents** and rejects a
mismatch.

## 2. Confirm the TLD is API-registerable

```
GET /domain/getRegistrationRequirements/{tld}
headers: X-API-Key, X-Secret-API-Key
```
Inspect `apiRegisterable`. If `false`, register on the website (registry
eligibility rules the API can't submit). If `true`, `requestSchema` is the JSON
Schema for the create body and `registrationDurationYears` is the fixed term.

## 3. Dry-run the create (charges nothing)

```
POST /domain/create/{domain}
body: {"apikey":"…","secretapikey":"…","cost":1200,"agreeToTerms":"yes","dryRun":true}
```
Runs availability + price-match + eligibility + funds + spend-cap checks without
charging, creating, or consuming create rate-limit budget. Returns
`wouldSucceed`, `cost`, `costDisplay`, `balance`, `sufficientFunds`, and
`withinMonthlySpendLimit`. **Only commit if `wouldSucceed` is true.**

## 4. Register for real (idempotent)

```
POST /domain/create/{domain}
headers: Idempotency-Key: <uuid>
body: {"apikey":"…","secretapikey":"…","cost":1200,"agreeToTerms":"yes"}
```
- `cost` — integer US cents, must equal the current quote from step 1.
- `agreeToTerms` — must be `"yes"`.
- `Idempotency-Key` — a retry within 24h replays the original result instead of
  registering/charging twice.
- Account email + phone must be verified before the first registration.

## 5. Verify ownership

```
GET /domain/get/{domain}
```

## 6. DNS — point at Vercel

Either set nameservers to Vercel:
```
POST /domain/updateNs/{domain}
body: {"apikey":"…","secretapikey":"…","ns":["ns1.vercel-dns.com","ns2.vercel-dns.com"]}
```
…or keep Porkbun DNS and add records (confirm current Vercel targets in the
dashboard; they can change):
```
POST /dns/create/{domain}
body: {"apikey":"…","secretapikey":"…","name":"","type":"A","content":"76.76.21.21","ttl":"600"}
POST /dns/create/{domain}
body: {"apikey":"…","secretapikey":"…","name":"www","type":"CNAME","content":"cname.vercel-dns.com","ttl":"600"}
```
Then add the domain in the Vercel project; Vercel issues the TLS cert
automatically (required for `.dev`/`.app`).

## Error codes worth branching on

`INVALID_DOMAIN`, `INSUFFICIENT_FUNDS`, `MONTHLY_SPEND_LIMIT_EXCEEDED`,
`DOMAIN_NOT_ALLOWED`, `IP_NOT_ALLOWED`.
