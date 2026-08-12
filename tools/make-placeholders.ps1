# Generates placeholder JPEGs so the site has something to render before real
# photos and event fliers are dropped in. Safe to re-run; overwrites by name.
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$heroDir = Join-Path $root 'src\images\hero'
$eventDir = Join-Path $root 'src\images\events'
New-Item -ItemType Directory -Force -Path $heroDir, $eventDir | Out-Null

function New-Placeholder {
    param(
        [string]$Path,
        [int]$Width,
        [int]$Height,
        [string]$Label,
        [string]$Back,
        [string]$Fore
    )
    $bmp = New-Object System.Drawing.Bitmap $Width, $Height
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = 'AntiAlias'
    $g.TextRenderingHint = 'AntiAliasGridFit'
    $g.Clear([System.Drawing.ColorTranslator]::FromHtml($Back))

    $pen = New-Object System.Drawing.Pen ([System.Drawing.ColorTranslator]::FromHtml($Fore)), ([single]($Width / 90))
    $inset = [int]($Width / 22)
    $g.DrawRectangle($pen, $inset, $inset, $Width - (2 * $inset), $Height - (2 * $inset))

    $brush = New-Object System.Drawing.SolidBrush ([System.Drawing.ColorTranslator]::FromHtml($Fore))
    $font = New-Object System.Drawing.Font 'Arial', ([single]($Width / 16)), ([System.Drawing.FontStyle]::Bold)
    $fmt = New-Object System.Drawing.StringFormat
    $fmt.Alignment = 'Center'
    $fmt.LineAlignment = 'Center'
    $rect = New-Object System.Drawing.RectangleF 0, 0, $Width, $Height
    $g.DrawString($Label, $font, $brush, $rect, $fmt)

    $g.Dispose()
    $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    $bmp.Dispose()
    Write-Host "wrote $Path"
}

$palette = @(
    @{ back = '#e8a33d'; fore = '#2b1a10' },
    @{ back = '#c8501e'; fore = '#f5efe0' },
    @{ back = '#3f6b57'; fore = '#f5efe0' },
    @{ back = '#2f4d6e'; fore = '#f5efe0' },
    @{ back = '#8c2f39'; fore = '#f5efe0' },
    @{ back = '#d9c27e'; fore = '#2b1a10' }
)

for ($i = 1; $i -le 4; $i++) {
    $p = $palette[($i - 1) % $palette.Count]
    New-Placeholder -Path (Join-Path $heroDir ("hero-0$i.jpg")) -Width 1600 -Height 1000 `
        -Label "HERO 0$i" -Back $p.back -Fore $p.fore
}

$events = @('darkroom-night', 'point-defiance-walk', 'film-swap', 'print-critique', 'sound-long-exposure')
for ($i = 0; $i -lt $events.Count; $i++) {
    $p = $palette[($i + 2) % $palette.Count]
    New-Placeholder -Path (Join-Path $eventDir ($events[$i] + '.jpg')) -Width 1080 -Height 1350 `
        -Label $events[$i] -Back $p.back -Fore $p.fore
}
