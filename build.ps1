param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$platform = "x64", 
    [string]$runtime_library = "MD",
    [string]$linkage = "static",
    [string]$toolset = "v142"
)

# create vcpkg triplet

$platform = $platform.tolower()
$runtime_library = $runtime_library.tolower()
$linkage = $linkage.tolower()
$toolset = $toolset.tolower()

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

# run vcpkg install and export

& "$vcpkg\vcpkg" install "ffmpeg[vpx]:$triplet" --recurse
& "$vcpkg\vcpkg" export "ffmpeg[vpx]:$triplet" --output=export --raw

# create zip archive

Get-ChildItem -Recurse -Path "$vcpkg\export\installed\$triplet" `
  -Include pkgconfig | Remove-Item -Verbose -Recurse
Get-ChildItem -Recurse -Path "$vcpkg\export\installed\$triplet\share" `
  -Include *.cmake,vcpkg_abi_info.txt,usage | Remove-Item -Verbose
Rename-Item -Path "$vcpkg\export\installed\$triplet" -NewName "$vcpkg\export\installed\ffmpeg-$triplet"
Get-ChildItem -Recurse -Path "$vcpkg\export\installed\ffmpeg-$triplet"
Compress-Archive "$vcpkg\export\installed\ffmpeg-$triplet" -DestinationPath "ffmpeg-$triplet.zip"