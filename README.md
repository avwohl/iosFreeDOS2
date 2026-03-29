# qxDOS — DOS for iOS and Mac

A DOS emulator for iOS and Mac using
[DOSBox Staging](https://dosbox-staging.github.io/) as the emulation engine.
Boots [FreeDOS](https://www.freedos.org/), [MS-DOS](https://github.com/microsoft/MS-DOS), or [DOSBox](https://dosbox-staging.github.io/)'s built-in DOS.

## What is this?

qxDOS is a SwiftUI front-end that lets you run DOS on iPad and Mac.
The qxDOS project provides only the iOS/Mac app shell — the user
interface, touch controls, disk management, and the infrastructure to
boot different DOS operating systems. All PC emulation is provided by
[DOSBox Staging](https://dosbox-staging.github.io/), an independent
open-source project. The operating systems themselves —
[FreeDOS](https://www.freedos.org/),
[MS-DOS](https://github.com/microsoft/MS-DOS), etc. — are independent
projects with their own developers and licenses. qxDOS did not write
or contribute code to any of them.

Choose which DOS to run:

- **FreeDOS** — free, open-source DOS by the [FreeDOS Project](https://www.freedos.org/) (GPL v2+)
- **MS-DOS** — [Microsoft](https://github.com/microsoft/MS-DOS)'s original DOS; bring your own media, or use MS-DOS 4.0 (MIT license)
- **DOSBox DOS** — [DOSBox Staging](https://dosbox-staging.github.io/)'s built-in kernel and shell, no OS on disk needed

Use it to run classic DOS games, utilities, learn DOS programming, or
explore period software archives like Simtel and Walnut Creek.

## Features

- Full 386 CPU with FPU and DPMI support
- VGA/SVGA graphics (S3 Trio64)
- Sound Blaster 16 audio
- Mouse and keyboard input
- Configurable virtual touch controls (D-Pad, analog stick, buttons)
- NE2000 Ethernet networking with SLIRP (FTP, Telnet, HTTP downloads)
- Host file transfer (R and W commands to move files between DOS and your device)
- Disk image management (floppy, HDD, CD-ROM ISO)
- Downloadable disk catalog with FreeDOS images and archive.org collections
- Multiple machine configuration profiles
- Built-in help system with in-app documentation
- iPad and Mac (Catalyst) support

## Networking

The emulated NE2000 Ethernet adapter connects DOS to the internet through
your device's network connection via SLIRP (a virtual NAT router). The
FreeDOS disk comes with mTCP, a TCP/IP suite with FTP, Telnet, Ping, and
an HTTP downloader.

Type `FDNET` at the DOS prompt to get online:

```
C:\> FDNET
Loading NE2000 packet driver...
Getting IP address via DHCP...
Network is ready.

C:\> FTP ftp.example.com
C:\> HTGET http://example.com/GAME.ZIP GAME.ZIP
```

## File Transfer

Two built-in commands let you move files between DOS and your device:

- **R** (Read) — copies a file from your device into DOS
- **W** (Write) — copies a file from DOS to your device

```
C:\> R myfile.txt C:\MYFILE.TXT
C:\> W C:\DOCUMENT.TXT document.txt
```

Files are stored in the qxDOS folder in the Files app (iPad/iPhone) or
the app container's Documents directory (Mac).

## Disk Catalog

The app includes a downloadable catalog of disk images:

- **FreeDOS Hard Disk** — 200MB bootable FreeDOS with 230 utilities
- **FreeDOS Starter** — 22MB minimal bootable FreeDOS
- **FreeDOS 1.4 / 1.3 LiveCD** — official installer ISOs (from freedos.org)
- **Simtel MS-DOS Archive** — thousands of DOS utilities and shareware (from archive.org)
- **Walnut Creek CD-ROMs** — classic DOS software collections (from archive.org)

CD-ROM ISOs are downloaded directly from their original hosts. ZIP files
are automatically extracted.

## Building

### Prerequisites

- Xcode 15+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
- CMake (`brew install cmake`)
- SDL2 and dependencies (`brew install sdl2 sdl2_image libpng speexdsp iir1 opusfile`)

### Steps

```bash
# Clone with submodules
git clone --recursive https://github.com/avwohl/qxDOS.git
cd qxDOS

# Configure CMake for Mac Catalyst
mkdir build-maccatalyst && cd build-maccatalyst
cmake ../dosbox-ios
cd ..

# Configure CMake for iOS (requires iOS toolchain)
mkdir build-ios && cd build-ios
cmake ../dosbox-ios -DCMAKE_SYSTEM_NAME=iOS
cd ..

# Generate Xcode project
xcodegen

# Open in Xcode and build
open qxDOS.xcodeproj
```

The Xcode pre-build script automatically runs `cmake --build` to
incrementally rebuild the DOSBox static libraries when sources change.

## Architecture

```
SwiftUI App (qxDOS/)
  └─ DOSEmulator.h/.mm (Objective-C++ bridge)
       └─ dosbox-ios/ (C bridge layer)
            ├─ dosbox_bridge.cpp — config, lifecycle, input
            ├─ int_e0_hostio.cpp — INT E0h host file transfer
            └─ DOSBox-staging (git submodule)
                 ├─ CPU: 386/486 with FPU, dynamic recompiler
                 ├─ DOS: kernel, DPMI, drives, shell
                 ├─ Hardware: VGA, Sound Blaster, NE2000, keyboard, mouse
                 └─ SDL2: video output, audio, input events
```

## License

qxDOS is licensed under GPL-3.0-or-later. See [LICENSE](LICENSE) for
the full license text.

This app distributes GPL-licensed binaries from several projects.
Complete source code is available at:

- **qxDOS:** https://github.com/avwohl/qxDOS
- **DOSBox Staging (GPL v2+):** https://github.com/dosbox-staging/dosbox-staging
- **FreeDOS kernel and utilities (GPL v2+):** https://github.com/FDOS
- **mTCP (GPL v3):** https://www.brutman.com/mTCP/

You may also request source code by opening an issue at
https://github.com/avwohl/qxDOS/issues. This offer is valid for three
years from the date of each release. See [RIGHTS.md](RIGHTS.md) for
full licensing details.
