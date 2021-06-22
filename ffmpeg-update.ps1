param (
    [switch]$force = $false
)

cd vcpkg
& git commit -a
& git pull --rebase
cd ..
& git commit -a
& git pull --rebase

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

$line = 6

$portfile = Get-Content "vcpkg\ports\ffmpeg\portfile.cmake"
if (-Not $portfile[$line].StartsWith("    REF")) {
  Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..20] ""
  throw "could not find REF field in portfile"
}
if (-Not $portfile[$line + 1].StartsWith("    SHA512")) {
  Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..20] ""
  throw "could not find SHA512 field in portfile"
}

$version_hash_old = $portfile[$line].Substring(8)
Write-Output "old version hash: $version_hash_old"

$commits = $wc.DownloadString("https://api.github.com/repos/FFmpeg/FFmpeg/commits") | ConvertFrom-Json

$version_hash = $commits[0].sha
$version = $commits[0].commit.committer.date.Split("T")[0]
Write-Output "new version hash: $version_hash"

if (($version_hash -eq $version_hash_old) -and (-not $force)) {
  Write-Output "Already up to date."
  Exit
}

$server = "https://github.com/FFmpeg/FFmpeg/archive"
$file = "$version_hash.tar.gz"
Write-Output "Downloading $server/$file..."
if (-Not (Test-Path -Path $file -PathType leaf)) {
  $wc.DownloadFile("$server/$file", "$file")
}
$sha512 = (Get-FileHash -Algorithm SHA512 "$file").Hash.ToLower()
$portfile[$line] = "    REF $version_hash"
$portfile[$line + 1] = "    SHA512 $sha512"
$portfile -join "`n" ` | Set-Content "vcpkg\ports\ffmpeg\portfile.cmake" -Encoding Ascii
Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..12] ""

$control = Get-Content "vcpkg\ports\ffmpeg\vcpkg.json"
if (-Not $control[2].StartsWith("  ""version-string"":")) { throw "could not find version field in vcpkg.json file" }
if (-Not $control[3].StartsWith("  ""port-version"":")) { throw "could not find port-version field in vcpkg.json file" }
$version_old = $control[2].Split(":")[1].Trim(" "",")
$port_version_old = $control[3].Split(":")[1].Trim(" "",")
Write-Output "old version: $version_old"
Write-Output "old port version: $port_version_old"
if ($version_old -eq $version) {
  $port_version = [convert]::ToInt64($port_version_old) + 1
}
else {
  $port_version = 0
}
Write-Output "new version: $version"
Write-Output "new port version: $port_version"
$control[2] = "  ""version-string"": ""$version"","
$control[3] = "  ""port-version"": $port_version,"
$control -join "`n" | Set-Content "vcpkg\ports\ffmpeg\vcpkg.json" -Encoding Ascii
Write-Output "" "vcpkg.json" "~~~~~~~~~~" "" $control[0..4]

cd vcpkg
& git commit -a -m "Update ffmpeg to version $version#$port_version ($version_hash)."
& git log -1 --format=%H  | Set-Content ../VCPKG_HASH.txt -Encoding Ascii
cd ..
& git commit -a -m "Update ffmpeg to version $version#$port_version ($version_hash)."
