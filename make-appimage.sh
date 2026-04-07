#!/bin/sh

set -eu

ARCH=$(uname -m)
export ARCH
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=https://raw.githubusercontent.com/CorsixTH/CorsixTH/refs/heads/master/CorsixTH/Original_Logo.svg
export DESKTOP=https://raw.githubusercontent.com/CorsixTH/CorsixTH/refs/heads/master/CorsixTH/com.corsixth.corsixth.desktop
export STARTUPWMCLASS=corsix-th
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1

# Deploy dependencies
#if [ "${DEVEL_RELEASE-}" = 1 ]; then
  quick-sharun /usr/bin/corsix-th /usr/lib/lua/*/lpeg.so
#else
#  quick-sharun ./AppDir/bin/* /usr/lib/lua/*/lpeg.so
  #echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env
#fi

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
