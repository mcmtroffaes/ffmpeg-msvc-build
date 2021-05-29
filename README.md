# ffmpeg-msvc-build

[![appveyor build status](https://ci.appveyor.com/api/projects/status/rok7i2fbv5ptrwvm?svg=true)](https://ci.appveyor.com/project/mcmtroffaes/ffmpeg-msvc-build) [![travis build status](https://travis-ci.com/mcmtroffaes/ffmpeg-msvc-build.svg?branch=master)](https://travis-ci.com/mcmtroffaes/ffmpeg-msvc-build)

Scripts for building FFmpeg with MSVC.

The script uses [vcpkg](https://github.com/microsoft/vcpkg)
which closely follows the [official
instructions](https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC).

The purpose of this repository is:

1. To enable the latest git version of ffmpeg to be built with vcpkg, with a few minimal patches on top of upstream vcpkg.
2. Do full feature testing for windows, linux, and osx (far more in-depth compared to what upstream vcpkg continuous integration is testing).
3. Provide a few lightweight builds for convenience. Given that there are so many different combinations of features that might make sense for specific purposes, and given the one hour time limit on appveyor, what is currently provided is an LGPL build including all standard libraries (avcodec, avformat, avfilter, avdevice, swresample, and swscale), vpx (one of the best LGPL video codecs), opus (one of the best LGPL audio codecs), and nvcodec (to provide H.264 and HEVC hardware encoding support if you have an nvidia GPU).

## Requirements

* [Visual Studio](https://docs.microsoft.com/en-us/cpp/)
* [vcpkg](https://github.com/microsoft/vcpkg)

## Usage

Clone the repository and run the following in powershell or cmd:

```ps
cd vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg.exe install --triplet=x64-windows ffmpeg[all]
```

You can pick another triplet, or another set of features. See the [ffmpeg vcpkg.json file](https://github.com/microsoft/vcpkg/blob/master/ports/ffmpeg/vcpkg.json) for a list of all features. The above will result in an LGPL licensed ffmpeg library built with all LGPL compatible features that are supported in vcpkg.

Prebuilt static LGPL builds for Visual Studio 2019 can be found
[here](https://github.com/mcmtroffaes/ffmpeg-msvc-build/releases).
See the
[vcpkg export documentation](https://vcpkg.readthedocs.io/en/latest/users/integration/#export)
for more information on how to use these pre-built packages.

## License

All scripts for creating the builds are licensed under the conditions
of the [MIT license](LICENSE.txt).

The builds themselves are covered by the relevant license for your build
(see [here](https://ffmpeg.org/legal.html) for full details).
