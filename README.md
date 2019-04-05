# ffmpeg-msvc-build

[![Build status](https://ci.appveyor.com/api/projects/status/rok7i2fbv5ptrwvm?svg=true)](https://ci.appveyor.com/project/mcmtroffaes/ffmpeg-msvc-build)

Scripts for building FFmpeg with MSVC on AppVeyor.

The script closely follows the [official
instructions](https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC). By
default, only static LGPL builds are generated (in 32 and 64 bit, and
in debug and release configurations). However, the build matrix can be
easily modified to allow different configurations to be built as well.

## Requirements

* [NASM](https://www.nasm.us/)
* [Visual Studio](https://docs.microsoft.com/en-us/cpp/)
* [MSYS2](https://www.msys2.org/) (needs to be installed at ``C:\msys64\``)

## Usage

Prebuilt static LGPL builds with Visual Studio 2017 (toolset v141) can be found [here](https://github.com/mcmtroffaes/ffmpeg-msvc-build/releases). If you want to build your own version on your local machine, then:

  * Ensure nasm is in your path; if not, add it.
  * Set the following variables:
      - APPVEYOR_BUILD_FOLDER (should be set to the project folder where ``build.sh`` resides)
      - TOOLSET (v120, v140, v141)
      - PLATFORM (x86, x64)
      - CONFIGURATION (Release, Debug)
      - LINKAGE (shared, static)
      - RUNTIME_LIBRARY (MD, MT)
      - LICENSE (LGPL21, LGPL3, GPL2, GPL3)
  * Start the build script by running ``build.bat``.

## License

All scripts for creating the builds are licensed under the conditions
of the [MIT license](LICENSE.txt). For the examples in the
[examples](examples) folder, see individual files for license details.

The builds themselves are covered by the relevant license for your build
(see [here](https://www.gnu.org/licenses/) for full details).
