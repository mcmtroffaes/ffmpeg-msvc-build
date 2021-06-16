import argparse
import json
from typing import NamedTuple, Optional


class Triplet(NamedTuple):
    triplet: str
    os: str


class Test(NamedTuple):
    test: str
    features: str


triplets = [
    Triplet(
        triplet="x64-linux",
        os="ubuntu-latest",
        ),
    Triplet(
        triplet="x64-osx",
        os="macos-latest",
        ),
    Triplet(
        triplet="x64-windows",
        os="windows-latest",
        ),
    Triplet(
        triplet="x64-windows-static",
        os="windows-latest",
        ),
    Triplet(
        triplet="x64-windows-static-md",
        os="windows-latest",
        ),
    Triplet(
        triplet="x86-windows",
        os="windows-latest",
        ),
    Triplet(
        triplet="x64-mingw-dynamic",
        os="ubuntu-latest",
        ),
    Triplet(
        triplet="x64-mingw-static",
        os="ubuntu-latest",
        ),
    ]

tests = [
    Test(
        test="minimal",
        features="core",
        ),
    Test(
        test="release",
        features="core,avcodec,avformat,avdevice,avfilter,swresample,swscale,opus,vpx",
        ),
    Test(
        test="avcodec",
        features="core,avcodec",
        ),
    Test(
        test="avformat",
        features="core,avformat",
        ),
    Test(
        test="avdevice",
        features="core,avdevice",
        ),
    Test(
        test="avfilter",
        features="core,avfilter",
        ),
    Test(
        test="swresample",
        features="core,swresample",
        ),
    Test(
        test="swscale",
        features="core,swscale",
        ),
    Test(
        test="ffmpeg",
        features="core,ffmpeg",
        ),
    Test(
        test="ffplay",
        features="core,ffplay",
        ),
    Test(
        test="ffprobe",
        features="core,ffprobe",
        ),
    Test(
        test="ass",
        features="core,ass,avfilter",
        ),
    Test(
        test="bzip2",
        features="core,avformat,bzip2",
        ),
    Test(
        test="dav1d",
        features="core,dav1d,avcodec",
        ),
    Test(
        test="freetype1",
        features="core,freetype,avfilter",
        ),
    Test(
        test="freetype2",
        features="core,freetype,fontconfig,fribidi,avfilter",
        ),
    ]


parser = argparse.ArgumentParser(description='Generate build matrix.')
parser.add_argument('--triplets', nargs='*')
parser.add_argument('--tests', nargs='*')
args = parser.parse_args()


def include_job(triplet: Triplet, test: Test):
    # filter as per arguments provided
    if args.triplets:
        if triplet.triplet not in args.triplets:
            return False
    if args.tests:
        if test.test not in args.tests:
            return False
    # disable mingw triplets (they are known to be broken)
    if triplet.triplet.startswith("x64-mingw"):
        return False
    # filter broken combinations
    if test.test == "freetype2" and triplet.triplet == "x64-windows-static-md":
        return False
    return True


matrix = {"include": [
    {**triplet._asdict(), **test._asdict()}
    for triplet in triplets
    for test in tests
    if include_job(triplet, test)
    ]}


print("::set-output name=matrix::%s" % json.dumps(matrix))
