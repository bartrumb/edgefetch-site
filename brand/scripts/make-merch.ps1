param([string]$Raven, [string]$Out)
# Builds EdgeFetch merch print files from a transparent raven PNG.
Add-Type -AssemblyName System.Drawing
$fontDir = Join-Path $PSScriptRoot '..\fonts'
$pfc = New-Object System.Drawing.Text.PrivateFontCollection
Get-ChildItem $fontDir *.ttf | ForEach-Object { $pfc.AddFontFile($_.FullName) }
function Fam($n) { $pfc.Families | Where-Object Name -eq $n | Select-Object -First 1 }
$fBold = Fam 'Schibsted Grotesk ExtraBold'; $fMed = Fam 'Schibsted Grotesk Medium'; $fMono = Fam 'IBM Plex Mono Medium'
function C($h) { [System.Drawing.ColorTranslator]::FromHtml($h) }
$white = C '#FFFFFF'; $cyan = C '#3FC6E0'; $amber = C '#F2A93B'; $fog = C '#9FB0C4'; $navy = C '#101C2C'
New-Item -ItemType Directory -Force $Out | Out-Null
$rbmp = [System.Drawing.Bitmap]::FromFile($Raven)

function New-Canvas($w, $h, $bg) {
  $b = New-Object System.Drawing.Bitmap $w, $h, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $b.SetResolution(300, 300)
  $g = [System.Drawing.Graphics]::FromImage($b)
  $g.SmoothingMode = 'HighQuality'; $g.InterpolationMode = 'HighQualityBicubic'; $g.PixelOffsetMode = 'HighQuality'; $g.TextRenderingHint = 'AntiAlias'
  if ($bg) { $g.Clear($bg) } else { $g.Clear([System.Drawing.Color]::Transparent) }
  return @($b, $g)
}
function Text-Centered($g, $text, $fam, $px, $color, $cx, $y, $tracking = 0) {
  $font = New-Object System.Drawing.Font $fam, $px, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
  $sf = New-Object System.Drawing.StringFormat; $sf.Alignment = 'Center'
  $g.DrawString($text, $font, (New-Object System.Drawing.SolidBrush $color), [float]$cx, [float]$y, $sf)
}
function Text-Left($g, $text, $fam, $px, $color, $x, $y) {
  $font = New-Object System.Drawing.Font $fam, $px, ([System.Drawing.FontStyle]::Regular), ([System.Drawing.GraphicsUnit]::Pixel)
  $g.DrawString($text, $font, (New-Object System.Drawing.SolidBrush $color), [float]$x, [float]$y)
}
function Draw-Raven($g, $x, $y, $w) { $h = [int]($rbmp.Height * $w / $rbmp.Width); $g.DrawImage($rbmp, (New-Object System.Drawing.Rectangle $x, $y, $w, $h)); return $h }

# 1. Tee front, for dark shirts: 4500 x 5400 (15 x 18 in at 300 dpi), transparent
$c = New-Canvas 4500 5400 $null; $b = $c[0]; $g = $c[1]
$rh = Draw-Raven $g 750 120 3000
Text-Centered $g 'EdgeFetch' $fBold 720 $white 2250 ($rh + 160)
Text-Centered $g 'polite by design' $fMono 240 $cyan 2250 ($rh + 1060)
$g.Dispose(); $b.Save((Join-Path $Out 'tee-front-dark.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

# 2. Tee back: the robots.txt joke, 4500 x 5400, transparent
$c = New-Canvas 4500 5400 $null; $b = $c[0]; $g = $c[1]
$lines = @(
  @('User-agent: EdgeFetch', $white),
  @('Allow: /', $white),
  @('', $white),
  @('# I read this file', $fog),
  @('# on every redirect.', $fog),
  @('# Then I fetch politely.', $fog)
)
$y = 900
foreach ($l in $lines) { Text-Left $g $l[0] $fMono 250 $l[1] 520 $y; $y += 360 }
$g.FillRectangle((New-Object System.Drawing.SolidBrush $cyan), 520, ($y + 200), 3460, 22)
Text-Left $g 'edgefetch.dev' $fBold 300 $cyan 520 ($y + 360)
$g.Dispose(); $b.Save((Join-Path $Out 'tee-back-dark.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

# 3. Mug wrap, 11 oz: 2700 x 1050, navy all round
$c = New-Canvas 2700 1050 $navy; $b = $c[0]; $g = $c[1]
$null = Draw-Raven $g 200 75 816
Text-Left $g 'EdgeFetch' $fBold 150 $white 1240 250
Text-Left $g 'User-agent: EdgeFetch' $fMono 64 $fog 1250 470
Text-Left $g 'Allow: /' $fMono 64 $fog 1250 560
Text-Left $g '# fetched politely, on hardware I own' $fMono 52 $cyan 1250 680
$g.Dispose(); $b.Save((Join-Path $Out 'mug-11oz-wrap.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

# 4. Round sticker, 3 in: 900 x 900, navy disc with amber rim
$c = New-Canvas 900 900 $null; $b = $c[0]; $g = $c[1]
$g.FillEllipse((New-Object System.Drawing.SolidBrush $amber), 0, 0, 900, 900)
$g.FillEllipse((New-Object System.Drawing.SolidBrush $navy), 18, 18, 864, 864)
$null = Draw-Raven $g 212 95 420
Text-Centered $g 'EdgeFetch' $fBold 92 $white 450 600
$g.Dispose(); $b.Save((Join-Path $Out 'sticker-3in-round.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

$rbmp.Dispose()
Get-ChildItem $Out | Select-Object Name, Length





