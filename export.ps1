param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$triplet = "x64-windows",
    [string]$features = "core"
)

# get version from CONTROL

$control = Get-Content "$vcpkg\ports\ffmpeg\CONTROL"
if (-Not $control[1].StartsWith("Version:")) {
  throw "could not find Version field in CONTROL file"
}
if (-Not $control[2].StartsWith("Port-Version:")) {
  if (-Not $control[2].StartsWith("Homepage:")) {
    throw "could not find Port-Version field in CONTROL file"
  }
  else {
    $version = $control[1].Remove(0, 9), "0" -Join "-"
  }
}
else {
  $version = $control[1].Remove(0, 9), $control[2].Remove(0,14) -Join "-"
}

# get license from copyright file

$copyright = `
  Get-Content "$vcpkg\installed\$triplet\share\ffmpeg\copyright" -First 2 -Encoding Ascii `
  | ForEach-Object { $_.Trim() }
Write-Output "" "COPYRIGHT" "~~~~~~~~~" "" $copyright ""
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
elseif ($copyright[0] -Eq "License: nonfree and unredistributable") {
  $license = "nonfree"
}
else {
  throw "unknown license"
}

# export

$ffmpeg = "ffmpeg-$version-$license-$triplet"
Write-Output "Exporting $ffmpeg..."

Try {
  & "$vcpkg\vcpkg" export "ffmpeg[$features]:$triplet" --output=$ffmpeg --7zip
}
Finally {
  pushd $vcpkg
  & 7z a logs.7z -ir!".\*.log"
  popd
  Move-Item -Path "$vcpkg\logs.7z" -Destination "."
  if ($env:APPVEYOR) {
    Write-Output "Pushing logs.7z"
    Push-AppveyorArtifact logs.7z  # this forces push even if build fails
  }
}

# move vcpkg export to the right location

Move-Item -Path "$vcpkg\$ffmpeg.7z" -Destination "." -ErrorAction "Stop"
if ($env:APPVEYOR) {
  Write-Output "Pushing $ffmpeg.7z"
  Push-AppveyorArtifact "$ffmpeg.7z"
}
