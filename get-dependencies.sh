#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    doxygen        \
    fluidsynth     \
    libdecor       \
    pipewire-alsa  \
    pipewire-audio \
    pipewire-jack  \
    rtmidi

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package


# If the application needs to be manually built that has to be done down here
if [ "${DEVEL_RELEASE-}" = 1 ]; then
    echo "Making nightly build of CorsixTH..."
    echo "---------------------------------------------------------------"
    make-aur-package corsix-th-git
else
    echo "Making stable build of CorsixTH..."
    echo "---------------------------------------------------------------"
    REPO="https://github.com/CorsixTH/CorsixTH"
    VERSION="$(git ls-remote --tags --sort="v:refname" "$REPO" | tail -n1 | sed 's/.*\///; s/\^{}//')"
    git clone --branch "$VERSION" --single-branch --recursive --depth 1 "$REPO" ./CorsixTH
    echo "$VERSION" > ~/version

    mkdir -p ./AppDir/bin
    cd ./CorsixTH
fi
