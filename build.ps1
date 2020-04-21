param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$platform = "x64", 
    [string]$runtime_library = "MD",
    [string]$linkage = "dynamic",
    [string]$toolset = "v142",
    [string]$features = "core"
)

# create vcpkg triplet

$platform = $platform.tolower()
$runtime_library = $runtime_library.tolower()
$linkage = $linkage.tolower()
$toolset = $toolset.tolower()
$features = $features.tolower()

switch ($runtime_library) {
  "md" { $crt_linkage = "dynamic" }
  "mt" { $crt_linkage = "static" }
  default { throw("invalid runtime library $runtime_library (expected MD or MT)")}
}

$triplet = "$platform-windows-$linkage-$runtime_library-$toolset"

Write-Output `
  "set(VCPKG_TARGET_ARCHITECTURE $platform)" `
  "set(VCPKG_CRT_LINKAGE $crt_linkage)" `
  "set(VCPKG_LIBRARY_LINKAGE $linkage)" `
  "set(VCPKG_PLATFORM_TOOLSET $toolset)" `
  | Out-File -FilePath "$vcpkg\triplets\$triplet.cmake" -Encoding ascii

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

# update vcpkg_acquire_msys to use the appveyor version of msys64

if ($env:APPVEYOR) {
  Copy-Item -Path "vcpkg_acquire_msys.cmake" -Destination "$vcpkg\scripts\cmake\"
}

# install

& "$vcpkg\vcpkg" install "ffmpeg[$features]:$triplet" --recurse
Get-ChildItem -Recurse -Name -File -Path "$vcpkg\installed\$triplet"

# get license from copyright file

$copyright = Get-Content "$vcpkg\installed\$triplet\share\ffmpeg\copyright" -First 2 -Encoding Ascii
Write-Output "" "COPYRIGHT" "~~~~~~~~~" "" $copyright ""
if ($copyright[0].Trim() == "GNU LESSER GENERAL PUBLIC LICENSE") {
  if ($copyright[1].Trim() == "Version 2.1, February 1999") {
    $license = "lgpl21"
  }
  elseif ($copyright[1].Trim() == "Version 3, 29 June 2007") {
    $license = "lgpl3"
  }
  else {
    throw "unknown LGPL version"
  }
}
elseif ($copyright[0].Trim() == "GNU GENERAL PUBLIC LICENSE") {
  if ($copyright[1].Trim() == "Version 2, June 1991") {
    $license = "gpl2"
  }
  elseif ($copyright[1].Trim() == "Version 3, 29 June 2007") {
    $license = "gpl3"
  }
  else {
    throw "unknown GPL version"
  }
}
elseif ($copyright[0].Trim() == "License: nonfree and unredistributable") {
  $license = "nonfree"
}
else {
  throw "unknown license"
}

$ffmpeg = "ffmpeg-$version-$license-$toolset-$linkage-$runtime_library-$platform"

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
