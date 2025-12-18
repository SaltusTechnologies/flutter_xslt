#!/usr/bin/env bash
# build_libxml_libxslt_ios_apple_silicon.sh
# Vendored static builds of libxml2 + libxslt (+ libexslt) for iOS (device + simulator, both arm64).
# Output:
#   ThirdParty/
#     include/              (public headers: libxml2/, libxslt/, libexslt/)
#     lib/
#       iphoneos/           (arm64 device)
#         libxml2.a libxslt.a libexslt.a
#       iphonesimulator/    (arm64 simulator)
#         libxml2.a libxslt.a libexslt.a

set -euo pipefail

# ========= Versions =========
LIBXML2_VER="${LIBXML2_VER:-2.14.2}"
LIBXSLT_VER="${LIBXSLT_VER:-1.1.43}"
IOS_MIN="${IOS_MIN:-14.0}"

# ========= Paths =========
ROOT="$(cd "$(dirname "$0")" && pwd)"
WORK="$ROOT/src"
PREFIX_BASE="$(cd "$ROOT/../.." && pwd)"
Headers_DIR="$PREFIX_BASE/src/flutter_xslt/ios/Lib/Headers"
BIN_OS_DIR="$PREFIX_BASE/src/flutter_xslt/ios/Lib/Bin/iphoneos"
#BIN_OS_DIR_SIM_DIR="$PREFIX_BASE/src/flutter_xslt/ios/Lib/Bin/iphonesimulator"

mkdir -p "$WORK" "$Headers_DIR" "$BIN_OS_DIR" #"$BIN_OS_DIR_SIM_DIR"

# ========= Tooling checks =========
xcrun --version >/dev/null
CLANG_OS="$(xcrun --sdk iphoneos -f clang)"
CLANG_SIM="$(xcrun --sdk iphonesimulator -f clang)"
SDK_OS="$(xcrun --sdk iphoneos --show-sdk-path)"
#SDK_SIM="$(xcrun --sdk iphonesimulator --show-sdk-path)"

echo "Using:"
echo "  libxml2  : $LIBXML2_VER"
echo "  libxslt  : $LIBXSLT_VER"
echo "  iOS min  : $IOS_MIN"
echo "  SDK (OS) : $SDK_OS"
#echo "  SDK (SIM): $SDK_SIM"
echo

# ========= Download sources (official GNOME mirrors) =========
cd "$WORK"
XML_URL="https://download.gnome.org/sources/libxml2/${LIBXML2_VER%.*}/libxml2-$LIBXML2_VER.tar.xz"
XSLT_URL="https://download.gnome.org/sources/libxslt/${LIBXSLT_VER%.*}/libxslt-$LIBXSLT_VER.tar.xz"

[ -f "libxml2-$LIBXML2_VER.tar.xz" ] || curl -L -O "$XML_URL"
[ -f "libxslt-$LIBXSLT_VER.tar.xz" ] || curl -L -O "$XSLT_URL"

rm -rf "libxml2-$LIBXML2_VER" "libxslt-$LIBXSLT_VER"
tar xf "libxml2-$LIBXML2_VER.tar.xz"
tar xf "libxslt-$LIBXSLT_VER.tar.xz"

