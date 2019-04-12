. functions.sh
ZERANOE_FFMPEG_HASH=`curl https://ffmpeg.zeranoe.com/builds/ | grep -Po 'value="[0-9]+-\K[a-z0-9]+' | head -n 1`
pushd ffmpeg
git fetch
if [[ `git rev-parse HEAD` == $ZERANOE_FFMPEG_HASH* ]]
then
    echo "Already up to date."
    exit 0
fi
git checkout $ZERANOE_FFMPEG_HASH
popd
git commit -a -m "Update ffmpeg to version $(get_git_date folder=ffmpeg)-$(get_git_hash folder=ffmpeg)"
VERSION=$(get_git_date folder=ffmpeg).$MINOR.$PATCH
echo "Tagging version $VERSION"
git tag -a -m "Tagging version $VERSION" $VERSION
