# Changelog

## v2.0.0 - DOSBox Migration

Complete rewrite of the emulator backend. Replaces the custom 8088/286/386
CPU emulator with DOSBox Staging for full compatibility with DOS games.

### Changed
- Emulator backend: custom emu88 → DOSBox Staging
- Full 386 + FPU + DPMI support (runs DOOM, Duke3D, etc.)
- VGA/SVGA with S3 Trio64 emulation
- Sound Blaster 16 audio
- Configuration UI updated for DOSBox settings (machine type, cycles, RAM)
- C++ standard updated from C++17 to C++20 (DOSBox requirement)

### Kept
- SwiftUI interface for iOS and Mac
- Disk catalog and download system
- Multi-profile machine configuration
- Floppy/HDD/ISO disk image management
- Touch keyboard with modifier keys (Ctrl, Alt, Fn)
