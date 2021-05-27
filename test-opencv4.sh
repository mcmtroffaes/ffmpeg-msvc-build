#!/bin/bash

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

# all features from vcpkg azure CI
# limit concurrency to prevent out of memory errors
VCPKG_MAX_CONCURRENCY=1 $VCPKG_ROOT/vcpkg install vcpkg-ci-ffmpeg:$TRIPLET vcpkg-ci-opencv:$TRIPLET --overlay-ports=$VCPKG_ROOT/scripts/test_ports/
