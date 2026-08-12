# Derives the site's brand assets from the club logo pack.
#   .\tools\make-brand-assets.ps1 -SourceDir C:\path\to\PNGS
# Writes the footer lockup into src/images/brand/ and the favicons plus the
# social share card into public/.
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDir
)

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$brandDir = Join-Path $root 'src\images\brand'
$publicDir = Join-Path $root 'public'
New-Item -ItemType Directory -Force -Path $brandDir, $publicDir | Out-Null

$fullLogo = Join-Path $SourceDir 'TPC_Full-2-Color_Logo_2024.png'
$monogram = Join-Path $SourceDir 'TPC_Monogram-Navy_Logo_2024.png'
foreach ($p in @($fullLogo, $monogram)) {
    if (-not (Test-Path $p)) { throw "Missing source logo: $p" }
}

Copy-Item $fullLogo (Join-Path $brandDir 'tpc-logo-full.png') -Force
Write-Host "wrote src/images/brand/tpc-logo-full.png"

function Save-Resized {
    param([string]$Source, [string]$Destination, [int]$Size)

    $src = New-Object System.Drawing.Bitmap $Source
    $out = New-Object System.Drawing.Bitmap $Size, $Size
    $g = [System.Drawing.Graphics]::FromImage($out)
    $g.InterpolationMode = 'HighQualityBicubic'
    $g.SmoothingMode = 'AntiAlias'
    $g.PixelOffsetMode = 'HighQuality'
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($src, 0, 0, $Size, $Size)
    $g.Dispose()
    $out.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
    $out.Dispose()
    $src.Dispose()
    Write-Host "wrote $Destination"
}

Save-Resized -Source $monogram -Destination (Join-Path $publicDir 'icon-32.png') -Size 32
Save-Resized -Source $monogram -Destination (Join-Path $publicDir 'icon-180.png') -Size 180
Save-Resized -Source $monogram -Destination (Join-Path $publicDir 'icon-512.png') -Size 512

# Social share card: the lockup centred on the site's paper stock.
$cardWidth = 1200
$cardHeight = 630
$card = New-Object System.Drawing.Bitmap $cardWidth, $cardHeight
$g = [System.Drawing.Graphics]::FromImage($card)
$g.InterpolationMode = 'HighQualityBicubic'
$g.SmoothingMode = 'AntiAlias'
$g.PixelOffsetMode = 'HighQuality'
$g.Clear([System.Drawing.ColorTranslator]::FromHtml('#F2EFEA'))

$logo = New-Object System.Drawing.Bitmap $fullLogo
$targetWidth = [int]($cardWidth * 0.62)
$targetHeight = [int]($targetWidth * $logo.Height / $logo.Width)
$g.DrawImage(
    $logo,
    [int](($cardWidth - $targetWidth) / 2),
    [int](($cardHeight - $targetHeight) / 2),
    $targetWidth,
    $targetHeight
)
$logo.Dispose()

# Coral rules top and bottom, echoing the print-ad framing.
$coral = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml('#FF6940'))
$g.FillRectangle($coral, 0, 0, $cardWidth, 10)
$g.FillRectangle($coral, 0, $cardHeight - 10, $cardWidth, 10)
$g.Dispose()

$card.Save((Join-Path $publicDir 'og-image.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$card.Dispose()
Write-Host "wrote public/og-image.png"
