#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake           \
	doxygen         \
	fluidsynth      \
	libdecor        \
	pipewire-alsa   \
	pipewire-audio  \
	pipewire-jack   \
	rtmidi          \
	sdl2_mixer      \
	timidity++

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package
# make-aur-package zenity-rs-bin

# If the application needs to be manually built that has to be done down here
git clone https://github.com/CorsixTH/CorsixTH ./corsixth
cd ./corsixth

set --
if [ "${DEVEL_RELEASE-}" = 1 ]; then
	echo "Making nightly build of CorsixTH..."
	echo "---------------------------------------------------------------"
	pacman -S --noconfirm lua-filesystem lua-lpeg
	git rev-parse --short HEAD > ~/version
else
	echo "Making stable build of CorsixTH..."
	echo "---------------------------------------------------------------"
	pacman -S --noconfirm lua54 lua54-filesystem lua54-lpeg
	git fetch --tags origin
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version
	set -- \
		-DLUA_PROGRAM_PATH=/usr/bin/lua5.4    \
		-DLUA_INCLUDE_DIR=/usr/include/lua5.4 \
		-DLUA_LIBRARY=/usr/lib/liblua5.4.so
fi

mkdir ./build
cd ./build

cmake ../ \
	-DCMAKE_BUILD_TYPE=Release  \
	-DENABLE_UNIT_TESTS=OFF     \
	-DCMAKE_INSTALL_PREFIX=/usr \
	"$@"

make -j$(nproc)
make install
