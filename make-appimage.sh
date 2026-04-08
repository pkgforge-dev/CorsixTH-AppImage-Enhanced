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
quick-sharun /usr/bin/corsix-th /usr/lib/lua/*/lpeg.so \
/usr/lib/alsa-lib/libasound_module_pcm_pipewire.so \
/usr/lib/alsa-lib/libasound_module_rate_lavrate.so \
/usr/lib/alsa-lib/libasound_module_rate_samplerate.so \
/usr/lib/alsa-lib/libasound_module_rate_speexrate.so \
/usr/lib/alsa-lib/libasound_module_pcm_jack.so \
/usr/lib/alsa-lib/libasound_module_pcm_oss.so \
/usr/lib/alsa-lib/libasound_module_pcm_a52.so \
/usr/lib/alsa-lib/libasound_module_pcm_speex.so \
/usr/lib/alsa-lib/libasound_module_pcm_upmix.so \
/usr/lib/alsa-lib/libasound_module_pcm_vdownmix.so \
/usr/lib/alsa-lib/libasound_module_pcm_usb_stream.so

echo 'SDL_SOUNDFONTS=${SHARUN_DIR}/share/soundfonts/FluidR3_GM.sf2' >> ./AppDir/.env
echo 'SHARUN_WORKING_DIR=${SHARUN_DIR}/bin' >> ./AppDir/.env

# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
