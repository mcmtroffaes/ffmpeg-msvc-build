& git pull --rebase
& git push
& git submodule update
$portfile = Get-Content "vcpkg\ports\ffmpeg\portfile.cmake"
if (-Not $portfile[6].StartsWith("    REF")) { throw "could not find REF field in portfile" }
$version_hash = $portfile[6].Substring(8)
$control = Get-Content "vcpkg\ports\ffmpeg\vcpkg.json" | ConvertFrom-Json
$ver = $control."version-string"
$pver = $control."port-version"
if($ver -Eq $null) { throw "could not find version-string from vcpkg.json" }
if($pver -Eq $null) { throw "could not find port-version from vcpkg.json" }
$tag = $ver.Replace("-", "") + ".$pver.0"
Write-Output "Tagging version $tag ($version_hash)."
& git tag -a -m "Tagging version $tag ($version_hash)." $tag
