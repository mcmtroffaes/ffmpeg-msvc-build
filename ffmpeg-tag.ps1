& git pull --rebase
& git push
& git submodule update
$portfile = Get-Content "vcpkg\ports\ffmpeg\portfile.cmake"
if (-Not $portfile[3].StartsWith("    REF")) { throw "could not find REF field in portfile" }
$version_hash = $portfile[3].Substring(8)
$control = Get-Content "vcpkg\ports\ffmpeg\CONTROL"
if (-Not $control[1].StartsWith("Version:")) { throw "could not find Version field in CONTROL file" }
if (-Not $control[2].StartsWith("Port-Version:")) { throw "could not find PortVersion field in CONTROL file" }
$version = $control[1].Split(" ")[1]
$port_version = $control[2].Split(" ")[1]
$tag = $version.Replace("-", "") + ".$port_version.0"
Write-Output "Tagging version $tag ($version_hash)."
& git tag -a -m "Tagging version $tag ($version_hash)." $tag
