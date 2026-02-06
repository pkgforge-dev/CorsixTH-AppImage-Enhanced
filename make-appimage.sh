#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q corsix-th-git | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.bg.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/scalable/apps/corsix-th.svg
export DESKTOP=/usr/share/applications/com.corsixth.corsixth.desktop
export DEPLOY_OPENGL=1
export DEPLOY_PIPEWIRE=1

# Deploy dependencies
quick-sharun /usr/bin/corsix-th \
/usr/lib/alsa-lib/libasound_module_pcm_a52.so \
/usr/lib/alsa-lib/libasound_module_pcm_jack.so \
/usr/lib/alsa-lib/libasound_module_pcm_oss.so \
/usr/lib/alsa-lib/libasound_module_pcm_speex.so \
/usr/lib/alsa-lib/libasound_module_pcm_upmix.so \
/usr/lib/alsa-lib/libasound_module_pcm_usb_stream.so \
/usr/lib/alsa-lib/libasound_module_pcm_vdownmix.so

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage
