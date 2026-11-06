# 交叉编译环境：llvm-mingw(macOS 原生) → x86_64 Windows。所有产物在外置盘 $W 下。
W=/Volumes/SSD2TB-Samsung/Projects/libmpv-win-full-build
TC=$W/llvm-mingw-20261104-ucrt-macos-universal
export PATH="$TC/bin:/Volumes/SSD2TB-Samsung/Projects/libmpv-darwin-build/watchtranslate/tc/venv/bin:/Volumes/SSD2TB-Samsung/Projects/libmpv-darwin-build/watchtranslate/tc/nasm/bin:/Users/leijie/.local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export PREFIX=$W/prefix
export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig
unset PKG_CONFIG_PATH
export HOST=x86_64-w64-mingw32
export CFLAGS="-O2 -I$PREFIX/include -Wno-error=int-conversion -Wno-error=incompatible-function-pointer-types -Wno-error=implicit-function-declaration -Wno-error=implicit-int"
