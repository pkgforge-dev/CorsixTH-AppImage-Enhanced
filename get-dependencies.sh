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
    soundfont-fluid \
    timidity++

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package


# If the application needs to be manually built that has to be done down here
mkdir -p ./AppDir/share/soundfonts
mkdir -p ./AppDir/etc/timidity
cp /usr/share/soundfonts/FluidR3_GM.sf2 ./AppDir/share/soundfonts
cp /etc/timidity/timidity.cfg ./AppDir/etc/timidity
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
    cd ./CorsixTH
    cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_UNIT_TESTS=OFF -DCMAKE_INSTALL_PREFIX=/usr -DLUA_PROGRAM_PATH=/usr/bin/lua5.4 -DLUA_INCLUDE_DIR=/usr/include/lua5.4 -DLUA_LIBRARY=/usr/lib/liblua5.4.so .
    cd CorsixTH && make -j$(nproc)
    make install
fi
