#!/bin/bash
# 下载并核对全部源码包(SHA-256)，解压到 src/。已存在的目录跳过。各 build-*.sh 开头会调用它。
set -euo pipefail
. "$(dirname "$0")/env.sh"
mkdir -p $W/src/.dl && cd $W/src
fetch() { # <sha256> <url> <file> <dir>
  [ -d "$4" ] && return 0
  [ -f ".dl/$3" ] || curl -sSfL -o ".dl/$3" "$2"
  echo "$1  .dl/$3" | shasum -a 256 -c - >/dev/null || { echo "checksum mismatch: $3" >&2; rm -f ".dl/$3"; exit 1; }
  tar -xf ".dl/$3"
}
fetch a4003623cdc0109dec3aac8435520aa3fb12c4d69454fa227f2658cdb6dab5fa https://code.videolan.org/videolan/dav1d/-/archive/1.2.1/dav1d-1.2.1.tar.bz2 dav1d-1.2.1.tar.bz2 dav1d-1.2.1
fetch 9a93b2b7dfdac77ceba5a558a580e74667dd6fede4585b91eefb60f03b72df23 https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz zlib-1.3.1.tar.gz zlib-1.3.1
fetch 57be87c22d9b49c112b6d24bc67d42508660e6b718b3db89c44e47e289137082 https://ffmpeg.org/releases/ffmpeg-6.0.tar.xz ffmpeg-6.0.tar.xz ffmpeg-6.0
fetch 12991c4e55c506dd7f9b765933e62fd2be2e06d421505d7950a132e4f1bb484d https://downloads.sourceforge.net/project/freetype/freetype2/2.13.2/freetype-2.13.2.tar.xz freetype-2.13.2.tar.xz freetype-2.13.2
fetch 7fa16c80c81bd622f7b198d31356da139cc318a63fc7761217af4130903f54a2 https://github.com/fribidi/fribidi/releases/download/v1.0.13/fribidi-1.0.13.tar.xz fribidi-1.0.13.tar.xz fribidi-1.0.13
fetch b16e6bc0fc7e6a218583f40c7d201771f2e3072f85ef6e9217b36c1dc6b2aa25 https://github.com/harfbuzz/harfbuzz/archive/8.1.1.tar.gz harfbuzz-8.1.1.tar.gz harfbuzz-8.1.1
fetch f0da0bbfba476c16ae3e1cfd862256d30915911f7abaa1b16ce62ee653192784 https://github.com/libass/libass/releases/download/0.17.1/libass-0.17.1.tar.xz libass-0.17.1.tar.xz libass-0.17.1
fetch 926dce4dfb918cbbac603ad5d453d453d0036d1e00e77baaf5d76ca99ce7a419 https://github.com/mpv-player/mpv/archive/652a1dd907.tar.gz mpv-652a1dd907.tar.gz mpv-652a1dd90711839acdccc08004056d25514ef2d8
[ -f ffmpeg-6.0/.wt-patched ] || { patch -d ffmpeg-6.0 -p1 < $W/patches/ffmpeg-fix-fmp4-hls-seek-reset.patch; touch ffmpeg-6.0/.wt-patched; }
