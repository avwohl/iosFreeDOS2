#!/bin/bash
#
# Build universal (arm64 + x86_64) static libraries for Mac Catalyst.
#
# This script:
#   1. Ensures vcpkg dependencies exist for both architectures
#   2. Builds DOSBox via CMake for both architectures
#   3. Lipos arm64 + x86_64 into universal libraries in build-maccatalyst/
#
# Prerequisites:
#   - vcpkg cloned at ~/vcpkg (or set VCPKG_ROOT)
#   - cmake installed (brew install cmake)
#   - arm64-maccatalyst and x64-maccatalyst vcpkg deps pre-built
#     (see dosbox-ios/vcpkg_installed/{arm64,x64}-maccatalyst/)
#
# Usage: ./scripts/build_maccatalyst_universal.sh

set -euo pipefail

SRCROOT="$(cd "$(dirname "$0")/.." && pwd)"
DOSBOX_IOS="$SRCROOT/dosbox-ios"
JOBS=$(sysctl -n hw.ncpu)

ARM64_BUILD="$SRCROOT/build-maccatalyst-arm64"
X86_BUILD="$SRCROOT/build-maccatalyst-x86_64"
UNIVERSAL="$SRCROOT/build-maccatalyst"

ARM64_VCPKG="$DOSBOX_IOS/vcpkg_installed/arm64-maccatalyst"
X86_VCPKG="$DOSBOX_IOS/vcpkg_installed/x64-maccatalyst"
UNIVERSAL_VCPKG="$DOSBOX_IOS/vcpkg_installed/universal-maccatalyst"

CATALYST_FLAGS_ARM64="-target arm64-apple-ios15.0-macabi -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks"
CATALYST_FLAGS_X86="-target x86_64-apple-ios15.0-macabi -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks"

# ---------- Step 0: Verify vcpkg deps exist ----------

for dir in "$ARM64_VCPKG/lib" "$X86_VCPKG/lib"; do
    if [ ! -d "$dir" ]; then
        echo "error: Missing vcpkg deps at $dir"
        echo "Build vcpkg dependencies first (see README)."
        exit 1
    fi
done

echo "=== vcpkg deps verified ==="

# ---------- Step 1: Configure and build arm64 ----------

if [ ! -f "$ARM64_BUILD/CMakeCache.txt" ]; then
    echo "=== Configuring arm64 Mac Catalyst CMake build ==="
    mkdir -p "$ARM64_BUILD"
    PKG_CONFIG_PATH="$ARM64_VCPKG/lib/pkgconfig" \
    PKG_CONFIG_LIBDIR="$ARM64_VCPKG/lib/pkgconfig" \
    cmake -S "$DOSBOX_IOS" -B "$ARM64_BUILD" \
        -DMACCATALYST=ON \
        -DDOSBOX_DISABLE_OPUS=ON \
        -DDOSBOX_DISABLE_PNG=ON \
        -DCMAKE_C_FLAGS="$CATALYST_FLAGS_ARM64" \
        -DCMAKE_CXX_FLAGS="$CATALYST_FLAGS_ARM64" \
        -DCMAKE_OSX_ARCHITECTURES=arm64 \
        -DCMAKE_PREFIX_PATH="$ARM64_VCPKG" \
        -DCMAKE_IGNORE_PREFIX_PATH="/opt/homebrew;/usr/local"
fi

echo "=== Building arm64 Mac Catalyst ==="
cmake --build "$ARM64_BUILD" -j"$JOBS" --target dosbox-core dosbox-bridge

# ---------- Step 2: Configure and build x86_64 ----------

if [ ! -f "$X86_BUILD/CMakeCache.txt" ]; then
    echo "=== Configuring x86_64 Mac Catalyst CMake build ==="
    mkdir -p "$X86_BUILD"
    PKG_CONFIG_PATH="$X86_VCPKG/lib/pkgconfig" \
    PKG_CONFIG_LIBDIR="$X86_VCPKG/lib/pkgconfig" \
    cmake -S "$DOSBOX_IOS" -B "$X86_BUILD" \
        -DMACCATALYST=ON \
        -DDOSBOX_DISABLE_OPUS=ON \
        -DDOSBOX_DISABLE_PNG=ON \
        -DCMAKE_C_FLAGS="$CATALYST_FLAGS_X86" \
        -DCMAKE_CXX_FLAGS="$CATALYST_FLAGS_X86" \
        -DCMAKE_OSX_ARCHITECTURES=x86_64 \
        -DCMAKE_PREFIX_PATH="$X86_VCPKG" \
        -DCMAKE_IGNORE_PREFIX_PATH="/opt/homebrew;/usr/local"
fi

echo "=== Building x86_64 Mac Catalyst ==="
cmake --build "$X86_BUILD" -j"$JOBS" --target dosbox-core dosbox-bridge

# ---------- Step 3: Lipo into universal ----------

echo "=== Creating universal (arm64 + x86_64) libraries ==="
mkdir -p "$UNIVERSAL"

# Lipo all .a files from the CMake build
for lib in "$ARM64_BUILD"/*.a; do
    name=$(basename "$lib")
    x86_lib="$X86_BUILD/$name"
    if [ -f "$x86_lib" ]; then
        lipo -create "$lib" "$x86_lib" -output "$UNIVERSAL/$name"
        echo "  universal: $name"
    else
        echo "  warning: $name missing x86_64, copying arm64 only"
        cp "$lib" "$UNIVERSAL/$name"
    fi
done

# Lipo vcpkg dependencies
mkdir -p "$UNIVERSAL_VCPKG/lib"
# Share headers (architecture-independent)
rm -f "$UNIVERSAL_VCPKG/include"
ln -sf "$ARM64_VCPKG/include" "$UNIVERSAL_VCPKG/include"

# Collect all unique .a files from both vcpkg dirs
for lib in "$ARM64_VCPKG/lib/"*.a "$X86_VCPKG/lib/"*.a; do
    name=$(basename "$lib")
    [ -f "$UNIVERSAL_VCPKG/lib/$name" ] && continue

    arm64_lib="$ARM64_VCPKG/lib/$name"
    x86_lib="$X86_VCPKG/lib/$name"

    if [ -f "$arm64_lib" ] && [ -f "$x86_lib" ]; then
        lipo -create "$arm64_lib" "$x86_lib" -output "$UNIVERSAL_VCPKG/lib/$name"
        echo "  universal: vcpkg/$name"
    elif [ -f "$arm64_lib" ]; then
        cp "$arm64_lib" "$UNIVERSAL_VCPKG/lib/$name"
        echo "  arm64-only: vcpkg/$name"
    else
        # Skip x86_64-only libs (e.g. libz.a) — system versions are universal
        echo "  skipping: vcpkg/$name (x86_64-only, use system lib)"
    fi
done

echo ""
echo "=== Done! Universal libraries in: ==="
echo "  DOSBox:  $UNIVERSAL/"
echo "  vcpkg:   $UNIVERSAL_VCPKG/"
echo ""
echo "Verify:"
for lib in "$UNIVERSAL"/*.a; do
    echo "  $(basename "$lib"): $(lipo -archs "$lib")"
done
