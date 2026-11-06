#!/bin/bash
# dav1d 1.2.1 与 zlib 1.3.1(静态)，FFmpeg 之前编。
set -euo pipefail
. "$(dirname "$0")/env.sh"
cd $W/src
[ -d dav1d-1.2.1 ] || curl -sSfL https://code.videolan.org/videolan/dav1d/-/archive/1.2.1/dav1d-1.2.1.tar.bz2 | tar -xj
[ -d zlib-1.3.1 ] || curl -sSfL https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz | tar -xz
(cd dav1d-1.2.1 && rm -rf build && meson setup build --cross-file $W/cross.ini --prefix=$PREFIX --default-library=static --buildtype=release -Denable_tools=false -Denable_tests=false && ninja -C build install)
(cd zlib-1.3.1 && make -f win32/Makefile.gcc PREFIX=x86_64-w64-mingw32- CC=x86_64-w64-mingw32-clang && make -f win32/Makefile.gcc install BINARY_PATH=$PREFIX/bin INCLUDE_PATH=$PREFIX/include LIBRARY_PATH=$PREFIX/lib SHARED_MODE=0)
mkdir -p $PREFIX/include/EGL $PREFIX/include/KHR
for f in EGL/egl.h EGL/eglext.h EGL/eglext_angle.h EGL/eglplatform.h KHR/khrplatform.h; do
  curl -sSfL "https://raw.githubusercontent.com/google/angle/chromium/5993/include/$f" -o $PREFIX/include/$f
done
