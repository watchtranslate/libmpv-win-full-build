# libmpv-win-full-build

WatchTranslate 的 Windows `libmpv-2.dll`：所有 FFmpeg 解码器、解复用器、解析器都开着（App 仓库决策 0125），给 media_kit 的 Windows 插件用。

为什么要自己编：media-kit 的 `libmpv-win32-video-build` 2023-09-24 版是精简 FFmpeg，缺 prores、cinepak、adpcm、nellymoser、rv、dnxhd、ffv1 等解码器，
也认不出 MXF、DV。用户硬盘里这类文件在 Windows App 上放不了，音频解不了时连取音翻译也做不了。

## 组成

| 组件 | 版本 | 说明 |
|---|---|---|
| mpv | `652a1dd907`（0.36.0-403，与 media-kit 2023-09-24 版同一提交） | 只编 libmpv；LGPL（`-Dgpl=false`）；egl-angle、d3d11va 硬解、gl-win32；补丁 `patches/mpv-wasapi-include-mmreg.patch`（新版 mingw-w64 头文件需要）、`patches/mpv-ao-pcm-utf8-path.patch`（ao_pcm 用 CRT 窄字符 `fopen`，PCM 输出路径含中文等非 ASCII 字符时打不开；改走 `mp_fopen`。App 取音靠它把 PCM 写进用户目录） |
| FFmpeg | n6.0 | LGPL v3，全部解码器/解复用器/解析器，dav1d、zlib、schannel、d3d11va/dxva2；补丁 `patches/ffmpeg-fix-fmp4-hls-seek-reset.patch`（上游 380a518c 回移，与 Android/iOS/macOS 相同） |
| dav1d | 1.2.1 | 静态 |
| zlib | 1.3.1 | 静态 |
| freetype / fribidi / harfbuzz / libass | 2.13.2 / 1.0.13 / 8.1.1 / 0.17.1 | 静态，与 libmpv-darwin-build v0.6.0 相同 |
| ANGLE EGL 头文件 | google/angle `chromium/5993` | 只用头文件 |
| 工具链 | llvm-mingw 20261104（UCRT，macOS universal） | 在 Apple Silicon Mac 上原生交叉编译 |

产物只依赖 Windows 系统 DLL（含 UCRT），C++ 运行库静态链接。

## 构建（macOS）

```sh
# 一次性：llvm-mingw 解到本目录；meson/ninja/nasm 在 PATH 上（env.sh 里写了本机路径，换机器改 env.sh）
./fetch-sources.sh # 全部源码包，按 SHA-256 核对(各 build 脚本也会先调用它)
./build-deps.sh    # dav1d、zlib、ANGLE 头文件
./build-ffmpeg.sh
./build-ass.sh
./build-mpv.sh      # 产物：out/libmpv-2.dll、out/libmpv.dll.a、out/include/mpv/*.h
```

## 发布

release 资产是与 media-kit 同样布局的 7z（`libmpv-2.dll`、`libmpv.dll.a`、`include/mpv/*.h`），App 的
`third_party/media_kit_libs_windows_video` 按 SHA-256 下载。

## 工具链与可复现性

- llvm-mingw `20261104`：`llvm-mingw-20261104-ucrt-macos-universal.tar.xz`（github.com/mstorsjo/llvm-mingw），解到本目录。
- meson 1.2.3、ninja、nasm 2.16.03；`env.sh` 里写的是作者本机路径，换机器时改 PATH。
- ANGLE 头文件取自 google/angle `chromium/5993` 分支（只用头文件，不进 dll 的代码）。
- 打包：`cd out && 7zz a -t7z -mx=9 ../mpv-dev-x86_64-<版本>.7z include libmpv-2.dll libmpv.dll.a`。

## 许可

本仓库的脚本按 MIT 发布。产物 `libmpv-2.dll` 含 mpv（LGPL-2.1+，`-Dgpl=false`）与 FFmpeg（LGPL-3.0+，`--disable-gpl --disable-nonfree --enable-version3`），
以及 dav1d（BSD-2）、zlib（zlib）、freetype（FTL）、fribidi（LGPL-2.1+）、harfbuzz（MIT）、libass（ISC）；对应源码版本和补丁就是本仓库的 `fetch-sources.sh` 与 `patches/`。
与旧版相比没有编入：libxml2（DASH 解复用器）、NVDEC/CUDA/QSV、libarchive、uchardet、iconv、lcms2、zimg、spirv-cross/d3d11 vo、avdevice；TLS 用系统 schannel。
