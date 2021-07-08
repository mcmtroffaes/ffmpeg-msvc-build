# ffmpeg-msvc-build

[![test](https://github.com/mcmtroffaes/ffmpeg-msvc-build/actions/workflows/test.yml/badge.svg)](https://github.com/mcmtroffaes/ffmpeg-msvc-build/actions/workflows/test.yml)

Scripts for building FFmpeg with MSVC.

The script uses [vcpkg](https://github.com/microsoft/vcpkg)
which closely follows the [official
instructions](https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC).

The purpose of this repository is:

1. To enable the latest git version of ffmpeg to be built with vcpkg, with a few minimal patches on top of upstream vcpkg.
2. Do full feature testing for windows, linux, and osx (far more in-depth compared to what upstream vcpkg continuous integration is testing).
3. Provide a few builds for convenience. Given that there are so many different combinations of features that might make sense for specific purposes, what is currently provided is an LGPLv2 build including all ffmpeg features exposed by vcpkg.

## Requirements

* [Visual Studio](https://docs.microsoft.com/en-us/cpp/)
* [vcpkg](https://github.com/microsoft/vcpkg)

## Usage

Clone the repository and run the following in powershell or cmd:

```ps
cd vcpkg
.\bootstrap-vcpkg.bat
.\vcpkg.exe install ffmpeg[core,all]:x64-windows
```

You can pick another triplet, or another set of features. See the [ffmpeg vcpkg.json file](https://github.com/microsoft/vcpkg/blob/master/ports/ffmpeg/vcpkg.json) for a list of all features. The above will result in an LGPLv2 licensed ffmpeg library built with all LGPL compatible features that are supported in vcpkg.

Prebuilt LGPLv2 builds for Visual Studio 2019 can be found
[here](https://github.com/mcmtroffaes/ffmpeg-msvc-build/releases).
See the
[vcpkg export documentation](https://vcpkg.readthedocs.io/en/latest/users/integration/#export)
for more information on how to use these pre-built packages.

## License

All scripts for creating the builds are licensed under the conditions
of the [MIT license](LICENSE.txt).

The builds themselves are covered by the relevant license for your build
(see [here](https://ffmpeg.org/legal.html) for full details).
