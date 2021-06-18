#!/bin/bash

set -e

if [ $# -ne 2 ]
then
    echo "Usage: $0 <vcpkg root folder> <triplet>"
    exit 1
fi

if [ ! -d "$1" ]
then
    echo "Folder $1 does not exist."
    exit 1
fi

VCPKG_ROOT=$1
TRIPLET=$2

echo "vcpkg root: $VCPKG_ROOT"
echo "triplet: $TRIPLET"

# Get list of all ffmpeg features from vcpkg list
ALL_FEATURES=`$VCPKG_ROOT/vcpkg list | grep "ffmpeg\[.*\]:$TRIPLET" | sed 's/ffmpeg\[\(.*\)\].*/\1/' | tr '\n' ';'`core
echo "ffmpeg features: $ALL_FEATURES"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Test release
mkdir -p $SCRIPT_DIR/test-$TRIPLET-rel
cd $SCRIPT_DIR/test-$TRIPLET-rel
cmake $SCRIPT_DIR/test -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=$TRIPLET -DFEATURES=$ALL_FEATURES
cmake --build .
ctest -V

# Test debug
mkdir -p $SCRIPT_DIR/test-$TRIPLET-dbg
cd $SCRIPT_DIR/test-$TRIPLET-dbg
cmake $SCRIPT_DIR/test -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=$TRIPLET -DFEATURES=$ALL_FEATURES
cmake --build .
ctest -V
