#!/bin/bash
# mpv 652a1dd907(与 media-kit 2023-09-24 版 libmpv-2.dll 同一提交)：只编 libmpv-2.dll，LGPL，egl-angle + d3d11va 硬解，依赖静态链接。
set -euo pipefail
. "$(dirname "$0")/env.sh"
"$W/fetch-sources.sh"
cd $W/src/mpv-652a1dd90711839acdccc08004056d25514ef2d8
rm -rf build
# 源码包没有 .git：别让 vcs_tag 找到外层仓库，版本号取 VERSION(与 media-kit 2023-09-24 版同一提交)。
export GIT_CEILING_DIRECTORIES=$W/src
echo "0.36.0-403-g652a1dd907" > VERSION
grep -q "<mmreg.h>" audio/out/ao_wasapi_utils.c || patch -p1 < $W/patches/mpv-wasapi-include-mmreg.patch
grep -q '"osdep/io.h"' audio/out/ao_pcm.c || patch -p1 < $W/patches/mpv-ao-pcm-utf8-path.patch
meson setup build --cross-file $W/cross.ini --prefix=$PREFIX --buildtype=release -Db_ndebug=true \
  --default-library=shared -Dprefer_static=true -Dc_link_args="-static" -Dcpp_link_args="-static" \
  -Dlibmpv=true -Dcplayer=false -Dgpl=false -Dtests=false \
  -Degl-angle=enabled -Dd3d-hwaccel=enabled -Dgl=enabled -Dgl-win32=enabled \
  -Dd3d11=disabled -Dshaderc=disabled -Dspirv-cross=disabled -Dvulkan=disabled -Dlibplacebo=disabled \
  -Dlua=disabled -Djavascript=disabled -Duchardet=disabled -Dlcms2=disabled -Diconv=disabled -Dlibarchive=disabled \
  -Ddvdnav=disabled -Dlibbluray=disabled -Dcdda=disabled -Drubberband=disabled -Dzimg=disabled -Dsdl2-audio=disabled -Dsdl2-video=disabled \
  -Dopenal=disabled -Dpdf-build=disabled -Dmanpage-build=disabled -Dhtml-build=disabled
ninja -C build
mkdir -p $W/out/include/mpv
cp build/libmpv-2.dll build/libmpv.dll.a $W/out/
cp libmpv/client.h libmpv/render.h libmpv/render_gl.h libmpv/stream_cb.h $W/out/include/mpv/
x86_64-w64-mingw32-strip $W/out/libmpv-2.dll
