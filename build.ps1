param (
    [string]$vcpkg = "C:\Tools\vcpkg", 
    [string]$platform = "x64", 
    [string]$runtime_library = "MD",
    [string]$linkage = "static",
    [string]$toolset = "v142",
    [string]$configuration = "Release"
)

$platform = $platform.tolower()
$runtime_library = $runtime_library.tolower()
$linkage = $linkage.tolower()
$toolset = $toolset.tolower()
$configuration = $configuration.tolower()

switch ($runtime_library) {
  "md" { $crt_linkage = "dynamic" }
  "mt" { $crt_linkage = "static" }
  default { throw("invalid runtime library $runtime_library (expected MD or MT)")}
}

$triplet = "$platform-windows-$linkage-$runtime_library-$toolset-$configuration"

echo `
  "set(VCPKG_TARGET_ARCHITECTURE $platform)" `
  "set(VCPKG_CRT_LINKAGE $crt_linkage)" `
  "set(VCPKG_LIBRARY_LINKAGE $linkage)" `
  "set(VCPKG_PLATFORM_TOOLSET $toolset)" `
  "set(VCPKG_BUILD_TYPE $configuration)" `
  | Out-File -FilePath "$vcpkg\triplets\$triplet.cmake" -Encoding ascii

& "$vcpkg\vcpkg" install "ffmpeg[vpx]:$triplet" --recurse
& "$vcpkg\vcpkg" export "ffmpeg[vpx]:$triplet" --output=export --raw
dir /s /b "$vcpkg\export\installed\$triplet\"
