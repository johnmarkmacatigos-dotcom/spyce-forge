#!/usr/bin/env bash
# domain.sh — safe Porkbun domain acquisition + DNS (Forge fallback for the MCP).
# Verified against Porkbun API v3.6. Reads PORKBUN_API_KEY / PORKBUN_SECRET_API_KEY
# from env (never pass keys as args). register always checks + dry-runs first and
# only charges with --confirm. Requires: curl, jq.
#
# Usage:
#   ./domain.sh check stacklore.dev
#   ./domain.sh requirements dev
#   ./domain.sh dryrun stacklore.dev
#   ./domain.sh register stacklore.dev --confirm
#   ./domain.sh dns-vercel stacklore.dev
set -uo pipefail
BASE="https://api.porkbun.com/api/json/v3"
ACTION="${1:-}"; TARGET="${2:-}"; CONFIRM=0; [[ "${3:-}" == "--confirm" ]] && CONFIRM=1
: "${PORKBUN_API_KEY:?Set PORKBUN_API_KEY}"; : "${PORKBUN_SECRET_API_KEY:?Set PORKBUN_SECRET_API_KEY}"
command -v jq >/dev/null || { echo "jq required"; exit 1; }
[[ -z "$ACTION" || -z "$TARGET" ]] && { echo "Usage: $0 <check|requirements|dryrun|register|dns-vercel> <target> [--confirm]"; exit 1; }

pb() { # pb <path> <json-extra-fields> [extra-curl-args...]
  local path="$1"; local extra="${2:-{\}}"; shift 2 || shift $#
  local body; body=$(jq -nc --arg ak "$PORKBUN_API_KEY" --arg sk "$PORKBUN_SECRET_API_KEY" --argjson ex "$extra" \
    '{apikey:$ak,secretapikey:$sk} + $ex')
  curl -sS -X POST "$BASE$path" -H 'Content-Type: application/json' "$@" -d "$body"
}

case "$ACTION" in
  check) pb "/domain/checkDomain/$TARGET" | jq . ;;
  requirements)
    curl -sS "$BASE/domain/getRegistrationRequirements/$TARGET" \
      -H "X-API-Key: $PORKBUN_API_KEY" -H "X-Secret-API-Key: $PORKBUN_SECRET_API_KEY" | jq . ;;
  dryrun)
    chk=$(pb "/domain/checkDomain/$TARGET")
    price=$(echo "$chk" | jq -r '.response.price'); cents=$(printf '%.0f' "$(echo "$price*100" | bc -l)")
    echo "Quote: \$$price USD ($cents cents). avail=$(echo "$chk" | jq -r '.response.avail')"
    pb "/domain/create/$TARGET" "{\"cost\":$cents,\"agreeToTerms\":\"yes\",\"dryRun\":true}" | jq . ;;
  register)
    chk=$(pb "/domain/checkDomain/$TARGET")
    avail=$(echo "$chk" | jq -r '.response.avail')
    [[ "$avail" != "yes" ]] && { echo "$TARGET not available (avail=$avail). Aborting."; exit 2; }
    price=$(echo "$chk" | jq -r '.response.price'); cents=$(printf '%.0f' "$(echo "$price*100" | bc -l)")
    dry=$(pb "/domain/create/$TARGET" "{\"cost\":$cents,\"agreeToTerms\":\"yes\",\"dryRun\":true}")
    echo "Dry-run: wouldSucceed=$(echo "$dry" | jq -r '.wouldSucceed') cost=$(echo "$dry" | jq -r '.costDisplay') balance=$(echo "$dry" | jq -r '.balance')"
    [[ "$(echo "$dry" | jq -r '.wouldSucceed')" != "true" ]] && { echo "Dry-run would NOT succeed. Aborting."; exit 3; }
    if [[ "$CONFIRM" -ne 1 ]]; then
      echo "READY to register $TARGET for \$$price USD. This SPENDS MONEY."
      echo "Re-run with --confirm to actually purchase."; exit 0
    fi
    idem=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || uuidgen)
    pb "/domain/create/$TARGET" "{\"cost\":$cents,\"agreeToTerms\":\"yes\"}" -H "Idempotency-Key: $idem" | jq .
    echo "(idempotency-key: $idem)" ;;
  dns-vercel)
    echo "Adding Vercel DNS records to $TARGET (confirm targets in Vercel dashboard)..."
    pb "/dns/create/$TARGET" '{"name":"","type":"A","content":"76.76.21.21","ttl":"600"}' | jq .
    pb "/dns/create/$TARGET" '{"name":"www","type":"CNAME","content":"cname.vercel-dns.com","ttl":"600"}' | jq .
    echo "Now add $TARGET in your Vercel project so it issues the TLS cert." ;;
  *) echo "Unknown action: $ACTION"; exit 1 ;;
esac
