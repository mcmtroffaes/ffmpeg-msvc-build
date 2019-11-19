# ffmpeg-msvc-build

[![Build status](https://ci.appveyor.com/api/projects/status/rok7i2fbv5ptrwvm?svg=true)](https://ci.appveyor.com/project/mcmtroffaes/ffmpeg-msvc-build)

Scripts for building FFmpeg with MSVC on AppVeyor.

The script uses [vcpkg](https://github.com/microsoft/vcpkg)
which closely follows the [official
instructions](https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC). By
default, only static LGPL builds are generated (in 32 and 64 bit, and
in debug and release configurations). However, the build matrix can be
easily modified to allow different configurations to be built as well.

## Requirements

* [Visual Studio](https://docs.microsoft.com/en-us/cpp/)
* [vcpkg](https://github.com/microsoft/vcpkg)

## Usage

Prebuilt static LGPL builds with Visual Studio 2019 (toolset v142) can be found [here](https://github.com/mcmtroffaes/ffmpeg-msvc-build/releases). If you want to build your own version on your local machine, then execute the build script as follows:

```
.\build.ps1 `
  -platform {x86,x64} `
  -runtime_library {MT,MD} `
  -linkage {dynamic,static} `
  -toolset {v120,v140,v141,v142,...} `
  -features {core,vpx,...}
```

## License

All scripts for creating the builds are licensed under the conditions
of the [MIT license](LICENSE.txt). For the examples in the
[examples](examples) folder, see individual files for license details.

The builds themselves are covered by the relevant license for your build
(see [here](https://www.gnu.org/licenses/) for full details).
