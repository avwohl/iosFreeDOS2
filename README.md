# iosFreeDOS2

Run FreeDOS games on iPad and Mac. Powered by DOSBox.

## What is this?

iosFreeDOS2 is the successor to [iosFreeDOS](https://github.com/avwohl/iosFreeDOS).
The original project built a custom 8088/286/386 emulator from scratch, but
the 386 protected mode + FPU + DPMI stack became unmanageable for running
real games like DOOM.

This project keeps the iOS/Mac SwiftUI interface and disk management from
iosFreeDOS, but replaces the custom emulator with
[DOSBox Staging](https://dosbox-staging.github.io/) — a mature, full-featured
DOS emulator with complete 386+FPU, DPMI, VGA, and Sound Blaster support.

## Features

- Full 386 CPU with FPU (runs DOOM, Duke Nukem 3D, etc.)
- DPMI support (DOS extenders work out of the box)
- VGA/SVGA graphics with S3 emulation
- Sound Blaster 16 audio
- Mouse support
- Disk image management (floppy, HDD, CD-ROM ISO)
- Downloadable game catalog
- iPad and Mac (Catalyst) support

## Architecture

```
┌─────────────────────────────────┐
│  SwiftUI Interface (iOS/Mac)    │
│  - Disk catalog & downloads     │
│  - Configuration profiles       │
│  - Terminal/graphics display     │
│  - Touch/keyboard input         │
├─────────────────────────────────┤
│  DOSEmulator Bridge (ObjC++)    │
│  - Config generation            │
│  - Frame capture & delivery     │
│  - Input injection              │
├─────────────────────────────────┤
│  DOSBox Staging                 │
│  - CPU (386 + FPU + MMX)        │
│  - DOS kernel + DPMI            │
│  - VGA/SVGA/Sound Blaster       │
│  - Disk drive emulation         │
└─────────────────────────────────┘
```

## Building

### Prerequisites

- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- CMake (`brew install cmake`)

### Steps

```bash
# Clone with submodules
git clone --recursive https://github.com/avwohl/iosFreeDOS2.git
cd iosFreeDOS2

# Generate Xcode project
xcodegen

# Open in Xcode and build
open iosFreeDOS.xcodeproj
```

## Status

**Work in progress.** The project structure and iOS UI are in place.
DOSBox integration is being built out:

- [x] Project setup with DOSBox submodule
- [x] iOS bridge layer (DOSEmulator wrapper)
- [x] SwiftUI UI adapted for DOSBox config
- [ ] DOSBox cross-compilation for iOS (ARM64)
- [ ] SDL2 iOS framework integration
- [ ] Frame capture and display
- [ ] Input routing (keyboard, mouse, touch)
- [ ] Audio output via iOS audio session
- [ ] App Store submission

## License

DOSBox Staging is licensed under GPL-2.0-or-later.
See [LICENSE](LICENSE) for the full license text.
