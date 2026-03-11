# Bundled Games - Hardware Notes

All games tested with iosFreeDOS (386 real-mode CPU, VGA adapter, 507K conventional memory).
The 386 CPU emulation is **real mode only** -- no protected mode, DPMI, or DOS extenders.

## Working Games (11)

### Alien Carnage / Halloween Harry (SubZero Software, 1994)
- **Directory:** `\GAMES\ALIENCAR`
- **Run:** `CARNAGE`
- **Video:** VGA (40-column mode)
- **Sound:** Sound Blaster/AdLib
- **Notes:** Freeware. Side-scrolling platformer/shooter.

### Bio Menace (Apogee, 1993)
- **Directory:** `\GAMES\BIOMENAC`
- **Run:** `BMENACE1`
- **Video:** CGA/EGA/VGA (auto-detected)
- **Sound:** Sound Blaster/AdLib, PC Speaker
- **Notes:** Freeware. Side-scrolling shooter by Jim Norwood.

### Dark Ages (Apogee, 1991)
- **Directory:** `\GAMES\DARKAGES\1`
- **Run:** `DA1`
- **Video:** EGA
- **Sound:** PC Speaker
- **Notes:** Shareware Episode 1. Side-scrolling platformer. Episodes 2-3 in subdirs `2`, `3`.

### Duke Nukem 1 (Apogee, 1991)
- **Directory:** `\GAMES\DUKE1`
- **Run:** `DN1`
- **Video:** EGA/VGA (mode 13h)
- **Sound:** PC Speaker
- **Memory:** Needs ~520K. Works with optimized FDCONFIG.SYS (507K free).
- **Notes:** Shareware Episode 1. Side-scrolling platformer.

### God of Thunder (Adept Software/Software Creations, 1993)
- **Directory:** `\GAMES\GOT`
- **Run:** `GOT`
- **Video:** VGA required (mode 13h)
- **Sound:** Sound Blaster/AdLib (run `SETBLAST` to configure)
- **Notes:** Freeware. Top-down puzzle/action adventure.

### Jill of the Jungle (Epic MegaGames, 1992)
- **Directory:** `\GAMES\JILL`
- **Run:** `JILL1`
- **Video:** VGA 256-color (auto-detected)
- **Sound:** Sound Blaster/AdLib
- **Notes:** Shareware Episode 1. Side-scrolling platformer by Tim Sweeney.

### Kingdom of Kroz (Apogee, 1990)
- **Directory:** `\GAMES\KROZ`
- **Run:** `KINGDOM`
- **Video:** Text mode (CGA/MDA)
- **Sound:** PC Speaker
- **Notes:** Freeware. Asks "Color or Monochrome?" at startup. ASCII dungeon crawler.

### Major Stryker (Apogee, 1993)
- **Directory:** `\GAMES\STRYKER`
- **Run:** `STRYKER`
- **Video:** EGA/VGA
- **Sound:** Sound Blaster/AdLib
- **Notes:** Freeware. Vertical scrolling shoot-em-up.

### SkyRoads (Bluemoon Interactive, 1993)
- **Directory:** `\GAMES\SKYROADS`
- **Run:** `SKYROADS`
- **Video:** EGA/VGA
- **Sound:** PC Speaker
- **Notes:** Freeware. 3D road racing/jumping game.

### Supaplex (Digital Integration, 1991)
- **Directory:** `\GAMES\SUPAPLEX`
- **Run:** `SPFIX63`
- **Video:** VGA (mode 13h)
- **Sound:** Sound Blaster/AdLib
- **Notes:** Freeware. Boulder Dash clone with circuit board theme. Uses community-fixed SPFIX63.

### Xargon (Epic MegaGames, 1994)
- **Directory:** `\GAMES\XARGON`
- **Run:** `XARGON`
- **Video:** VGA (40-column mode)
- **Sound:** Sound Blaster/AdLib
- **Notes:** Freeware. Side-scrolling platformer, successor to Jill of the Jungle.

## Removed Games

### Kiloblaster (Epic MegaGames, 1992) -- REMOVED
- **Reason:** Silently exits at startup. Turbo Pascal runtime fails hardware detection.

### Liero (1998-1999) -- REMOVED
- **Reason:** Requires XMS extended memory (HIMEM.SYS).

### Cosmo's Cosmic Adventure (Apogee, 1992) -- REMOVED
- **Reason:** Requires 528K-536K conventional memory (507K available).

### Traffic Department 2192 (Safari Software, 1994) -- REMOVED
- **Reason:** Requires more conventional memory than available.

## Emulator Requirements

- **CPU:** 386 real mode only (no protected mode, no DPMI, no DOS extenders)
- **Display:** Set to VGA in config (games auto-detect CGA/EGA/VGA via INT 10h)
- **Memory:** 507K conventional with optimized FDCONFIG.SYS
- **Sound:** PC Speaker always works. Sound Blaster at I/O 220, IRQ 7, DMA 1.
- **No XMS/EMS:** HIMEM.SYS and EMM386 cannot run (require protected mode)

## Games That Cannot Run on This Emulator

- **DOOM, Quake, Duke Nukem 3D, Descent, etc.:** Require DOS4GW/DPMI (32-bit protected mode)
- **Any game needing HIMEM.SYS/EMM386:** Requires protected mode transitions
- **Windows 3.x games:** Require protected mode
- **Any game showing "DOS/4GW Protected Mode Runtime":** Needs DPMI
