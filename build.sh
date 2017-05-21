# exit immediately upon error
set -e

# FOLDER
git_date() {
	pushd "$1" > /dev/null
	git show -s --format=%ci HEAD | sed 's/\([0-9]\{4\}\)-\([0-9][0-9]\)-\([0-9][0-9]\).*/\1\2\3/'
	popd > /dev/null
}

# FOLDER
git_hash() {
	pushd "$1" > /dev/null
	git show -s --format=%h HEAD
	popd > /dev/null
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
			echo "--enable-gpl --enable-libx264"
			;;
		GPL3)
			echo "--enable-gpl --enable-version3 --enable-libx264"
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

# CONFIGURATION
ffmpeg_options_debug() {
	case "$1" in
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

# PREFIX LICENSE LINKAGE RUNTIME_LIBRARY CONFIGURATION
ffmpeg_options () {
	echo -n "--disable-doc --enable-runtime-cpudetect"
	echo -n " --prefix=$1"
	echo -n " $(ffmpeg_options_license $2)"
	echo -n " $(ffmpeg_options_linkage $3)"
	echo -n " $(ffmpeg_options_runtime $4 $5)"
	echo -n " $(ffmpeg_options_debug $5)"
}

# BASE LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
target_id () {
	local toolset_=$(toolset "$3")
	local date_=$(git_date "$1")
	local hash_=$(git_hash "$1")
	echo "$1-${date_}-${hash_}-$2-${toolset_}-$4-$5-$6-$7" | tr '[:upper:]' '[:lower:]'
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

	# install license file
	mkdir -p "$abs1/share/doc/ffmpeg"
	cp "ffmpeg/$(license_file $2)" "$abs1/share/doc/ffmpeg/license.txt"

	# run configure and save output (lists all enabled features and mentions license at the end)
	pushd ffmpeg
	./configure --toolchain=msvc $(ffmpeg_options $abs1 $2 $3 $4 $5) \
		> "$abs1/share/doc/ffmpeg/configure.txt" || (tail -30 config.log && exit 1)
	cat "$abs1/share/doc/ffmpeg/configure.txt"
	#tail -30 config.log  # for debugging
	make
	make install
	# fix extension of static libraries
	if [ "$3" = "static" ]
	then
		for file in "$abs1/lib/*.a"; do mv "$file" "${file/.a/.lib}"; done
	fi
	# move import libraries to lib folder
	if [ "$3" = "shared" ]
	then
		for file in "$abs1/bin/*.lib"; do mv "$file" "$abs1/lib/$file"; done
	fi
	popd
}

# PREFIX RUNTIME_LIBRARY CONFIGURATION
x264_options () {
	echo -n " --prefix=$1"
	echo -n " --disable-cli"
	echo -n " --enable-static"
	echo -n " --extra-cflags=$(cflags_runtime $2 $3)"
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

# FOLDER
function make_zip() {
	7z a -tzip -r "$1.zip" $1
}

# PREFIX LICENSE LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
function make_nuget() {
	if [ "${6,,}" = "x86" ]
	then
		local platform="Win32"
	else
		local platform="x64"
	fi
	local fullnuspec="FFmpeg.$2.${3^}.$4.$5.${6,,}.nuspec"
	cat FFmpeg.nuspec.in \
		| sed "s/@FFMPEG_DATE@/$(git_date ffmpeg)/g" \
		| sed "s/@FFMPEG_HASH@/$(git_hash ffmpeg)/g" \
		| sed "s/@PREFIX@/$1/g" \
		| sed "s/@LICENSE@/$2/g" \
		| sed "s/@LINKAGE@/${3^}/g" \
		| sed "s/@RUNTIME_LIBRARY@/$4/g" \
		| sed "s/@CONFIGURATION@/$5/g" \
		| sed "s/@PLATFORM@/$platform/g" \
		> $fullnuspec
	cat $fullnuspec  # for debugging
	# postproc requires GPL license
	if [ "$2" = "LGPL21" ] || [ "$2" = "LGPL3" ]
	then
		cat FFmpeg.targets.in \
			| sed "s/;postproc.lib//g"
			> FFmpeg.targets
	else
		cp FFmpeg.targets.in FFmpeg.targets
	fi
	cat FFmpeg.targets  # for debugging
	nuget pack $fullnuspec
}

# LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
function make_all() {
	# ensure link.exe is the one from msvc
	mv /usr/bin/link /usr/bin/link1
	which link
	# ensure cl.exe can be called
	which cl
	cl
	if [ "$1" = "GPL2" ] || [ "$1" = "GPL3" ]
	then
		# LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
		local x264_prefix=$(target_id "x264" "GPL2" "$2" "static" "$4" "$5" "$6")
		# PREFIX RUNTIME_LIBRARY
		build_x264 "$x264_prefix" "$4" "$5"
	fi
	# LICENSE VISUAL_STUDIO LINKAGE RUNTIME_LIBRARY CONFIGURATION PLATFORM
	local ffmpeg_prefix=$(target_id "ffmpeg" "$1" "$2" "$3" "$4" "$5" "$6")
	# PREFIX LICENSE LINKAGE RUNTIME_LIBRARY CONFIGURATION
	build_ffmpeg "$ffmpeg_prefix" "$1" "$3" "$4" "$5"
	# FOLDER
	make_zip "$ffmpeg_prefix"
	# TODO fix static builds and enable nuget
	#make_nuget "$ffmpeg_prefix" "$1" "$3" "$4" "$5" "$6"
	mv /usr/bin/link1 /usr/bin/link
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
