#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    cmake          \
    doxygen        \
    fluidsynth     \
    freetype2      \
    libdecor       \
    pipewire-alsa  \
    pipewire-audio \
    pipewire-jack  \
    rtmidi         \
    sdl2_mixer

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package


# If the application needs to be manually built that has to be done down here
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of CorsixTH..."
    echo "---------------------------------------------------------------"
    make-aur-package corsix-th-git
    VERSION=$(pacman -Q corsix-th-git | awk '{print $2; exit}')
else
    echo "Making stable build of CorsixTH..."
    echo "---------------------------------------------------------------"
    REPO="https://github.com/CorsixTH/CorsixTH"
    VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//')"
    git clone --branch "$VERSION" --single-branch "$REPO" ./CorsixTH
    echo "${VERSION#v}" > ~/version

    pacman -S --noconfirm lua54 lua54-filesystem lua54-lpeg
    mkdir -p ./AppDir/bin
    cd ./CorsixTH
    cp -rv CorsixTH/Bitmap CorsixTH/Campaigns CorsixTH/Graphics CorsixTH/Levels CorsixTH/Lua CorsixTH/Luatest CorsixTH/CorsixTH.lua ../AppDir/bin
    cmake -DCMAKE_BUILD_TYPE=Release -DLUA_PROGRAM_PATH=/usr/bin/lua5.4 -DLUA_INCLUDE_DIR=/usr/include/lua5.4 -DLUA_LIBRARY=/usr/lib/liblua5.4.so -CMAKE_SOURCE_DIR=../AppDir/bin .
    make -j$(nproc)
    #mv -v CorsixTH/Bitmap CorsixTH/Campaigns CorsixTH/Graphics CorsixTH/Levels CorsixTH/Lua CorsixTH/Luatest CorsixTH/corsix-th ../AppDir/bin
    mv -v CorsixTH/corsix-th ../AppDir/bin
fi
