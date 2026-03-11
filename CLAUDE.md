# iosFreeDOS2 - DOSBox-based FreeDOS for iOS/Mac

## Project Overview

Successor to iosFreeDOS. Replaces the custom 8088/286/386 emulator with
DOSBox-staging for full 386+FPU, DPMI, Sound Blaster, and VGA support.
Goal: run FreeDOS games (including DOOM) on iPad and Mac.

## Architecture

```
SwiftUI Views (kept from iosFreeDOS)
  └─ DOSEmulator.h/.mm (Objective-C++ bridge, rewritten for DOSBox)
       └─ DOSBox-staging (git submodule at dosbox-staging/)
            ├─ CPU: full 386+FPU with dynamic recompiler
            ├─ DOS: kernel, DPMI, drives, shell
            ├─ Hardware: VGA, Sound Blaster, keyboard, mouse
            └─ SDL2: video output, audio, input events
```

## Build

1. Prerequisites: Xcode 15+, CMake, SDL2 iOS framework
2. `git submodule update --init` to fetch dosbox-staging
3. Build DOSBox as static library: `cmake --preset ios-arm64` (see cmake/)
4. Generate Xcode project: `xcodegen` (requires XcodeGen)
5. Open iosFreeDOS.xcodeproj and build

## Key Directories

- `iosFreeDOS/` - SwiftUI app (Views, Bridge, Assets)
- `dosbox-staging/` - DOSBox source (git submodule)
- `dosbox-ios/` - iOS-specific DOSBox integration layer
- `fd/` - FreeDOS disk images
- `dos/` - DOS guest utilities (R.COM, W.COM)

## Development Notes

- DOSBox uses C++20, SDL2, and has many optional dependencies
- For iOS, we disable: debugger, webserver, FluidSynth, MT32
- SDL2 provides iOS support (OpenGL ES / Metal rendering)
- The bridge writes a temporary dosbox.conf and launches DOSBox
- Frame capture via custom GFX callback → delegate → SwiftUI
