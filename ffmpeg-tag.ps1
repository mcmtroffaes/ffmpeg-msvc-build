& git pull --rebase
& git push
& git submodule update
$portfile = Get-Content "vcpkg\ports\ffmpeg\portfile.cmake"
if (-Not $portfile[3].StartsWith("    REF")) { throw "could not find REF field in portfile" }
$version_hash = $portfile[3].Substring(8)
$control = Get-Content "vcpkg\ports\ffmpeg\vcpkg.json"
if (-Not $control[2].StartsWith("  ""version-string"":")) { throw "could not find version field in vcpkg.json file" }
if (-Not $control[3].StartsWith("  ""port-version"":")) { throw "could not find port-version field in vcpkg.json file" }
$version_old = $control[2].Split(":")[1].Trim(" "",")
$port_version_old = $control[3].Split(":")[1].Trim(" "",")
$tag = $version.Replace("-", "") + ".$port_version.0"
Write-Output "Tagging version $tag ($version_hash)."
& git tag -a -m "Tagging version $tag ($version_hash)." $tag
