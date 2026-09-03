#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
	cmake          \
	doxygen        \
	fluidsynth     \
	pipewire-alsa  \
	pipewire-audio \
	pipewire-jack  \
	rtmidi         \
	sdl2_mixer     \
	sdl3_mixer	   \
	timidity++

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini libdecor-mini

REPO="https://github.com/CorsixTH/CorsixTH"
git clone "$REPO" ./corsixth
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
	TAG=$(git tag --sort=-v:refname | grep -vi 'rc\|alpha\|beta' | head -1)
	git checkout "$TAG"
	echo "$TAG" > ~/version
	set -- \
		-DLUA_PROGRAM_PATH=/usr/bin/lua5.4    \
		-DLUA_INCLUDE_DIR=/usr/include/lua5.4 \
		-DLUA_LIBRARY=/usr/lib/liblua5.4.so
fi

cmake -S ./ -B build \
	-DCMAKE_BUILD_TYPE=Release  \
	-DENABLE_UNIT_TESTS=OFF     \
	-DCMAKE_INSTALL_PREFIX=/usr \
	"$@"
cmake --build build -j$(nproc)
cmake --install build
