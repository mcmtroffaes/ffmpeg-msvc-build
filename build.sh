# print some environment variables for debugging
echo "PATH=$PATH"
echo "INCLUDE=$INCLUDE"
echo "LIB=$LIB"
echo "LIBPATH=$LIBPATH"
echo "CL=$CL"
echo "_CL_=$_CL_"

# print commands for debugging
set -x

# ensure link.exe is the one from msvc
rm /usr/bin/link
which link

# ensure cl.exe can be called
which cl
cl

# run configure
cd $APPVEYOR_BUILD_FOLDER/ffmpeg
./configure --toolchain=msvc --disable-ffmpeg --disable-ffprobe --disable-doc --enable-runtime-cpudetect --disable-static --enable-shared --disable-debug --extra-cflags=-MD --extra-cxxflags=-MD

# print last 30 lines from config log file for debugging
tail -30 config.log

# run make
make
