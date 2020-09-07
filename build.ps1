param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$triplet = "x64-windows",
    [string]$features = "core"
)

# update CONTROL and portfile.cmake files to the proper version

$version = Get-Content "VERSION" -First 1 -Encoding Ascii
$version_nuget, $version_hash = $version.Split("-")
$version_nuget_major, $version_nuget_minor, $version_nuget_patch = $version_nuget.Split(".")
$version_nuget_year  = [convert]::ToInt64($version_nuget_major.Substring(0, 4))
$version_nuget_month = [convert]::ToInt64($version_nuget_major.Substring(4, 2))
$version_nuget_day   = [convert]::ToInt64($version_nuget_major.Substring(6, 2))
$version_vcpkg = "{0,4:d4}-{1,2:d2}-{2,2:d2}-{3}" -f $version_nuget_year, $version_nuget_month, $version_nuget_day, $version_nuget_minor

$control = Get-Content "$vcpkg\ports\ffmpeg\CONTROL"
if (-Not $control[1].StartsWith("Version:")) { throw "could not find version field in CONTROL file" }
$control[1] = "Version: $version_vcpkg"
$control -join "`n" | Set-Content "$vcpkg\ports\ffmpeg\CONTROL" -Encoding Ascii -NoNewline
Write-Output "" "CONTROL" "~~~~~~~" "" $control[0..4]

$sha512 = Get-Content "SHA512" -First 1 -Encoding Ascii

$portfile = Get-Content "$vcpkg\ports\ffmpeg\portfile.cmake"
if (-Not $portfile[3].StartsWith("    REF")) {
  Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..20] ""
  throw "could not find REF field in portfile"
}
if (-Not $portfile[4].StartsWith("    SHA512")) {
  Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..20] ""
  throw "could not find SHA512 field in portfile"
}
$portfile[3] = "    REF $version_hash"
$portfile[4] = "    SHA512 $sha512"
$portfile -join "`n" ` | Set-Content "$vcpkg\ports\ffmpeg\portfile.cmake" -Encoding Ascii -NoNewline
Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..12] ""

# fix patches
Copy-Item -Path "0006-fix-StaticFeatures.patch" -Destination "$vcpkg\ports\ffmpeg\"
Copy-Item -Path "0011-Fix-x265-detection.patch" -Destination "$vcpkg\ports\ffmpeg\"
Copy-Item -Path "0012-Fix-ssl-110-detection.patch" -Destination "$vcpkg\ports\ffmpeg\"

# update vcpkg_acquire_msys to use the appveyor version of msys64

if ($env:APPVEYOR) {
  Copy-Item -Path "vcpkg_acquire_msys.cmake" -Destination "$vcpkg\scripts\cmake\"
}

# install

& "$vcpkg\vcpkg" install "ffmpeg[$features]:$triplet" --recurse
Get-ChildItem -Recurse -Name -File -Path "$vcpkg\installed\$triplet"

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

$ffmpeg = "ffmpeg-$version-$license-$triplet"

# export

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
