# exit immediately upon error
set -e

ffmpeg_date() {
	cd ffmpeg
	git show -s --format=%ci HEAD | sed 's/\([0-9]\{4\}\)-\([0-9][0-9]\)-\([0-9][0-9]\).*/\1\2\3/'
	cd ..
}

ffmpeg_hash() {
	cd ffmpeg
	git show -s --format=%t HEAD
	cd ..
}

# VISUAL_STUDIO
toolset () {
	case "$1" in
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

# LICENSE
license_file () {
	case "$1" in
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

# LICENSE
ffmpeg_options_license() {
	case "$1" in
		LGPL21)
			;;
		LGPL3)
			echo "--enable-version3"
			;;
		GPL2)
			echo "--enable-gpl"
			;;
		GPL3)
			echo "--enable-gpl --enable-version3"
			;;
		*)
			return 1
	esac
}

# LINKAGE
ffmpeg_options_linkage() {
	case "$1" in
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

# RUNTIME_LIBRARY CONFIGURATION
cflags_runtime() {
	echo -n "-$1" | tr '[:lower:]' '[:upper:]'
	case "$2" in
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

# RUNTIME_LIBRARY CONFIGURATION
ffmpeg_options_runtime() {
	cflags=`cflags_runtime $1 $2`
	echo "--extra-cflags=$cflags --extra-cxxflags=$cflags"
}

# PREFIX LICENSE LINKAGE RUNTIME_LIBRARY CONFIGURATION
ffmpeg_options () {
	echo -n "--disable-programs --disable-doc --enable-runtime-cpudetect"
	echo -n " --prefix=$1"
	echo -n " $(ffmpeg_options_license $2)"
	echo -n " $(ffmpeg_options_linkage $3)"
	echo -n " $(ffmpeg_options_runtime $4 $5)"
}

# LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
target_id () {
	local ts=$(toolset "$2")
	echo "ffmpeg-$(ffmpeg_date)-$(ffmpeg_hash)-$1-$ts-$3-$4-$5-$6" | tr '[:upper:]' '[:lower:]'
}

# assumes we are in the ffmpeg folder
# PREFIX LICENSE LINKAGE RUNTIME_LIBRARY CONFIGURATION
function build_ffmpeg() {
	echo "==============================================================================="
	echo "build_ffmpeg"
	echo "==============================================================================="
	echo "PREFIX=$1"
	echo "LICENSE=$2"
	echo "LINKAGE=$3"
	echo "RUNTIME_LIBRARY=$4"
	echo "CONFIGURATION=$5"
	echo "-------------------------------------------------------------------------------"
	echo "PATH=$PATH"
	echo "INCLUDE=$INCLUDE"
	echo "LIB=$LIB"
	echo "LIBPATH=$LIBPATH"
	echo "CL=$CL"
	echo "_CL_=$_CL_"
	echo "-------------------------------------------------------------------------------"

	# find absolute path for prefix
	local abs1=$(readlink -f $1)

	# ensure link.exe is the one from msvc
	mv /usr/bin/link /usr/bin/link1
	which link

	# ensure cl.exe can be called
	which cl
	cl

	# install license file
	mkdir -p "$abs1/share/doc"
	cp "ffmpeg/$(license_file $2)" "$abs1/share/doc/ffmpeg-license.txt"

	# run configure and save output (lists all enabled features and mentions license at the end)
	pushd ffmpeg
	./configure --toolchain=msvc $(ffmpeg_options $abs1 $2 $3 $4 $5) \
		> "$abs1/share/doc/ffmpeg-configure.txt"
	cat "$abs1/share/doc/ffmpeg-configure.txt"
	#tail -30 config.log  # for debugging
	make
	make install
	popd

	mv /usr/bin/link1 /usr/bin/link
}

# FOLDER
function make_zip() {
	7z a -tzip -r "$1.zip" $1
}

# LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
function make_all() {
	# LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
	local prefix=$(target_id "$1" "$2" "$3" "$4" "$5" "$6")
	# PREFIX LICENSE LINKAGE RUNTIME_LIBRARY CONFIGURATION
	build_ffmpeg "$prefix" "$1" "$3" "$4" "$5"
	# FOLDER
	make_zip "$prefix"
}


function appveyor_main() {
	# bash starts in msys home folder, so first go to project folder
	cd $(cygpath "$APPVEYOR_BUILD_FOLDER")
	make_all "$LICENSE" "$APPVEYOR_BUILD_WORKER_IMAGE" \
		"$LINKAGE" "$RUNTIME_LIBRARY" "$Configuration" "$Platform"
}

function local_main() {
	make_all "$LICENSE" "$VISUAL_STUDIO" \
		"$LINKAGE" "$RUNTIME_LIBRARY" "$CONFIGURATION" "$PLATFORM"
}

set -x
appveyor_main
