#!/bin/bash
# libass 及其依赖(freetype、fribidi、harfbuzz)，静态库。版本与 libmpv-darwin-build v0.6.0 一致。
set -euo pipefail
. "$(dirname "$0")/env.sh"
"$W/fetch-sources.sh"
cd $W/src
M="--cross-file $W/cross.ini --prefix=$PREFIX --default-library=static --buildtype=release"
(cd freetype-2.13.2 && rm -rf build && meson setup build $M -Dbrotli=disabled -Dbzip2=disabled -Dharfbuzz=disabled -Dpng=disabled -Dzlib=disabled && ninja -C build install)
(cd fribidi-1.0.13 && rm -rf build && meson setup build $M -Ddocs=false -Dbin=false -Dtests=false && ninja -C build install)
(cd harfbuzz-8.1.1 && rm -rf build && meson setup build $M -Dtests=disabled -Ddocs=disabled -Dutilities=disabled -Dglib=disabled -Dgobject=disabled -Dcairo=disabled -Dicu=disabled -Dfreetype=enabled -Dgdi=disabled -Ddirectwrite=disabled && ninja -C build install)
(cd libass-0.17.1 && rm -rf build && mkdir build && cd build && ../configure --host=$HOST --prefix=$PREFIX --enable-static --disable-shared --disable-require-system-font-provider --enable-directwrite CC=x86_64-w64-mingw32-clang CXX=x86_64-w64-mingw32-clang++ && make -j10 && make install)
