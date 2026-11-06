#!/bin/bash
# FFmpeg n6.0：全部解码器/解复用器/解析器(LGPL v3)，fMP4 HLS 定位补丁，dav1d、zlib、schannel、d3d11va/dxva2。静态库装进 $PREFIX。
set -euo pipefail
. "$(dirname "$0")/env.sh"
"$W/fetch-sources.sh"
cd $W/src
rm -rf ffmpeg-6.0/build && mkdir ffmpeg-6.0/build && cd ffmpeg-6.0/build
../configure --prefix=$PREFIX --target-os=mingw32 --arch=x86_64 --cross-prefix=x86_64-w64-mingw32- \
  --cc=x86_64-w64-mingw32-clang --cxx=x86_64-w64-mingw32-clang++ --enable-cross-compile --pkg-config=pkg-config --pkg-config-flags=--static \
  --extra-cflags="-I$PREFIX/include $CFLAGS" --extra-ldflags="-L$PREFIX/lib" \
  --disable-gpl --disable-nonfree --enable-version3 --enable-static --disable-shared --disable-programs --disable-doc --disable-debug \
  --disable-encoders --disable-muxers --disable-devices --disable-avdevice --disable-postproc \
  --enable-encoder=mjpeg,png --enable-muxer=image2 \
  --enable-libdav1d --enable-zlib --enable-schannel --enable-d3d11va --enable-dxva2 --enable-hwaccels --enable-runtime-cpudetect \
  --disable-autodetect --enable-w32threads
make -j10
make install
