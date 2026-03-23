set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
# Use Darwin (not iOS) — Mac Catalyst uses the macOS SDK, not iPhoneSimulator
set(VCPKG_CMAKE_SYSTEM_NAME Darwin)
set(VCPKG_C_FLAGS "-target x86_64-apple-ios15.0-macabi -iframework /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk/System/iOSSupport/System/Library/Frameworks")
set(VCPKG_CXX_FLAGS "${VCPKG_C_FLAGS}")
set(VCPKG_OSX_ARCHITECTURES x86_64)
set(VCPKG_OSX_DEPLOYMENT_TARGET 15.0)
