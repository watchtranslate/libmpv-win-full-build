# libmpv-win-full-build

WatchTranslate 的 Windows `libmpv-2.dll`：所有 FFmpeg 解码器、解复用器、解析器都开着（App 仓库决策 0125），给 media_kit 的 Windows 插件用。

为什么要自己编：media-kit 的 `libmpv-win32-video-build` 2023-09-24 版是精简 FFmpeg，缺 prores、cinepak、adpcm、nellymoser、rv、dnxhd、ffv1 等解码器，
也认不出 MXF、DV。用户硬盘里这类文件在 Windows App 上放不了，音频解不了时连取音翻译也做不了。

## 组成

| 组件 | 版本 | 说明 |
|---|---|---|
| mpv | `652a1dd907`（0.36.0-403，与 media-kit 2023-09-24 版同一提交） | 只编 libmpv；LGPL（`-Dgpl=false`）；egl-angle、d3d11va 硬解、gl-win32；补丁 `patches/mpv-wasapi-include-mmreg.patch`（新版 mingw-w64 头文件需要） |
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
./build-deps.sh    # dav1d、zlib、ANGLE 头文件
./build-ffmpeg.sh
./build-ass.sh
./build-mpv.sh      # 产物：out/libmpv-2.dll、out/libmpv.dll.a、out/include/mpv/*.h
```

## 发布

release 资产是与 media-kit 同样布局的 7z（`libmpv-2.dll`、`libmpv.dll.a`、`include/mpv/*.h`），App 的
`third_party/media_kit_libs_windows_video` 按 SHA-256 下载。
