#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook:sdl-soundfonts.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/CorsixTH/CorsixTH/refs/heads/master/CorsixTH/Original_Logo.svg
export DESKTOP=https://raw.githubusercontent.com/CorsixTH/CorsixTH/refs/heads/master/CorsixTH/com.corsixth.corsixth.desktop
export STARTUPWMCLASS=corsix-th
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1

# Deploy dependencies
quick-sharun /usr/bin/corsix-th /usr/lib/lua/*/lpeg.so /usr/lib/alsa-lib /usr/lib/libpulse-simple.so* /usr/lib/libfluidsynth.so*

cp -v /etc/timidity/timidity.cfg ./AppDir/bin
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env

# Additional changes can be done in between here
mkdir -p ./AppDir/share/soundfonts
wget https://raw.githubusercontent.com/Jacalz/fluid-soundfont/master/SF3/FluidR3.sf3 -O ./AppDir/share/soundfonts/FluidR3.sf3

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
