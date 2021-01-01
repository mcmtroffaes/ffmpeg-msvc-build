# ffmpeg-msvc-build

[![appveyor build status](https://ci.appveyor.com/api/projects/status/rok7i2fbv5ptrwvm?svg=true)](https://ci.appveyor.com/project/mcmtroffaes/ffmpeg-msvc-build) [![travis build status](https://travis-ci.com/mcmtroffaes/ffmpeg-msvc-build.svg?branch=master)](https://travis-ci.com/mcmtroffaes/ffmpeg-msvc-build)

Scripts for building FFmpeg with MSVC on AppVeyor.

The script uses [vcpkg](https://github.com/microsoft/vcpkg)
which closely follows the [official
instructions](https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC).

## Requirements

* [Visual Studio](https://docs.microsoft.com/en-us/cpp/)
* [vcpkg](https://github.com/microsoft/vcpkg)

## Usage

Prebuilt static LGPL builds with Visual Studio 2019 can be found
[here](https://github.com/mcmtroffaes/ffmpeg-msvc-build/releases).
See the
[vcpkg export documentation](https://vcpkg.readthedocs.io/en/latest/users/integration/#export)
for more information on how to use these pre-built packages.

## License

All scripts for creating the builds are licensed under the conditions
of the [MIT license](LICENSE.txt).

The builds themselves are covered by the relevant license for your build
(see [here](https://www.gnu.org/licenses/) for full details).
