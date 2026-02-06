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
make-aur-package corsix-th-git

# If the application needs to be manually built that has to be done down here
