# exit immediately upon error
set -e

function make_zip() {
	local folder
	local "${@}"
	find "$folder"  # prints paths of all files to be zipped
	7z a -tzip -r "$folder.zip" $folder
}

get_git_date() {
	local folder
	local "${@}"
	pushd "$folder" > /dev/null
	git show -s --format=%ci HEAD | sed 's/\([0-9]\{4\}\)-\([0-9][0-9]\)-\([0-9][0-9]\).*/\1\2\3/'
	popd > /dev/null
}

get_git_hash() {
	local folder
	local "${@}"
	pushd "$folder" > /dev/null
	git show -s --format=%h HEAD
	popd > /dev/null
}

cflags_runtime() {
	local runtime
	local configuration
	local "${@}"
	echo -n "-$runtime" | tr '[:lower:]' '[:upper:]'
	case "$configuration" in
		Release)
			echo ""
			;;
		Debug)
			echo "d"
			;;
		*)
			return 1
	esac
}

target_id() {
	local base
	local license
	local visual_studio
	local linkage
	local runtime
	local configuration
	local platform
	local "${@}"
	local date_=$(get_git_date folder="$base")
	local hash_=$(get_git_hash folder="$base")
	echo "${base}-${date_}-${hash_}-${license}-${visual_studio}-${linkage}-${runtime}-${configuration}-${platform}" | tr '[:upper:]' '[:lower:]'
}

license_file() {
	local license
	local "${@}"
	case "$license" in
		LGPL21)
			echo "COPYING.LGPLv2.1"
			;;
		LGPL3)
			echo "COPYING.LGPLv3"
			;;
		GPL2)
			echo "COPYING.GPLv2"
			;;
		GPL3)
			echo "COPYING.GPLv3"
			;;
		*)
			return 1
	esac
}

ffmpeg_options_license() {
	local license
	local "${@}"
	case "$license" in
		LGPL21)
			;;
		LGPL3)
			echo "--enable-version3"
			;;
		GPL2)
			echo "--enable-gpl --enable-libx264"
			;;
		GPL3)
			echo "--enable-gpl --enable-version3 --enable-libx264"
			;;
		*)
			return 1
	esac
}

ffmpeg_options_linkage() {
	local linkage
	local "${@}"
	case "$linkage" in
		shared)
			echo "--disable-static --enable-shared"
			;;
		static)
			echo "--enable-static --disable-shared"
			;;
		*)
			return 1
	esac
}

ffmpeg_options_runtime() {
	local runtime
	local configuration
	local "${@}"
	local cflags=`cflags_runtime runtime="$runtime" configuration="$configuration"`
	echo "--extra-cflags=$cflags --extra-cxxflags=$cflags"
}

ffmpeg_options_debug() {
	local configuration
	local "${@}"
	case "$configuration" in
		Release)
			echo "--disable-debug"
			;;
		Debug)
			echo ""
			;;
		*)
			return 1
	esac
}

ffmpeg_options() {
	local prefix
	local license
	local linkage
	local runtime
	local configuration
	local "${@}"
	echo -n "--disable-doc --enable-runtime-cpudetect"
	echo -n " --prefix=$prefix"
	echo -n " $(ffmpeg_options_license license=$license)"
	echo -n " $(ffmpeg_options_linkage linkage=$linkage)"
	echo -n " $(ffmpeg_options_runtime runtime=$runtime configuration=$configuration)"
	echo -n " $(ffmpeg_options_debug configuration=$configuration)"
}

