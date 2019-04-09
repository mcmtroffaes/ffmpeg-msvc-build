. functions.sh
pushd ffmpeg
git fetch
git checkout origin/master
popd
git commit -a -m "Update ffmpeg to version $(get_git_date folder=$folder)-$(get_git_hash folder=$folder)"
VERSION=$(get_git_date folder=ffmpeg).$MINOR.$PATCH
echo "Tagging version $VERSION"
git tag -a -m "Tagging version $VERSION" $VERSION
