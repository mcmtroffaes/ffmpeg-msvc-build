# exit immediately upon error
set -e

. functions.sh

set -xe
# bash starts in msys home folder, so first go to project folder
cd $(cygpath "$APPVEYOR_BUILD_FOLDER")
make_all \
	license=${LICENSE,,} \
	visual_studio=${TOOLSET,,} \
	linkage=${LINKAGE,,} \
	runtime=${RUNTIME_LIBRARY,,} \
	configuration=${Configuration,,} \
	platform=${Platform,,}
