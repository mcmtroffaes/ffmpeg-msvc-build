param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$platform = "x64", 
    [string]$runtime_library = "MD",
    [string]$linkage = "dynamic",
    [string]$toolset = "v142",
    [string]$license = "LGPL21",
    [string]$features = "core"
)

# create vcpkg triplet

$platform = $platform.tolower()
$runtime_library = $runtime_library.tolower()
$linkage = $linkage.tolower()
$toolset = $toolset.tolower()
$license = $license.tolower()
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
if (-Not $portfile[5].StartsWith("    REF")) { throw "could not find REF field in portfile" }
if (-Not $portfile[6].StartsWith("    SHA512")) { throw "could not find SHA512 field in portfile" }
$portfile[5] = "    REF $version_hash"
$portfile[6] = "    SHA512 $sha512"
$portfile -join "`n" ` | Set-Content "$vcpkg\ports\ffmpeg\portfile.cmake" -Encoding Ascii -NoNewline
Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[2..14] ""

# run vcpkg install and export

& "$vcpkg\vcpkg" install "ffmpeg[$features]:$triplet" --recurse
& "$vcpkg\vcpkg" export "ffmpeg[$features]:$triplet" --output=export --raw

# create zip archive

$ffmpeg = "ffmpeg-$version-$license-$triplet"
Get-ChildItem -Recurse -Path "$vcpkg\export\installed\$triplet" `
  -Include pkgconfig | Remove-Item -Verbose -Recurse
Get-ChildItem -Recurse -Path "$vcpkg\export\installed\$triplet\share" `
  -Include *.cmake,vcpkg_abi_info.txt,usage | Remove-Item -Verbose
Move-Item -Path "$vcpkg\export\installed\$triplet" -Destination $ffmpeg
Get-ChildItem -Recurse -Name -Path $ffmpeg
Compress-Archive $ffmpeg -DestinationPath "$ffmpeg.zip"
