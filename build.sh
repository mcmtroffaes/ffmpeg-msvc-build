# exit immediately upon error
set -e
cd $(cygpath "$APPVEYOR_BUILD_FOLDER")
. functions.sh
set -xe
# bash starts in msys home folder, so first go to project folder
make_all \
	license=${LICENSE,,} \
	visual_studio=${TOOLSET,,} \
	linkage=${LINKAGE,,} \
	runtime=${RUNTIME_LIBRARY,,} \
	configuration=${Configuration,,} \
	platform=${Platform,,}
