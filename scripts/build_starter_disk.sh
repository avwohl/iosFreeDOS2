#!/bin/bash
# Build a small (~22MB) bootable FreeDOS starter disk with DOOM + Duke Nukem
# Minimal system + CWSDPMI + two classic games. Friendly for cellular downloads.

set -e

IMGDIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTIMG="$IMGDIR/fd/freedos_starter.img"
SRCIMG="$IMGDIR/fd/freedos.img"

# Download FreeDOS boot floppy if not present
if [ ! -f "$SRCIMG" ]; then
  echo "Downloading FreeDOS 1.4 boot floppy..."
  # Original: https://www.ibiblio.org/pub/micro/pc-stuff/freedos/files/distributions/1.4/official/FD14BOOT.img
  curl -L --retry 3 --connect-timeout 30 -o "$SRCIMG" \
    https://www.awohl.com/freedos/freedos.img
fi

# --- Locate LiveCD ISO for system files ---
find_iso() {
  local name="$1"
  for dir in "$IMGDIR/fd" "$HOME/Downloads" "$HOME/Downloads/old" \
             "$HOME/Downloads/old/FD14-LiveCD"; do
    [ -f "$dir/$name" ] && echo "$dir/$name" && return
  done
}

LIVEISO=$(find_iso "FD14LIVE.iso")
echo "LiveCD ISO:  ${LIVEISO:-not found}"

# Geometry: 16 heads, 63 sectors/track
HEADS=16
SPT=63
CYLS=45  # ~22MB
TOTAL_SECTORS=$((CYLS * HEADS * SPT))
PART_START=63
PART_SECTORS=$((TOTAL_SECTORS - PART_START))
IMG_SIZE=$((TOTAL_SECTORS * 512))

echo "Creating ${IMG_SIZE} byte ($((IMG_SIZE/1024/1024))MB) starter disk image..."
echo "Geometry: C=$CYLS H=$HEADS S=$SPT = $TOTAL_SECTORS sectors"

# 1. Create blank image
dd if=/dev/zero of="$OUTIMG" bs=512 count=$TOTAL_SECTORS 2>/dev/null

# 2. Write MBR boot code + partition table
python3 -c "
import struct, sys

code = bytearray(446)
boot2 = bytes([
    0xFA, 0x33, 0xC0, 0x8E, 0xD0, 0xBC, 0x00, 0x7C,
    0x8E, 0xD8, 0x8E, 0xC0, 0xFB,
    0xBE, 0xBE, 0x7D, 0xB9, 0x04, 0x00,
    0x80, 0x3C, 0x80, 0x74, 0x09,
    0x83, 0xC6, 0x10, 0xE2, 0xF5,
    0xCD, 0x18, 0xEB, 0xFE,
    0x8A, 0x74, 0x01, 0x8B, 0x4C, 0x02,
    0xB2, 0x80, 0xBB, 0x00, 0x7C,
    0xB8, 0x01, 0x02, 0xCD, 0x13,
    0x72, 0xFE,
    0xEA, 0x00, 0x7C, 0x00, 0x00,
])
code[:len(boot2)] = boot2

part = bytearray(16)
part[0] = 0x80
part[1] = 1; part[2] = 1; part[3] = 0
part[4] = 0x06
end_cyl = $CYLS - 1
part[5] = ($HEADS - 1) & 0xFF
part[6] = ($SPT & 0x3F) | ((end_cyl >> 2) & 0xC0)
part[7] = end_cyl & 0xFF
struct.pack_into('<I', part, 8, $PART_START)
struct.pack_into('<I', part, 12, $PART_SECTORS)

mbr = bytearray(512)
mbr[:len(code)] = code
mbr[446:462] = part
mbr[510] = 0x55; mbr[511] = 0xAA
sys.stdout.buffer.write(mbr)
" > /tmp/mbr.bin

dd if=/tmp/mbr.bin of="$OUTIMG" bs=512 count=1 conv=notrunc 2>/dev/null

# 3. Format partition as FAT16
dd if=/dev/zero of=/tmp/partition.img bs=512 count=$PART_SECTORS 2>/dev/null
mkfs.fat -F 16 -n "FREEDOS" -h $PART_START -S 512 -s 4 /tmp/partition.img
dd if=/tmp/partition.img of="$OUTIMG" bs=512 seek=$PART_START conv=notrunc 2>/dev/null

# 4. Set up mtools
export MTOOLS_SKIP_CHECK=1
PART_OFFSET=$((PART_START * 512))
cat > /tmp/mtoolsrc_starter << EOF
mtools_skip_check=1
drive c: file="$OUTIMG" offset=$PART_OFFSET
EOF
export MTOOLSRC=/tmp/mtoolsrc_starter

# =========================================================================
# 5. Install minimal FreeDOS system
# =========================================================================

# Mount LiveCD if available
LIVE_MNT=""
DID_MOUNT_LIVE=""
cleanup_mounts() {
  [ -n "$DID_MOUNT_LIVE" ] && hdiutil detach "$LIVE_MNT" -quiet 2>/dev/null || true
}
trap cleanup_mounts EXIT

