# print commands for debugging
set -x

OPTIONS="--disable-programs --disable-doc --enable-runtime-cpudetect"

case "$LINKAGE" in
	Dynamic)
		OPTIONS+=" --disable-static --enable-shared"
		;;
	Static)
		OPTIONS+=" --enable-static --disable-shared"
		;;
	*)
		echo "LINKAGE must be Dynamic or Static"
		exit 1
esac

case "$LICENSE" in
	LGPL2)
		;;
	LGPL3)
		OPTIONS+="  --enable-version3"
		;;
	GPL2)
		OPTIONS+=" --enable-gpl"
		;;
	GPL3)
		OPTIONS+=" --enable-gpl --enable-version3"
		;;
	*)
		echo "LICENSE must be LGPL2, LGPL3, GPL2, or GPL3"
		exit 1
esac

# note: bash is case sensitive; appveyor sets $Configuration instead of $CONFIGURATION
case "$Configuration" in
	Release)
		OPTIONS+=" --extra-cflags=-${RUNTIME_LIBRARY} --extra-cxxflags=-${RUNTIME_LIBRARY}"
		;;
	Debug)
		OPTIONS+=" --extra-cflags=-${RUNTIME_LIBRARY}d --extra-cxxflags=-${RUNTIME_LIBRARY}d"
		;;
	*)
		echo "CONFIGURATION must be Release or Debug"
		exit 1
esac

# print some environment variables for debugging
set +x
echo "------------------------------------------------------------------------"
echo "CONFIGURATION=$Configuration"
echo "LINKAGE=$LINKAGE"
echo "LICENSE=$LICENSE"
echo "RUNTIME_LIBRARY=$RUNTIME_LIBRARY"
echo "OPTIONS=$OPTIONS"
echo "------------------------------------------------------------------------"
echo "PATH=$PATH"
echo "INCLUDE=$INCLUDE"
echo "LIB=$LIB"
echo "LIBPATH=$LIBPATH"
echo "CL=$CL"
echo "_CL_=$_CL_"
echo "------------------------------------------------------------------------"
set -x

# ensure link.exe is the one from msvc
rm /usr/bin/link
which link

# ensure cl.exe can be called
which cl
cl

# run configure
cd $APPVEYOR_BUILD_FOLDER/ffmpeg
./configure --toolchain=msvc $OPTIONS

# print last 30 lines from config log file for debugging
tail -30 config.log

# run make
make
