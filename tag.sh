. functions.sh
VERSION=$(get_git_date folder=$folder).$MINOR.$PATCH
echo "Tagging version $VERSION"
git tag -a -m "Tagging version $VERSION" $VERSION