# ========= Build function =========
# $1 = platform label ("iphoneos" | "iphonesimulator")
# $2 = SDK path
# $3 = CC path
# $4 = arch (arm64)
# $5 = outlibdir
build_sdk() {
  local PLATFORM="$1" SDK="$2" CC="$3" ARCH="$4" OUTLIBDIR="$5"
  local HOST_TRIPLET="arm-apple-darwin"

  local TARGET_FLAG_OS="-target ${ARCH}-apple-ios${IOS_MIN}"
  local TARGET_FLAG_SIM="-target ${ARCH}-apple-ios${IOS_MIN}-simulator"
  local TARGET_FLAG
  if [[ "$PLATFORM" == "iphoneos" ]]; then
    TARGET_FLAG="$TARGET_FLAG_OS"
  else
    TARGET_FLAG="$TARGET_FLAG_SIM"
  fi

  local CFLAGS="-arch $ARCH -isysroot $SDK $TARGET_FLAG -Os -fvisibility=hidden"
  local LDFLAGS="-arch $ARCH -isysroot $SDK $TARGET_FLAG"
  local XML_PREFIX="$WORK/prefix-$PLATFORM-$ARCH-xml"
  local XSLT_PREFIX="$WORK/prefix-$PLATFORM-$ARCH-xslt"

  echo "==> Building libxml2 for $PLATFORM ($ARCH)"
  rm -rf "libxml2-$LIBXML2_VER-build-$PLATFORM-$ARCH"
  cp -R "libxml2-$LIBXML2_VER" "libxml2-$LIBXML2_VER-build-$PLATFORM-$ARCH"
  pushd "libxml2-$LIBXML2_VER-build-$PLATFORM-$ARCH" >/dev/null
    ./configure \
      CC="$CC" CFLAGS="$CFLAGS" LDFLAGS="$LDFLAGS" \
      --host="$HOST_TRIPLET" \
      --enable-static --disable-shared \
      --without-python --without-zlib --without-lzma \
      --prefix="$XML_PREFIX"
    make -j"$(sysctl -n hw.logicalcpu)"
    make install
  popd >/dev/null

echo "==> Building libxslt (and libexslt) for $PLATFORM ($ARCH)"
rm -rf "libxslt-$LIBXSLT_VER-build-$PLATFORM-$ARCH"
cp -R "libxslt-$LIBXSLT_VER" "libxslt-$LIBXSLT_VER-build-$PLATFORM-$ARCH"
pushd "libxslt-$LIBXSLT_VER-build-$PLATFORM-$ARCH" >/dev/null
  # Detect build triplet in *this* source dir
  BUILD_TRIPLET="$(./config.guess)"
  PYTHON=no PYTHON_CFLAGS= PYTHON_LIBS= \
  PKG_CONFIG_PATH="$XML_PREFIX/lib/pkgconfig" \
  CONFIG_SHELL=/bin/bash \
  ./configure \
    CC="$CC" CFLAGS="$CFLAGS -I$XML_PREFIX/include/libxml2" \
    LDFLAGS="$LDFLAGS -L$XML_PREFIX/lib" \
    --build="$BUILD_TRIPLET" \
    --host="$HOST_TRIPLET" \
    --enable-static --disable-shared \
    --without-crypto \
    --without-python \
    --prefix="$XSLT_PREFIX"

  make -j"$(sysctl -n hw.logicalcpu)"
  make install
popd >/dev/null

  # Copy headers once per platform (identical across arches—we only do arm64 anyway)
  rsync -a "$XML_PREFIX/include/" "$Headers_DIR/"
  rsync -a "$XSLT_PREFIX/include/" "$Headers_DIR/"

  mkdir -p "$OUTLIBDIR"
  cp "$XML_PREFIX/lib/libxml2.a" "$OUTLIBDIR/"
  cp "$XSLT_PREFIX/lib/libxslt.a" "$OUTLIBDIR/"
  cp "$XSLT_PREFIX/lib/libexslt.a" "$OUTLIBDIR/"
}

# ========= Build: device (arm64) and simulator (arm64) =========
build_sdk "iphoneos"       "$SDK_OS"  "$CLANG_OS"  "arm64" "$BIN_OS_DIR"
#build_sdk "iphonesimulator" "$SDK_SIM" "$CLANG_SIM" "arm64" "$BIN_OS_DIR_SIM_DIR"

# ========= Summary =========
echo
echo "✅ Build complete."
echo "Headers: $Headers_DIR"
echo "Device libs:    $BIN_OS_DIR (libxml2.a, libxslt.a, libexslt.a)"
#echo "Simulator libs: $BIN_OS_DIR_SIM_DIR (libxml2.a, libxslt.a, libexslt.a)"
echo

