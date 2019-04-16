. functions.sh
ZERANOE_FFMPEG_HASH=`curl https://ffmpeg.zeranoe.com/builds/ | grep -Po 'value="[0-9]+-\K[a-z0-9]+' | head -n 1`
pushd ffmpeg
git fetch
if [[ `git rev-parse HEAD` == $ZERANOE_FFMPEG_HASH* ]] && [[ "$1" != "--force" ]]
then
    echo "Already up to date."
    exit 0
fi
git checkout $ZERANOE_FFMPEG_HASH
popd

OLD_NUGET_VERSION=`cat VERSION | head -n 1`
OLD_NUGET_VERSION_MAJOR=`expr "${OLD_NUGET_VERSION}" : '^\([0-9]*\)[.]'`
OLD_NUGET_VERSION_MINOR=`expr "${OLD_NUGET_VERSION}" : '^[0-9]*[.]\([0-9]*\)'`
NEW_NUGET_VERSION_MAJOR=$(get_git_date folder=ffmpeg)

if [ "$OLD_NUGET_VERSION_MAJOR" \> "$NEW_NUGET_VERSION_MAJOR" ]
then
    echo "New major version is lower than old version."
    exit 1
fi

if [ "$OLD_NUGET_VERSION_MAJOR" == "$NEW_NUGET_VERSION_MAJOR" ]
then
    NEW_NUGET_VERSION_MINOR=$((OLD_NUGET_VERSION_MINOR+1))
else
    NEW_NUGET_VERSION_MINOR=0
fi

NEW_NUGET_VERSION=${NEW_NUGET_VERSION_MAJOR}.${NEW_NUGET_VERSION_MINOR}.0

echo "$OLD_NUGET_VERSION -> $NEW_NUGET_VERSION"

sed -i "s/$OLD_NUGET_VERSION/$NEW_NUGET_VERSION/g" VERSION
git commit -a -m "Update ffmpeg to version $(get_git_date folder=ffmpeg)-$(get_git_hash folder=ffmpeg)"
git tag -a -m "Tagging version $NEW_NUGET_VERSION." $NEW_NUGET_VERSION
