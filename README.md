# ffmpeg-msvc-build

[![Build status](https://ci.appveyor.com/api/projects/status/rok7i2fbv5ptrwvm?svg=true)](https://ci.appveyor.com/project/mcmtroffaes/ffmpeg-msvc-build)

Scripts for building FFmpeg with MSVC on AppVeyor.

The script closely follows the [official instructions](https://trac.ffmpeg.org/wiki/CompilationGuide/MSVC). By default, only static LGPL builds are generated (in 32 and 64 bit, and in debug and release configurations). However, the build matrix can be easily modified to allow different configurations to be built as well.
