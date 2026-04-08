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
    soundfont-fluid

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano ffmpeg-mini

# Comment this out if you need an AUR package


# If the application needs to be manually built that has to be done down here
mkdir -p ./AppDir/share/soundfonts
cp /usr/share/soundfonts/FluidR3_GM.sf2 ./AppDir/share/soundfonts
REPO="https://github.com/CorsixTH/CorsixTH"
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of CorsixTH..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote "$REPO" HEAD | cut -c 1-9 | head -1)"
    git clone "$REPO" ./CorsixTH
    echo "$VERSION" > ~/version

    pacman -S --noconfirm lua lua-filesystem lua-lpeg
    mkdir -p ./AppDir/bin
    cd ./CorsixTH
    cmake . \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_UNIT_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DLUA_PROGRAM_PATH=/usr/bin/lua \
        -DLUA_INCLUDE_DIR=/usr/include/lua \
        -DLUA_LIBRARY=/usr/lib/liblua5.5.so

    cd CorsixTH && make -j$(nproc)
    make install
else
    echo "Making stable build of CorsixTH..."
    echo "---------------------------------------------------------------"
    VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//')"
    git clone --branch "$VERSION" --single-branch "$REPO" ./CorsixTH
    echo "${VERSION#v}" > ~/version

    pacman -S --noconfirm lua54 lua54-filesystem lua54-lpeg timidity++
    mkdir -p ./AppDir/bin
    cp /etc/timidity/timidity.cfg ./AppDir/bin
    
    cd ./CorsixTH
    cmake . \
        -DCMAKE_BUILD_TYPE=Release \
        -DENABLE_UNIT_TESTS=OFF \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DLUA_PROGRAM_PATH=/usr/bin/lua5.4 \
        -DLUA_INCLUDE_DIR=/usr/include/lua5.4 \
        -DLUA_LIBRARY=/usr/lib/liblua5.4.so

    cd CorsixTH && make -j$(nproc)
    make install
fi
