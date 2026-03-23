# About FreeDOS

FreeDOS is a free, open-source operating system compatible with MS-DOS. This app runs FreeDOS inside an emulated 386 PC powered by DOSBox Staging.

## What You Get

The emulated PC includes:

- **CPU** — 386/486 with FPU and DPMI (protected mode for games like DOOM)
- **Graphics** — VGA/SVGA (S3 Trio64), all standard video modes
- **Sound** — Sound Blaster 16 with FM synthesis and digital audio
- **Mouse** — PS/2 mouse, works with DOS mouse drivers
- **Ethernet** — NE2000 with SLIRP (virtual NAT for internet access)
- **Drives** — floppy (A:, B:), hard disk (C:, D:), CD-ROM

## What's on the Disk

The FreeDOS disk images come with the FreeDOS kernel, COMMAND.COM, and a set of utilities in `C:\FREEDOS\BIN`:

| Command | What it does |
|---------|-------------|
| `EDIT` | Full-screen text editor |
| `MEM` | Show memory usage |
| `XCOPY` | Copy files and directory trees |
| `FORMAT` | Format a floppy disk |
| `FDISK` | Partition a hard disk |
| `DELTREE` | Delete a directory and everything in it |
| `MORE` | Page through long output |
| `LABEL` | Set a disk volume label |

The starter disk also includes:

| Command | What it does |
|---------|-------------|
| `R` | Copy a file from your device into DOS |
| `W` | Copy a file from DOS to your device |
| `CWSDPMI` | DPMI server for protected-mode programs (DOOM, etc.) |

## Networking Tools

In `C:\NET` (type `NET` to activate):

| Command | What it does |
|---------|-------------|
| `FTP` | Transfer files to/from FTP servers |
| `TELNET` | Remote terminal sessions |
| `PING` | Test network connectivity |
| `HTGET` | Download files via HTTP |
| `DHCP` | Get an IP address (called by NET automatically) |

## CPU Speed

The emulated CPU speed is configurable in machine settings. Presets range from 8088 (4.77 MHz) to Pentium speed. Use higher speeds for protected-mode games. The "Max" setting runs as fast as your device allows.

## DPMI

DPMI (DOS Protected Mode Interface) lets programs use extended memory beyond the 640K conventional limit. CWSDPMI is included on the disk and loads automatically when a DPMI program runs. Games compiled with DJGPP (like DJDOOM) use this.

## FreeDOS vs. MS-DOS

FreeDOS is compatible with MS-DOS at the application level. Most DOS programs, games, and utilities work without modification. FreeDOS is free software (GPL) and actively maintained at freedos.org.

## Disk Images

The app supports several disk image formats:

- **Hard disk images** (.img) — bootable FAT16 partitioned disks
- **Floppy images** (.img) — 1.44MB floppy disks
- **CD-ROM images** (.iso) — read-only CD-ROM

You can download ready-made images from the in-app disk catalog, import your own, or create blank disks.
