#!/bin/bash

if [ -z "$1" ]
then
    echo "Expected vcpkg root as first argument."
    exit 1
fi

if [ -z "$2" ]
then
    echo "Expected triplet as second argument."
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
mkdir $SCRIPT_DIR/test-$TRIPLET-rel
cd $SCRIPT_DIR/test-$TRIPLET-rel
cmake $SCRIPT_DIR/test -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=RELEASE -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=$TRIPLET -DFEATURES=$ALL_FEATURES
cmake --build .
ctest -V

# Test debug
mkdir $SCRIPT_DIR/test-$TRIPLET-dbg
cd $SCRIPT_DIR/test-$TRIPLET-dbg
cmake $SCRIPT_DIR/test -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=DEBUG -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake -DVCPKG_TARGET_TRIPLET=$TRIPLET -DFEATURES=$ALL_FEATURES
cmake --build .
ctest -V
