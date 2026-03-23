# Software Rights and Licensing

This document describes the licensing and legal status of software
distributed with FreeDOS for iOS/Mac.

## DOSBox Staging

The emulator core is DOSBox Staging, a modernized fork of DOSBox.

- **License:** GNU General Public License (GPL) v2+
- **Website:** https://dosbox-staging.github.io/
- **Source:** https://github.com/dosbox-staging/dosbox-staging

## FreeDOS

FreeDOS is the operating system included in the bootable disk images.

- **License:** GNU General Public License (GPL) v2+
- **Copyright:** Copyright 1995-2012 Pasquale J. Villani and The FreeDOS Project
- **Website:** https://www.freedos.org/
- **Source:** https://github.com/FDOS
- **Components used:**
  - FreeDOS Kernel 2043 (GPL v2+)
  - FreeCom 0.86 (COMMAND.COM) (GPL v2+)
  - FreeDOS utilities (various GPL/BSD licenses)

## libslirp

Userspace TCP/IP stack providing NE2000 networking (NAT).

- **License:** BSD 3-Clause
- **Version:** 4.7.0
- **Source:** https://gitlab.freedesktop.org/slirp/libslirp

## mTCP

TCP/IP applications for DOS: FTP, Telnet, DHCP, Ping, HTGET.
Included on the default FreeDOS disk in `C:\NET`.

- **License:** GNU General Public License (GPL) v3
- **Author:** Michael Brutman
- **Website:** https://www.brutman.com/mTCP/

## NE2000 Packet Driver

Crynwr NE2000 packet driver for DOS (NE2000.COM).
Included on the default FreeDOS disk in `C:\NET`.

- **License:** Open Source (Crynwr Software)
- **Source:** http://crynwr.com/drivers/

## Disk Catalog — External Downloads

The disk catalog links to external archives hosted by third parties.
These files are not bundled with the app; they are downloaded by the
user on demand.

### FreeDOS Official ISOs
- **Source:** freedos.org / ibiblio.org
- **License:** GPL v2+

### Simtel MS-DOS Archive
- **Source:** archive.org
- **License:** Shareware / Public Domain collection
- **Contents:** Thousands of MS-DOS utilities, tools, and shareware
  from the Simtel mirror network (1990s)

### Walnut Creek CD-ROMs
- **Source:** archive.org
- **License:** Shareware / Public Domain collection
- **Contents:** Curated DOS software collections from Walnut Creek
  CDROM (founded 1991)

## ZIPFoundation

Used for extracting downloaded ZIP archives.

- **License:** MIT License
- **Source:** https://github.com/weichsel/ZIPFoundation
