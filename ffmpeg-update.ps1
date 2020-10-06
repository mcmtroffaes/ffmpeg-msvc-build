param (
    [switch]$force = $false
)

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")

$portfile = Get-Content "vcpkg\ports\ffmpeg\portfile.cmake"
if (-Not $portfile[3].StartsWith("    REF")) {
  Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..20] ""
  throw "could not find REF field in portfile"
}
if (-Not $portfile[4].StartsWith("    SHA512")) {
  Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..20] ""
  throw "could not find SHA512 field in portfile"
}

$version_hash_old = $portfile[3].Substring(8)
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
$portfile[3] = "    REF $version_hash"
$portfile[4] = "    SHA512 $sha512"
$portfile -join "`n" ` | Set-Content "vcpkg\ports\ffmpeg\portfile.cmake" -Encoding Ascii
Write-Output "" "portfile.cmake" "~~~~~~~~~~~~~~" "" $portfile[0..12] ""

$control = Get-Content "vcpkg\ports\ffmpeg\CONTROL"
if (-Not $control[1].StartsWith("Version:")) { throw "could not find Version field in CONTROL file" }
if (-Not $control[2].StartsWith("Port-Version:")) { throw "could not find PortVersion field in CONTROL file" }
$version_old = $control[1].Split(" ")[1]
$port_version_old = $control[2].Split(" ")[1]
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
$control[1] = "Version: $version"
$control[2] = "Port-Version: $port_version"
$control -join "`n" | Set-Content "vcpkg\ports\ffmpeg\CONTROL" -Encoding Ascii
Write-Output "" "CONTROL" "~~~~~~~" "" $control[0..4]

cd vcpkg
& git diff -b
& git add -i
& git commit -a -m "Update ffmpeg."
& git log -1 --format=%H > ../VCPKG_HASH.txt
cd ..
