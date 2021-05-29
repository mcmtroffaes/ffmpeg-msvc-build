param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$triplet = "x64-windows",
    [string]$features = "core"
)

# get version from CONTROL

$control = Get-Content "$vcpkg\ports\ffmpeg\vcpkg.json" | ConvertFrom-Json
$ver = $control."version-string"
$pver = $control."port-version"
if(!$ver) { throw "could not find version-string from vcpkg.json" }
if(!$pver) { throw "could not find port-string from vcpkg.json" }
$version = $control."version-string", $control."port-version" -Join "-"
Write-Output "FFmpeg version $version"

# get license from copyright file

$copyright = `
  Get-Content "$vcpkg\installed\$triplet\share\ffmpeg\copyright" -First 2 -Encoding Ascii `
  | ForEach-Object { $_.Trim() }
if(!$copyright) { throw "could not find copyright file" }
Write-Output $copyright
if ($copyright[0] -Eq "GNU LESSER GENERAL PUBLIC LICENSE") {
  if ($copyright[1] -Eq "Version 2.1, February 1999") {
    $license = "lgpl21"
  }
  elseif ($copyright[1] -Eq "Version 3, 29 June 2007") {
    $license = "lgpl3"
  }
  else {
    throw "unknown LGPL version"
  }
}
elseif ($copyright[0] -Eq "GNU GENERAL PUBLIC LICENSE") {
  if ($copyright[1] -Eq "Version 2, June 1991") {
    $license = "gpl2"
  }
  elseif ($copyright[1] -Eq "Version 3, 29 June 2007") {
    $license = "gpl3"
  }
  else {
    throw "unknown GPL version"
  }
}
elseif ($copyright -Eq "License: nonfree and unredistributable") {
  $license = "nonfree"
}
else {
  throw "unknown license"
}

# export

$ffmpeg = "ffmpeg-$version-$license-$triplet"
Write-Output "Exporting $ffmpeg..."

& "$vcpkg\vcpkg" export "ffmpeg[$features]:$triplet" --output=$ffmpeg --7zip

# move vcpkg export to the right location

Move-Item -Path "$vcpkg\$ffmpeg.7z" -Destination "." -ErrorAction "Stop"
if ($env:APPVEYOR) {
  Write-Output "Pushing $ffmpeg.7z"
  Push-AppveyorArtifact "$ffmpeg.7z"
}