# assumes we are in the ffmpeg folder
function build_ffmpeg() {
	local prefix
	local license
	local linkage
	local runtime
	local configuration
	local "${@}"
	echo "==============================================================================="
	echo "build_ffmpeg"
	echo "==============================================================================="
	echo "PREFIX=$prefix"
	echo "LICENSE=$license"
	echo "LINKAGE=$linkage"
	echo "RUNTIME_LIBRARY=$runtime"
	echo "CONFIGURATION=$configuration"
	echo "-------------------------------------------------------------------------------"
	echo "PATH=$PATH"
	echo "INCLUDE=$INCLUDE"
	echo "LIB=$LIB"
	echo "LIBPATH=$LIBPATH"
	echo "CL=$CL"
	echo "_CL_=$_CL_"
	echo "-------------------------------------------------------------------------------"

	# find absolute path for prefix
	local abs1=$(readlink -f $prefix)

	# install license file
	mkdir -p "$abs1/share/doc/ffmpeg"
	cp "ffmpeg/$(license_file license=$license)" "$abs1/share/doc/ffmpeg/license.txt"

	# run configure and save output (lists all enabled features and mentions license at the end)
	pushd ffmpeg
	# reduce clashing windows.h imports ("near", "Rectangle")
	sed -i 's/#include <windows.h>/#define Rectangle WindowsRectangle\n#include <windows.h>\n#undef Rectangle\n#undef near/' compat/atomics/win32/stdatomic.h
	# temporary fix for C99 syntax error on msvc, patch already on mailing list
	sed -i 's/MXFPackage packages\[2\] = {};/MXFPackage packages\[2\] = {{0}};/' libavformat/mxfenc.c
	./configure --toolchain=msvc $(ffmpeg_options prefix=$abs1 license=$license linkage=$linkage runtime=$runtime configuration=$configuration) \
		> "$abs1/share/doc/ffmpeg/configure.txt" || (ls && tail -30 config.log && exit 1)
	cat "$abs1/share/doc/ffmpeg/configure.txt"
	#tail -30 config.log  # for debugging
	make
	make install
	# fix extension of static libraries
	if [ "$linkage" = "static" ]
	then
		pushd "$abs1/lib/"
		for file in *.a; do mv "$file" "${file/.a/.lib}"; done
		popd
	fi
	# move import libraries to lib folder
	if [ "$linkage" = "shared" ]
	then
		pushd "$abs1/bin/"
		for file in *.lib; do mv "$file" ../lib/; done
		popd
	fi
	popd
}

# PREFIX RUNTIME_LIBRARY CONFIGURATION
x264_options() {
	echo -n " --prefix=$1"
	echo -n " --disable-cli"
	echo -n " --enable-static"
	echo -n " --extra-cflags=$(cflags_runtime runtime=$2 configuration=$3)"
}

# PREFIX RUNTIME_LIBRARY CONFIGURATION
function build_x264() {
	# find absolute path for prefix
	local abs1=$(readlink -f $1)

	pushd x264
	# use latest config.guess to ensure that we can detect msys2
	curl "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" > config.guess
	# hotpatch configure script so we get the right compiler, compiler_style, and compiler flags
	sed -i 's/host_os = mingw/host_os = msys/' configure
	CC=cl ./configure $(x264_options $abs1 $2 $3) || (tail -30 config.log && exit 1)
	make
	make install
	INCLUDE="$INCLUDE;$(cygpath -w $abs1/include)"
	LIB="$LIB;$(cygpath -w $abs1/lib)"
	popd
}

function make_all() {
	local license
	local visual_studio
	local linkage
	local runtime
	local configuration
	local platform
	local "${@}"
	# ensure link.exe is the one from msvc
	mv /usr/bin/link /usr/bin/link1
	which link
	# ensure cl.exe can be called
	which cl
	cl
	if [ "$license" = "GPL2" ] || [ "$license" = "GPL3" ]
	then
		local x264_prefix=$(target_id base="x264" license="GPL2" visual_studio="$visual_studio" linkage="static" runtime="$runtime" configuration="$configuration" platform="$platform")
		# PREFIX RUNTIME_LIBRARY
		#build_x264 "$x264_prefix" "$runtime" "$configuration"
	fi
	local ffmpeg_prefix=$(target_id base="ffmpeg" license="$license" visual_studio="$visual_studio" linkage="$linkage" runtime="$runtime" configuration="$configuration" platform="$platform")
	build_ffmpeg prefix="$ffmpeg_prefix" license="$license" linkage="$linkage" runtime="$runtime" configuration="$configuration"
	make_zip folder="$ffmpeg_prefix"
	mv /usr/bin/link1 /usr/bin/link
}

get_appveyor_visual_studio() {
	local visual_studio_fullname
	local "${@}"
	case "$visual_studio" in
		Visual\ Studio\ 2013)
			echo -n "v120"
			;;
		Visual\ Studio\ 2015)
			echo -n "v140"
			;;
		Visual\ Studio\ 2017)
			echo -n "v141"
			;;
		*)
			return 1
	esac
}

set -xe
# bash starts in msys home folder, so first go to project folder
cd $(cygpath "$APPVEYOR_BUILD_FOLDER")
make_all \
	license="$LICENSE" \
	visual_studio="$(get_appveyor_visual_studio visual_studio_fullname=$APPVEYOR_BUILD_WORKER_IMAGE)" \
	linkage="$LINKAGE" \
	runtime="$RUNTIME_LIBRARY" \
	configuration="$Configuration" \
	platform="$Platform"