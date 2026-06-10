$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$pagePath = Join-Path $root "postofficesaathi/index.html"
$imagePath = Join-Path $root "postofficesaathi/preview.jpg"
$pageUrl = "https://ij-roy.github.io/postofficesaathi/"
$imageUrl = "https://ij-roy.github.io/postofficesaathi/preview.jpg?v=20260610-1"
$playStoreUrl = "https://play.google.com/store/apps/details?id=roy.ij.postofficesaathi"

function Assert-True {
  param(
    [bool] $Condition,
    [string] $Message
  )

  if (-not $Condition) {
    throw $Message
  }
}

function Assert-Contains {
  param(
    [string] $Content,
    [string] $Expected,
    [string] $Message
  )

  Assert-True -Condition $Content.Contains($Expected) -Message $Message
}

Assert-True -Condition (Test-Path -LiteralPath $pagePath) -Message "Missing postofficesaathi/index.html"
Assert-True -Condition (Test-Path -LiteralPath $imagePath) -Message "Missing postofficesaathi/preview.jpg"

$html = Get-Content -LiteralPath $pagePath -Raw

Assert-Contains -Content $html -Expected '<meta property="og:title" content="Post Office Saathi">' -Message "Missing og:title"
Assert-Contains -Content $html -Expected '<meta property="og:description" content="Simple Postal Utility App">' -Message "Missing og:description"
Assert-Contains -Content $html -Expected '<meta property="og:site_name" content="IJ Roy">' -Message "Missing og:site_name"
Assert-Contains -Content $html -Expected ('<meta property="og:url" content="' + $pageUrl + '">') -Message "Missing og:url"
Assert-Contains -Content $html -Expected ('<meta property="og:image" content="' + $imageUrl + '">') -Message "Missing og:image"
Assert-Contains -Content $html -Expected ('<meta property="og:image:url" content="' + $imageUrl + '">') -Message "Missing og:image:url"
Assert-Contains -Content $html -Expected '<meta property="og:image:width" content="1200">' -Message "Missing og:image:width"
Assert-Contains -Content $html -Expected '<meta property="og:image:height" content="631">' -Message "Missing og:image:height"
Assert-Contains -Content $html -Expected ('<link rel="canonical" href="' + $pageUrl + '">') -Message "Missing canonical page URL"
Assert-True -Condition (-not $html.Contains('http-equiv="refresh"')) -Message "Meta refresh redirect should not be used because link preview crawlers can treat it as the primary resource"
Assert-Contains -Content $html -Expected ('window.location.replace("' + $playStoreUrl + '");') -Message "Missing JavaScript redirect"
Assert-Contains -Content $html -Expected ('href="' + $playStoreUrl + '"') -Message "Missing fallback Play Store link"

Add-Type -AssemblyName System.Drawing
$image = [System.Drawing.Image]::FromFile($imagePath)
try {
  Assert-True -Condition ($image.Width -eq 1200) -Message "preview.jpg width must be 1200"
  Assert-True -Condition ($image.Height -eq 631) -Message "preview.jpg height must be 631"
}
finally {
  $image.Dispose()
}

Write-Output "postofficesaathi page checks passed"
