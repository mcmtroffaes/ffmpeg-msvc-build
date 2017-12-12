# exit immediately upon error
set -e

MINOR=0
PATCH=2

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

get_version() {
	local folder
	local "${@}"
	echo -n "$(get_git_date folder=$folder).$MINOR.$PATCH-$(get_git_hash folder=$folder)"
}

cflags_runtime() {
	local runtime
	local configuration
	local "${@}"
	echo -n "-$runtime"
	case "$configuration" in
		release)
			echo ""
			;;
		debug)
			echo "d"
			;;
		*)
			return 1
	esac
}

target_id() {
	local base
	local extra
	local visual_studio
	local linkage
	local runtime
	local configuration
	local platform
	local "${@}"
	echo -n "$base-$(get_version folder=$base)"
	[[ !  -z  $extra  ]] && echo -n "-${extra}"
	echo -n "-$visual_studio-$linkage-$runtime-$configuration-$platform"
}

license_file() {
	local license
	local "${@}"
	case "$license" in
		lgpl21)
			echo "COPYING.LGPLv2.1"
			;;
		lgpl3)
			echo "COPYING.LGPLv3"
			;;
		gpl2)
			echo "COPYING.GPLv2"
			;;
		gpl3)
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
		lgpl21)
			;;
		lgpl3)
			echo "--enable-version3"
			;;
		gpl2)
			echo "--enable-gpl --enable-libx264"
			;;
		gpl3)
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
		release)
			echo "--disable-debug"
			;;
		debug)
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

	# install license file
	mkdir -p "$prefix/share/doc/ffmpeg"
	cp "ffmpeg/$(license_file license=$license)" "$prefix/share/doc/ffmpeg/license.txt"

	# run configure and save output (lists all enabled features and mentions license at the end)
	pushd ffmpeg
	# reduce clashing windows.h imports ("near", "Rectangle")
	sed -i 's/#include <windows.h>/#define Rectangle WindowsRectangle\n#include <windows.h>\n#undef Rectangle\n#undef near/' compat/atomics/win32/stdatomic.h
	./configure --toolchain=msvc $(ffmpeg_options prefix=$prefix license=$license linkage=$linkage runtime=$runtime configuration=$configuration) \
		> "$prefix/share/doc/ffmpeg/configure.txt" || (ls && tail -30 config.log && exit 1)
	cat "$prefix/share/doc/ffmpeg/configure.txt"
	#tail -30 config.log  # for debugging
	make
	make install
	# fix extension of static libraries
	if [ "$linkage" = "static" ]
	then
		pushd "$prefix/lib/"
		for file in *.a; do mv "$file" "${file/.a/.lib}"; done
		popd
	fi
	# move import libraries to lib folder
	if [ "$linkage" = "shared" ]
	then
		pushd "$prefix/bin/"
		for file in *.lib; do mv "$file" ../lib/; done
		popd
	fi
	# delete pkgconfig files (not useful for msvc)
	rm -rf "$prefix/lib/pkgconfig"
	# delete .def files (not useful for msvc)
	pushd "$prefix/lib/"
	for file in *.def; do rm "$file"; done
	popd
	popd
}

x264_options() {
	local prefix
	local runtime
	local configuration
	local "${@}"
	echo -n " --prefix=$prefix"
	echo -n " --disable-cli"
	echo -n " --enable-static"
	echo -n " --extra-cflags=$(cflags_runtime runtime=$runtime configuration=$configuration)"
}

function build_x264() {
	local runtime
	local configuration
	local platform
	local "${@}"
	local version=20170626.0.1
	local hash=ba24899
	local folder=x264-$version-$hash-$visual_studio-static-$runtime-$configuration-$platform
	curl -L "https://github.com/mcmtroffaes/x264-msvc-build/releases/download/$version/$folder.zip" -o $folder.zip
	7z x $folder.zip
	local prefix=$(readlink -f $folder)
	find "$prefix"  # prints paths of all files that have been unzipped
	INCLUDE="$INCLUDE;$(cygpath -w $prefix/include)"
	LIB="$LIB;$(cygpath -w $prefix/lib)"
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
	if [ "$license" = "gpl2" ] || [ "$license" = "gpl3" ]
	then
		build_x264 runtime=$runtime configuration=$configuration platform=$platform
	fi
	local ffmpeg_folder=$(target_id base="ffmpeg" extra="$license" visual_studio="$visual_studio" linkage="$linkage" runtime="$runtime" configuration="$configuration" platform="$platform")
	local ffmpeg_prefix=$(readlink -f $ffmpeg_folder)
	build_ffmpeg prefix=$ffmpeg_prefix license=$license linkage=$linkage runtime=$runtime configuration=$configuration
	make_zip folder=$ffmpeg_folder
	mv /usr/bin/link1 /usr/bin/link
}

get_appveyor_visual_studio() {
	case "$APPVEYOR_BUILD_WORKER_IMAGE" in
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
	license="${LICENSE,,}" \
	visual_studio=$(get_appveyor_visual_studio) \
	linkage="${LINKAGE,,}" \
	runtime="${RUNTIME_LIBRARY,,}" \
	configuration="${Configuration,,}" \
	platform="${Platform,,}"
