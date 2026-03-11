# Networking with NE2000

FreeDOS emulates an NE2000 Ethernet adapter. With a packet driver and TCP/IP stack, you can use FTP, Telnet, IRC, and other network applications from DOS.

## What You Need

1. **NE2000 packet driver** — included with FreeDOS, or from crynwr.com
2. **mTCP** — lightweight TCP/IP stack from brutman.com/mTCP

## Setup

### 1. Load the Packet Driver

```
C:\DRIVERS> NE2000 0x60 3 0x300
```

The three arguments are: software interrupt (0x60), hardware IRQ (3), and I/O base (0x300). These match the emulated NIC's defaults.

### 2. Configure mTCP

Create `C:\MTCP\MTCP.CFG`:

```
PACKETINT 0x60
HOSTNAME  FREEDOS
```

Set the environment variable:

```
SET MTCPCFG=C:\MTCP\MTCP.CFG
```

### 3. Get an IP Address

If your network has DHCP:

```
C:\MTCP> DHCP
```

For a static IP, add these to MTCP.CFG:

```
IPADDR     192.168.1.100
NETMASK    255.255.255.0
GATEWAY    192.168.1.1
NAMESERVER 8.8.8.8
```

### 4. Use the Network

```
C:\MTCP> PING 8.8.8.8
C:\MTCP> FTP ftp.example.com
C:\MTCP> TELNET bbs.example.com
C:\MTCP> HTGET http://example.com/file.zip file.zip
```

## NIC Settings

| Parameter | Value |
|-----------|-------|
| I/O Base | 0x300 |
| IRQ | 3 |
| MAC Address | 52:54:00:12:34:56 |

## Troubleshooting

- **"No NE2000 found"** — make sure networking is enabled (CLI: `-net` flag)
- **DHCP timeout** — check that the host machine has network access
- **Can ping but can't resolve names** — check NAMESERVER in MTCP.CFG
