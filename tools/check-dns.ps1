<#
.SYNOPSIS
  Checks that DNS and GitHub Pages are wired up for www.tacomaphoto.club.

.DESCRIPTION
  Verifies, against the authoritative Squarespace nameservers (so results are
  never masked by resolver caching):

    * the four GitHub Pages A records on the apex
    * the four GitHub Pages AAAA records on the apex
    * the www CNAME pointing at the Pages host
    * the GitHub Pages custom domain and HTTPS enforcement
    * that both hostnames actually serve the site over HTTPS

.EXAMPLE
  pwsh tools/check-dns.ps1
#>
[CmdletBinding()]
param(
  [string]$Domain    = 'tacomaphoto.club',
  [string]$PagesHost = 't-walker.github.io',
  [string]$Repo      = 't-walker/tacoma-photo-club'
)

$ErrorActionPreference = 'Continue'

$ExpectedA    = @('185.199.108.153', '185.199.109.153', '185.199.110.153', '185.199.111.153')
$ExpectedAAAA = @('2606:50c0:8000::153', '2606:50c0:8001::153', '2606:50c0:8002::153', '2606:50c0:8003::153')

$script:Failures = 0

function Write-Check {
  param([bool]$Ok, [string]$Label, [string]$Detail)
  if ($Ok) {
    Write-Host '  PASS ' -ForegroundColor Green -NoNewline
  } else {
    Write-Host '  FAIL ' -ForegroundColor Red -NoNewline
    $script:Failures++
  }
  Write-Host ("{0,-34} {1}" -f $Label, $Detail)
}

# Resolve against the authoritative nameservers rather than a caching resolver,
# so a freshly-added record shows up immediately instead of after the TTL.
function Get-AuthoritativeNs {
  param([string]$Zone)
  try {
    (Resolve-DnsName $Zone -Type NS -Server 1.1.1.1 -ErrorAction Stop |
      Where-Object Type -eq 'NS' | Select-Object -First 1).NameHost
  } catch { $null }
}

function Resolve-Auth {
  param([string]$Name, [string]$Type, [string]$Server)
  try {
    $args = @{ Name = $Name; Type = $Type; ErrorAction = 'Stop'; DnsOnly = $true }
    if ($Server) { $args.Server = $Server }
    Resolve-DnsName @args | Where-Object Type -eq $Type
  } catch { @() }
}

Write-Host "`nDNS + Pages check for $Domain" -ForegroundColor Cyan

$ns = Get-AuthoritativeNs -Zone $Domain
Write-Check ([bool]$ns) 'nameserver delegation' ($ns ?? 'could not determine NS')
if (-not $ns) {
  Write-Host "`nThe domain is not delegated yet - nothing else can be checked.`n" -ForegroundColor Yellow
  exit 1
}
Write-Host "  (querying $ns directly, bypassing resolver cache)`n" -ForegroundColor DarkGray

# --- apex A / AAAA ---------------------------------------------------------
$a = (Resolve-Auth -Name $Domain -Type A -Server $ns).IPAddress | Sort-Object
$missingA = $ExpectedA | Where-Object { $_ -notin $a }
Write-Check ($missingA.Count -eq 0) "A    $Domain" $(
  if ($a) { "$($a.Count)/4 -> $($a -join ', ')" } else { 'none found' })
if ($missingA) { Write-Host "       missing: $($missingA -join ', ')" -ForegroundColor DarkYellow }

$aaaa = (Resolve-Auth -Name $Domain -Type AAAA -Server $ns).IPAddress | Sort-Object
$missingAAAA = $ExpectedAAAA | Where-Object { $_ -notin $aaaa }
Write-Check ($missingAAAA.Count -eq 0) "AAAA $Domain" $(
  if ($aaaa) { "$($aaaa.Count)/4" } else { 'none found (optional but recommended)' })

# --- www CNAME -------------------------------------------------------------
$cname = (Resolve-Auth -Name "www.$Domain" -Type CNAME -Server $ns).NameHost
$cnameOk = $cname -and ($cname.TrimEnd('.') -ieq $PagesHost)
Write-Check $cnameOk "CNAME www.$Domain" $(
  if ($cname) { "-> $cname" } else { 'none found' })

# --- GitHub Pages ----------------------------------------------------------
Write-Host ''
$pages = $null
try { $pages = gh api "repos/$Repo/pages" 2>$null | ConvertFrom-Json } catch { }

if ($pages) {
  Write-Check ($pages.cname -ieq "www.$Domain") 'Pages custom domain' ($pages.cname ?? '(none)')
  Write-Check ([bool]$pages.https_enforced) 'Pages enforce HTTPS' $pages.https_enforced
} else {
  Write-Check $false 'GitHub Pages API' 'could not read (is gh authenticated?)'
}

# --- live HTTPS ------------------------------------------------------------
Write-Host ''
foreach ($url in @("https://www.$Domain/", "https://$Domain/")) {
  try {
    $r = Invoke-WebRequest $url -MaximumRedirection 5 -TimeoutSec 15 -ErrorAction Stop
    Write-Check ($r.StatusCode -eq 200) "GET $url" "HTTP $($r.StatusCode)"
  } catch {
    Write-Check $false "GET $url" $_.Exception.Message.Split("`n")[0]
  }
}

Write-Host ''
if ($script:Failures -eq 0) {
  Write-Host "All checks passed - the site is live at https://www.$Domain/`n" -ForegroundColor Green
  exit 0
}
Write-Host "$script:Failures check(s) failed. DNS changes can take up to ~30 min to propagate.`n" -ForegroundColor Yellow
exit 1