mount_iso() {
  local iso="$1" label="$2"
  for vol in /Volumes/${label}*; do
    [ -d "$vol" ] && echo "$vol" && return 0
  done
  local out=$(hdiutil attach "$iso" -readonly -nobrowse 2>&1)
  if [ $? -eq 0 ]; then
    echo "$out" | tail -1 | sed 's/.*	//'
    echo "NEW" >&2
    return 0
  fi
  return 1
}

if [ -n "$LIVEISO" ]; then
  LIVE_MNT=$(mount_iso "$LIVEISO" "FD14-Live" 2>/tmp/mount_live_status)
  if [ -z "$LIVE_MNT" ]; then
    echo "  WARNING: Failed to mount LiveCD"
  else
    echo "  LiveCD at $LIVE_MNT"
    grep -q NEW /tmp/mount_live_status 2>/dev/null && DID_MOUNT_LIVE=1
  fi
fi

echo "Installing FreeDOS kernel..."
mcopy -i "$SRCIMG" ::KERNEL.SYS /tmp/KERNEL.SYS
mcopy -D o /tmp/KERNEL.SYS c:

if [ -n "$LIVE_MNT" ] && [ -d "$LIVE_MNT/freedos" ]; then
  echo "  Copying minimal FreeDOS system from LiveCD..."
  mmd c:/FREEDOS 2>/dev/null || true
  mmd c:/FREEDOS/BIN 2>/dev/null || true
  mmd c:/FREEDOS/NLS 2>/dev/null || true

  # Copy only essential binaries
  ESSENTIAL="COMMAND.COM CWSDPMI.EXE MEM.EXE MORE.COM TYPE.COM DIR.COM DELTREE.EXE EDIT.EXE XCOPY.EXE CHOICE.EXE FDISK.EXE FORMAT.EXE SYS.COM LABEL.EXE SHSUCDX.COM"
  for f in $ESSENTIAL; do
    if [ -f "$LIVE_MNT/freedos/bin/$f" ]; then
      mcopy -D o "$LIVE_MNT/freedos/bin/$f" "c:/FREEDOS/BIN/$f" 2>/dev/null || true
    elif [ -f "$LIVE_MNT/freedos/bin/$(echo $f | tr '[:upper:]' '[:lower:]')" ]; then
      mcopy -D o "$LIVE_MNT/freedos/bin/$(echo $f | tr '[:upper:]' '[:lower:]')" "c:/FREEDOS/BIN/$f" 2>/dev/null || true
    fi
  done

  # COMMAND.COM must be in root for boot
  if [ -f "$LIVE_MNT/COMMAND.COM" ]; then
    mcopy -D o "$LIVE_MNT/COMMAND.COM" c:
  fi
else
  echo "  No LiveCD ISO found - using boot floppy"
  mmd c:/FREEDOS 2>/dev/null || true
  mmd c:/FREEDOS/BIN 2>/dev/null || true
  mcopy -i "$SRCIMG" ::/FREEDOS/BIN/COMMAND.COM /tmp/COMMAND.COM
  mcopy -D o /tmp/COMMAND.COM c:
  mcopy -D o /tmp/COMMAND.COM c:/FREEDOS/BIN/
  for f in $(mdir -b -i "$SRCIMG" ::/FREEDOS/BIN/ 2>/dev/null | grep -v "^$"); do
    bn=$(echo "$f" | sed 's|.*/||')
    mcopy -i "$SRCIMG" "::FREEDOS/BIN/$bn" /tmp/"$bn" 2>/dev/null || true
    mcopy -D o /tmp/"$bn" "c:/FREEDOS/BIN/$bn" 2>/dev/null || true
  done
fi

# =========================================================================
# 6. Configuration
# =========================================================================
cat > /tmp/FDCONFIG.SYS << 'CFGEOF'
LASTDRIVE=Z
FILES=40
BUFFERS=20
DOS=HIGH
SHELL=C:\COMMAND.COM C:\ /E:1024 /P
CFGEOF
mcopy -D o /tmp/FDCONFIG.SYS c:

cat > /tmp/AUTOEXEC.BAT << 'BATEOF'
@ECHO OFF
SET DOSDIR=C:\FREEDOS
SET PATH=C:\FREEDOS\BIN;C:\DOOM;C:\DUKE
SET NLSPATH=C:\FREEDOS\NLS
SET TEMP=C:\TEMP
SET DIRCMD=/OGN
PROMPT $P$G
IF NOT EXIST C:\TEMP\NUL MD C:\TEMP
C:\FREEDOS\BIN\CWSDPMI -p
ECHO.
ECHO Type DOOM to play DOOM (VGA), or DUKE to play Duke Nukem (EGA).
ECHO.
BATEOF
mcopy -D o /tmp/AUTOEXEC.BAT c:

mmd c:/TEMP 2>/dev/null || true

