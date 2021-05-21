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
VCPKG_MAX_CONCURRENCY=1 $VCPKG_ROOT/vcpkg install ffmpeg[all,all-gpl,all-nonfree,ass,avcodec,avdevice,avfilter,avformat,avresample,bzip2,core,dav1d,fdk-aac,fontconfig,freetype,fribidi,gpl,iconv,ilbc,lzma,modplug,mp3lame,nonfree,nvcodec,opencl,opengl,openh264,openjpeg,openssl,opus,postproc,sdl2,snappy,soxr,speex,swresample,swscale,theora,vorbis,vpx,webp,x264,x265,zlib]:$TRIPLET opencv4[ade,contrib,core,dnn,eigen,ffmpeg,gdcm,ipp,jasper,jpeg,lapack,nonfree,openexr,opengl,openmp,png,qt,quirc,sfm,tiff,vtk,webp]:$TRIPLET
