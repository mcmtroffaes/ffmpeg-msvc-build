# script to update VERSION and SHA512 files to the latest ffmpeg git version
# to run this script, first set
# $env:PSExecutionPolicyPreference = "Bypass" in your local session

param (
    [switch]$force = $false
)

$ErrorActionPreference = "Stop"

& git pull --rebase

pushd ffmpeg
& git pull
popd

$version_old = Get-Content "VERSION" -First 1 -Encoding Ascii
$version_nuget_old, $version_hash_old = $version_old.Split("-")
$version_nuget_major_old, $version_nuget_minor_old, $version_nuget_patch_old = $version_nuget_old.Split(".")

Write-Output "old major: $version_nuget_major_old" "old minor: $version_nuget_minor_old" "old hash:  $version_hash_old"

pushd ffmpeg
$version_hash = git show --no-patch --no-notes --pretty="%h" | Out-String -NoNewLine
$version_nuget_major = git show --no-patch --no-notes --pretty="%cs" | Out-String -NoNewLine
$version_nuget_major = $version_nuget_major -Replace "-",""
popd

if (($version_hash -eq $version_hash_old) -and (-not $force)) {
  Write-Output "Already up to date."
}
else {
  if ($version_hash -ne $version_hash_old) {
    $wc = New-Object System.Net.WebClient
    $server = "https://github.com/ffmpeg/ffmpeg/archive"
    $file = "$version_hash.tar.gz"
    Write-Output "Downloading $server/$file..."
    $wc.DownloadFile("$server/$file", "$file")
    $sha512 = (Get-FileHash -Algorithm SHA512 "$file").Hash.ToLower()
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
