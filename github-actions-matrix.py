import argparse
import json
from typing import NamedTuple, Optional


class Triplet(NamedTuple):
    triplet: str
    os: str


class Test(NamedTuple):
    test: str
    features: str
    dependencies_ubuntu: str = ""


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
        dependencies_ubuntu="gperf",  # pulls in fontconfig which needs gperf
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
        dependencies_ubuntu="gperf",  # pulls in fontconfig which needs gperf
        ),
    Test(
        test="iconv",
        features="core,iconv,avcodec",
        ),
    Test(
        test="ilbc",
        features="core,ilbc,avcodec",
        ),
    Test(
        test="lzma",
        features="core,lzma,avformat",
        ),
    Test(
        test="modplug",
        features="core,modplug,avformat",
        ),
    Test(
        test="mp3lame",
        features="core,mp3lame,avcodec",
        ),
    Test(
        test="nvcodec",
        features="core,nvcodec,avcodec",
        ),
    Test(
        test="opencl",
        features="core,opencl,avfilter",
        ),
    Test(
        test="opengl",
        features="core,opengl,avdevice",
        dependencies_ubuntu="libgl-dev libxext-dev",
        ),
    Test(
        test="openh264",
        features="core,openh264,avcodec",
        ),
    Test(
        test="openjpeg",
        features="core,openjpeg,avcodec",
        ),
    Test(
        test="opus",
        features="core,opus,avcodec",
        ),
    Test(
        test="sdl2",
        features="core,sdl2,avdevice",
        ),
    Test(
        test="snappy",
        features="core,snappy,avcodec",
        ),
    Test(
        test="soxr",
        features="core,soxr,swresample",
        ),
    Test(
        test="ssh",
        features="core,ssh,avformat",
        ),
    Test(
        test="tesseract",
        features="core,tesseract,avfilter",
        ),
    Test(
        test="speex",
        features="core,speex,avcodec",
        ),
    Test(
        test="theora",
        features="core,theora,avcodec",
        ),
    Test(
        test="vorbis",
        features="core,vorbis,avcodec",
        ),
    Test(
        test="vpx",
        features="core,vpx,avcodec",
        ),
    Test(
        test="webp",
        features="core,webp,avcodec",
        ),
    Test(
        test="xml2",
        features="core,xml2,avformat",
        ),
    Test(
        test="zlib",
        features="core,zlib,avformat",
        ),
    Test(
        test="avisynthplus",
        features="core,avisynthplus,avformat",
        ),
    # GPL features
    Test(
        test="postproc",
        features="core,postproc",
        ),
    Test(
        test="x264",
        features="core,x264,avcodec",
        ),
    Test(
        test="x265",
        features="core,x265,avcodec",
        ),
    # non-free features
    Test(
        test="openssl",
        features="core,openssl,avformat",
        ),
    Test(
        test="fdk-aac",
        features="core,fdk-aac,avcodec",
        ),
    ]


parser = argparse.ArgumentParser(description='Generate build matrix.')
parser.add_argument('--triplets', nargs='*')
parser.add_argument('--tests', nargs='*')
args = parser.parse_args()


def experimental_job(triplet: Triplet, test: Test):
    is_experimental = dict(experimental=True)
    if test.test == "ffplay" and triplet.triplet == "x64-osx":
        return is_experimental
    if test.test == "ass" and triplet.triplet == "x64-linux":
        return is_experimental
    if test.test == "bzip2" and triplet.triplet == "x64-osx":
        return is_experimental
    if test.test == "dav1d" and triplet.triplet == "x64-osx":
        return is_experimental
    if test.test == "freetype2" and triplet.triplet.startswith("x64-windows-static"):
        return is_experimental
    if test.test == "freetype2" and triplet.triplet == "x64-linux":
        return is_experimental
    if test.test == "freetype2" and triplet.triplet == "x64-osx":
        return is_experimental
    return {}


def include_job(triplet: Triplet, test: Test):
    # filter as per arguments provided
    if args.triplets:
        if triplet.triplet not in args.triplets:
            return False
    if args.tests:
        if test.test not in args.tests:
            return False
    # disable mingw triplets in default build (known to be broken)
    if triplet.triplet.startswith("x64-mingw") and not args.triplets:
        return False
    # disable x64-windows-static in default build (reduce matrix size)
    if triplet.triplet.startswith("x64-windows-static") and not args.triplets:
        return False
    # dav1d only supports 64 bit
    if test.test == "dav1d" and triplet.triplet.startswith("x86-windows"):
        return False
    # nvcodec not supported on osx
    if test.test == "nvcodec" and triplet.triplet == "x64-osx":
        return False
    return True


matrix = {"include": [
    {**triplet._asdict(), **test._asdict(), **experimental_job(triplet, test)}
    for triplet in triplets
    for test in tests
    if include_job(triplet, test)
    ]}


print("::set-output name=matrix::%s" % json.dumps(matrix, separators=(',', ':')))
