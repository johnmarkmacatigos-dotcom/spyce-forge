<#
.SYNOPSIS
  domain.ps1 — safe Porkbun domain acquisition + DNS (Forge fallback for the MCP).

.DESCRIPTION
  Verified against Porkbun API v3.6. Reads PORKBUN_API_KEY / PORKBUN_SECRET_API_KEY
  from the environment (never pass keys on the command line). Registration is
  guarded: it always checks availability and runs a dry-run first, and only
  charges when you pass -Confirm.

.EXAMPLE
  .\domain.ps1 check stacklore.dev
  .\domain.ps1 dryrun stacklore.dev
  .\domain.ps1 register stacklore.dev -Confirm
  .\domain.ps1 dns-vercel stacklore.dev
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory)][ValidateSet('check','requirements','dryrun','register','dns-vercel')]
  [string]$Action,
  [Parameter(Mandatory)][string]$Target,
  [switch]$Confirm
)
$ErrorActionPreference = 'Stop'
$Base = 'https://api.porkbun.com/api/json/v3'
$ak = $env:PORKBUN_API_KEY; $sk = $env:PORKBUN_SECRET_API_KEY
if (-not $ak -or -not $sk) { Write-Error "Set PORKBUN_API_KEY and PORKBUN_SECRET_API_KEY env vars first."; exit 1 }

function Invoke-Pb {
  param($Path, $Body = @{}, $Headers = @{})
  $Body.apikey = $ak; $Body.secretapikey = $sk
  Invoke-RestMethod -Method Post -Uri "$Base$Path" -ContentType 'application/json' `
    -Headers $Headers -Body ($Body | ConvertTo-Json -Depth 6)
}

switch ($Action) {
  'check' {
    $r = Invoke-Pb "/domain/checkDomain/$Target"
    $r | ConvertTo-Json -Depth 6
  }
  'requirements' {
    # $Target is the TLD here (e.g. dev)
    $r = Invoke-RestMethod -Method Get -Uri "$Base/domain/getRegistrationRequirements/$Target" `
      -Headers @{ 'X-API-Key' = $ak; 'X-Secret-API-Key' = $sk }
    $r | ConvertTo-Json -Depth 6
  }
  'dryrun' {
    $c = Invoke-Pb "/domain/checkDomain/$Target"
    $price = [double]$c.response.price
    $cents = [int][math]::Round($price * 100)
    Write-Host "Quote: `$$price USD ($cents cents). avail=$($c.response.avail)" -ForegroundColor Cyan
    $r = Invoke-Pb "/domain/create/$Target" @{ cost = $cents; agreeToTerms = 'yes'; dryRun = $true }
    $r | ConvertTo-Json -Depth 6
  }
  'register' {
    $c = Invoke-Pb "/domain/checkDomain/$Target"
    if ($c.response.avail -ne 'yes') { Write-Error "$Target is not available (avail=$($c.response.avail)). Aborting."; exit 2 }
    $price = [double]$c.response.price; $cents = [int][math]::Round($price * 100)
    $dry = Invoke-Pb "/domain/create/$Target" @{ cost = $cents; agreeToTerms = 'yes'; dryRun = $true }
    Write-Host "Dry-run: wouldSucceed=$($dry.wouldSucceed) cost=$($dry.costDisplay) balance=$($dry.balance) sufficientFunds=$($dry.sufficientFunds)" -ForegroundColor Cyan
    if ("$($dry.wouldSucceed)" -ne 'True' -and "$($dry.wouldSucceed)" -ne 'true') { Write-Error "Dry-run says it would NOT succeed. Aborting."; exit 3 }
    if (-not $Confirm) {
      Write-Host "READY to register $Target for `$$price USD. This SPENDS MONEY." -ForegroundColor Yellow
      Write-Host "Re-run with -Confirm to actually purchase." -ForegroundColor Yellow
      exit 0
    }
    $idem = [guid]::NewGuid().ToString()
    $r = Invoke-Pb "/domain/create/$Target" @{ cost = $cents; agreeToTerms = 'yes' } @{ 'Idempotency-Key' = $idem }
    Write-Host "Registration result (idem $idem):" -ForegroundColor Green
    $r | ConvertTo-Json -Depth 6
  }
  'dns-vercel' {
    Write-Host "Adding Vercel DNS records to $Target (confirm targets in the Vercel dashboard)..." -ForegroundColor Cyan
    (Invoke-Pb "/dns/create/$Target" @{ name = '';    type = 'A';     content = '76.76.21.21';         ttl = '600' }) | ConvertTo-Json -Depth 4
    (Invoke-Pb "/dns/create/$Target" @{ name = 'www'; type = 'CNAME'; content = 'cname.vercel-dns.com'; ttl = '600' }) | ConvertTo-Json -Depth 4
    Write-Host "Now add $Target in your Vercel project so it issues the TLS cert." -ForegroundColor Green
  }
}
