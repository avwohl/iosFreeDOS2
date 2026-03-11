# Quick Start Guide

Welcome to FreeDOS, an IBM PC emulator that runs FreeDOS on your iPhone, iPad, or Mac.

## First Boot

1. Open the app and scroll to **Disk Catalog**
2. Download a **FreeDOS** floppy image
3. Tap **Use as A:**
4. Tap **Start Emulator**

You should see FreeDOS boot to an `A:\>` prompt.

## Keyboard

The on-screen keyboard has special keys in the toolbar above it:

- **Ctrl** — toggles Ctrl mode (next key sent as Ctrl+key)
- **Esc** — sends the Escape key
- **Tab** — sends the Tab key
- **Arrow keys** — cursor movement

On a hardware keyboard (iPad, Mac), all keys work normally.

## Mouse

Touch the terminal screen to move the mouse cursor:

- **Tap** — left click
- **Long press** — right click
- **Drag** — move mouse with button held

Enable or disable the mouse in the Peripherals settings.

## Disks

iosFreeDOS supports floppy disks (A: and B:), hard disks (C: and D:), and CD-ROM ISOs.

- Use the **Disk Catalog** to download ready-made images
- Use **Download from URL** to load images from the internet
- Use **Load from Files** to import images from your device
- Use **Create Blank Disk** to make empty floppy or hard disk images

## Configuration Profiles

Save different machine setups as named profiles. Each profile remembers:

- Display adapter, CPU speed, peripherals
- Which disk images are loaded
- Boot drive selection

Use the profile picker at the top of the settings screen to switch between them.

## Boot Drive

Select which drive to boot from in the **Boot** section:

- **Floppy A:** — boot from the floppy disk in drive A
- **Hard Disk C:** — boot from the hard disk
- **CD-ROM** — boot from a CD-ROM ISO image

## Getting Files In and Out

Use the built-in **R.COM** and **W.COM** utilities to transfer files between DOS and your device.

- `R hostfile DOSFILE.TXT` — read a file from your device into DOS
- `W DOSFILE.TXT hostfile` — write a DOS file out to your device

On iOS, host files live in the **Files app** under **FreeDOS**. On Mac, they are in the app's container folder. See the **File Transfer** help topic for details.

## Compatibility

The 386 CPU emulation is **real mode only**. Programs that require protected
mode or DOS extenders (like DOOM, Quake, or Duke Nukem 3D) will not run.
Games needing HIMEM.SYS or EMM386 are also unsupported. The emulator runs
a wide range of classic DOS software from the late 1980s through mid-1990s.

## Next Steps

- **File Transfer** — learn how to move files in and out of the emulator
- **Networking** — set up the NE2000 network adapter for TCP/IP
