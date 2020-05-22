# script to update VERSION and SHA512 files to the zeranoe ffmpeg version
# to run this script, first set
# $env:PSExecutionPolicyPreference = "Bypass" in your local session

param (
    [switch]$force = $false
)

$ErrorActionPreference = "Stop"

$version_old = Get-Content "VERSION" -First 1 -Encoding Ascii
$version_nuget_old, $version_hash_old = $version_old.Split("-")
$version_nuget_major_old, $version_nuget_minor_old, $version_nuget_patch_old = $version_nuget_old.Split(".")

Write-Output "old major: $version_nuget_major_old" "old minor: $version_nuget_minor_old" "old hash:  $version_hash_old"

$wc = New-Object System.Net.WebClient
$zeranoe = $wc.DownloadString("https://ffmpeg.zeranoe.com/builds/win64/static").Split("`n")
$match = $zeranoe | Select-String -Pattern "href=""ffmpeg-([0-9]+-[a-z0-9]+)-win64"
$zeranoe_version = $match.Matches[-1].Groups[1].Value
$version_nuget_major, $version_hash = $zeranoe_version.Split("-")

if (($version_hash -eq $version_hash_old) -and (-not $force)) {
  Write-Output "Already up to date."
}
else {
  if ($version_hash -ne $version_hash_old) {
    $wc.DownloadFile("https://github.com/ffmpeg/ffmpeg/archive/$version_hash.tar.gz", "$version_hash.tar.gz")
    $sha512 = (Get-FileHash -Algorithm SHA512 "$version_hash.tar.gz").Hash.ToLower()
    Write-Output $sha512 | Set-Content "SHA512" -Encoding Ascii -NoNewline
  }
  if ($version_nuget_major -eq $version_nuget_major_old) {
    $version_nuget_minor = [convert]::ToInt64($version_nuget_minor_old) + 1
  }
  else {
    $version_nuget_minor = 0
  }
  Write-Output "new major: $version_nuget_major" "new minor: $version_nuget_minor" "new hash:  $version_hash"
  $version_nuget = "{0}.{1}.0" -f $version_nuget_major, $version_nuget_minor
  Write-Output "$version_nuget-$version_hash" | Set-Content "VERSION" -Encoding Ascii -NoNewline
  & git commit -a -m "Update ffmpeg to version $version_nuget-$version_hash."
  & git tag -a -m "Tagging version $version_nuget." $version_nuget
}