# Install R.COM and W.COM
if [ -f "$IMGDIR/dos/r.com" ]; then
    mcopy -D o "$IMGDIR/dos/r.com" "c:/FREEDOS/BIN/R.COM"
    mcopy -D o "$IMGDIR/dos/w.com" "c:/FREEDOS/BIN/W.COM"
    echo "Installed R.COM and W.COM"
fi

# Install DPMITEST.COM
if [ -f "$IMGDIR/dos/dpmitest.com" ]; then
    mcopy -D o "$IMGDIR/dos/dpmitest.com" "c:/DPMITEST.COM"
    echo "Installed DPMITEST.COM"
fi

# =========================================================================
# 7. Install DOOM shareware
# =========================================================================
echo "Installing DOOM shareware..."
mmd c:/DOOM 2>/dev/null || true

DOOM_DIR=""
# Check for pre-extracted DOOM files
for dir in /tmp/doom_sw "$IMGDIR/fd/doom"; do
  if [ -f "$dir/DOOM.EXE" ] && [ -f "$dir/DOOM1.WAD" ]; then
    DOOM_DIR="$dir"
    break
  fi
done

if [ -n "$DOOM_DIR" ]; then
  mcopy -D o "$DOOM_DIR/DOOM.EXE" c:/DOOM/
  mcopy -D o "$DOOM_DIR/DOOM1.WAD" c:/DOOM/
  mcopy -D o "$DOOM_DIR/DEFAULT.CFG" c:/DOOM/ 2>/dev/null || true
  echo "  DOOM installed from $DOOM_DIR"
else
  echo "  WARNING: DOOM files not found - download doom shareware to /tmp/doom_sw/"
fi

# =========================================================================
# 8. Install Duke Nukem 1
# =========================================================================
echo "Installing Duke Nukem 1..."
mmd c:/DUKE 2>/dev/null || true

DUKE_DIR=""
for dir in "$IMGDIR/fd/games/duke1" "$IMGDIR/fd/duke1"; do
  if [ -d "$dir" ]; then
    DUKE_DIR="$dir"
    break
  fi
done

if [ -n "$DUKE_DIR" ]; then
  for f in "$DUKE_DIR"/*; do
    [ -f "$f" ] && mcopy -D o "$f" "c:/DUKE/$(basename "$f" | tr '[:lower:]' '[:upper:]')" 2>/dev/null || true
  done
  # Copy from subdirectories too
  for d in "$DUKE_DIR"/*/; do
    [ -d "$d" ] || continue
    for f in "$d"*; do
      [ -f "$f" ] && mcopy -D o "$f" "c:/DUKE/$(basename "$f" | tr '[:lower:]' '[:upper:]')" 2>/dev/null || true
    done
  done
  echo "  Duke Nukem installed from $DUKE_DIR"
else
  echo "  WARNING: Duke Nukem files not found"
fi

# =========================================================================
# 9. Boot sector
# =========================================================================
dd if="$SRCIMG" of=/tmp/floppy_boot.bin bs=512 count=1 2>/dev/null

python3 -c "
import struct, sys
floppy = open('/tmp/floppy_boot.bin', 'rb').read()
partition = open('$OUTIMG', 'rb')
partition.seek($PART_START * 512)
part_boot = bytearray(partition.read(512))
partition.close()
result = bytearray(part_boot)
result[0:3] = floppy[0:3]
result[3:11] = floppy[3:11]
struct.pack_into('<I', result, 0x1C, $PART_START)
result[0x3E:510] = floppy[0x3E:510]
result[510] = 0x55; result[511] = 0xAA
sys.stdout.buffer.write(bytes(result))
" > /tmp/new_boot.bin

dd if=/tmp/new_boot.bin of="$OUTIMG" bs=512 seek=$PART_START count=1 conv=notrunc 2>/dev/null

echo "Patching boot sector for FAT16..."
python3 -c "
import sys
data = bytearray(open('$OUTIMG', 'rb').read())
boot_off = $PART_START * 512
fat12 = bytes([0xAB,0x89,0xC6,0x01,0xF6,0x01,0xC6,0xD1,0xEE,0xAD,
               0x73,0x04,0xB1,0x04,0xD3,0xE8,0x80,0xE4,0x0F,0x3D,
               0xF8,0x0F,0x72,0xE8])
actual = bytes(data[boot_off+0xFC : boot_off+0xFC+24])
if actual != fat12:
    print('WARNING: Boot sector bytes differ, skipping FAT16 patch')
    sys.exit(0)
fat16 = bytes([0xAB,0x89,0xC6,0x01,0xF6,0xAD,0x3D,0xF8,0xFF,
               0x72,0xF5] + [0x90]*13)
data[boot_off+0xFC : boot_off+0xFC+24] = fat16
open('$OUTIMG', 'wb').write(data)
print('  FAT16 cluster chain patch applied')
"

echo ""
echo "Starter disk created: $OUTIMG"
echo "Size: $(ls -lh "$OUTIMG" | awk '{print $5}')"
echo ""
echo "Contents:"
mdir c: 2>/dev/null || echo "(mdir failed)"
echo ""
echo "Free space:"
minfo c: 2>/dev/null | grep -i "free\|total" || true
