#!/bin/bash
# Build a FreeDOS games hard disk image (non-bootable, mount as D:)
# Contains bundled shareware games + FreeDOS open-source games from LiveCD
#
# Sources:
#   1. fd/games/         - bundled shareware games (archive.org freeware)
#   2. FreeDOS 1.4 LiveCD ISO packages/games/ - open-source games

set -e

IMGDIR="$(cd "$(dirname "$0")/.." && pwd)"
OUTIMG="$IMGDIR/fd/freedos_games.img"
GAMEDIR="$IMGDIR/fd/games"

# Download shareware games bundle if not present
if [ ! -d "$GAMEDIR" ]; then
  echo "Downloading shareware games bundle..."
  GAMES_URL="https://github.com/avwohl/iosFreeDOS/releases/download/v1.0.17/shareware-games.tar.gz"
  curl -L -o /tmp/shareware-games.tar.gz "$GAMES_URL"
  tar xzf /tmp/shareware-games.tar.gz -C "$IMGDIR/fd"
  rm -f /tmp/shareware-games.tar.gz
fi

# --- Locate LiveCD ISO ---
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
CYLS=407  # ~200MB
TOTAL_SECTORS=$((CYLS * HEADS * SPT))
PART_START=63
PART_SECTORS=$((TOTAL_SECTORS - PART_START))
IMG_SIZE=$((TOTAL_SECTORS * 512))

echo "Creating ${IMG_SIZE} byte ($((IMG_SIZE/1024/1024))MB) games disk..."

# 1. Create blank image with MBR
dd if=/dev/zero of="$OUTIMG" bs=512 count=$TOTAL_SECTORS 2>/dev/null

# 2. Write MBR (non-bootable - just partition table, no active flag)
python3 -c "
import struct, sys

mbr = bytearray(512)
part = bytearray(16)
part[0] = 0x00  # NOT active (non-bootable)
part[1] = 1; part[2] = 1; part[3] = 0
part[4] = 0x06  # FAT16
end_cyl = $CYLS - 1
part[5] = ($HEADS - 1) & 0xFF
part[6] = ($SPT & 0x3F) | ((end_cyl >> 2) & 0xC0)
part[7] = end_cyl & 0xFF
struct.pack_into('<I', part, 8, $PART_START)
struct.pack_into('<I', part, 12, $PART_SECTORS)
mbr[446:462] = part
mbr[510] = 0x55; mbr[511] = 0xAA
sys.stdout.buffer.write(mbr)
" > /tmp/mbr_games.bin

dd if=/tmp/mbr_games.bin of="$OUTIMG" bs=512 count=1 conv=notrunc 2>/dev/null

# 3. Format partition
dd if=/dev/zero of=/tmp/partition_games.img bs=512 count=$PART_SECTORS 2>/dev/null
mkfs.fat -F 16 -n "GAMES" -h $PART_START -S 512 -s 8 /tmp/partition_games.img
dd if=/tmp/partition_games.img of="$OUTIMG" bs=512 seek=$PART_START conv=notrunc 2>/dev/null

# 4. Set up mtools
export MTOOLS_SKIP_CHECK=1
PART_OFFSET=$((PART_START * 512))
cat > /tmp/mtoolsrc_games << EOF
mtools_skip_check=1
drive d: file="$OUTIMG" offset=$PART_OFFSET
EOF
export MTOOLSRC=/tmp/mtoolsrc_games

# Helper: recursively copy a directory to the image
copy_tree() {
  local src="$1" dest="$2"
  [ -d "$src" ] || return 0
  mmd "$dest" 2>/dev/null || true
  for f in "$src"/*; do
    local bn=$(basename "$f")
    if [ -f "$f" ]; then
      mcopy -D o "$f" "$dest/$bn" 2>/dev/null || true
    elif [ -d "$f" ]; then
      copy_tree "$f" "$dest/$bn"
    fi
  done
}

# Helper: copy a bundled game (skips doc/metadata files)
copy_game() {
  local src="$1" dest="$2"
  mmd "d:/$dest" 2>/dev/null || true
  for f in "$src"/*; do
    if [ -f "$f" ]; then
      local bn=$(basename "$f")
      case "$bn" in
        *.txt|*.TXT|*.md|*.nfo|*.NFO|*.diz|*.DIZ|*.1st|*.doc|*.DOC) continue ;;
        run.bat|dosbox*.conf|*.ba1) continue ;;
      esac
      mcopy -D o "$f" "d:/$dest/$bn" 2>/dev/null || true
    elif [ -d "$f" ]; then
      local subdir=$(basename "$f")
      case "$subdir" in Documentation|__MACOSX|.git) continue ;; esac
      mmd "d:/$dest/$subdir" 2>/dev/null || true
      for sf in "$f"/*; do
        [ -f "$sf" ] && mcopy -D o "$sf" "d:/$dest/$subdir/$(basename "$sf")" 2>/dev/null || true
      done
    fi
  done
}

# =========================================================================
# 5. Install bundled shareware games
# =========================================================================
echo "Installing bundled shareware games..."

[ -d "$GAMEDIR/biomenace/BioMenac" ] && { echo "  Bio Menace"; copy_game "$GAMEDIR/biomenace/BioMenac" "BIOMENAC"; }
[ -d "$GAMEDIR/skyroads" ] && { echo "  SkyRoads"; copy_game "$GAMEDIR/skyroads" "SKYROADS"; }
[ -d "$GAMEDIR/godofthunder/godthund" ] && { echo "  God of Thunder"; copy_game "$GAMEDIR/godofthunder/godthund" "GOT"; }
[ -d "$GAMEDIR/darkages/DarkAges" ] && { echo "  Dark Ages"; copy_game "$GAMEDIR/darkages/DarkAges" "DARKAGES"; }
[ -d "$GAMEDIR/jill/JillJung" ] && { echo "  Jill of the Jungle"; copy_game "$GAMEDIR/jill/JillJung" "JILL"; }
[ -d "$GAMEDIR/xargon/Xargon" ] && { echo "  Xargon"; copy_game "$GAMEDIR/xargon/Xargon" "XARGON"; }
[ -d "$GAMEDIR/majorstryker/MajorStr/MAJOR" ] && { echo "  Major Stryker"; copy_game "$GAMEDIR/majorstryker/MajorStr/MAJOR" "STRYKER"; }
[ -d "$GAMEDIR/aliencarnage/AlienCar" ] && { echo "  Alien Carnage"; copy_game "$GAMEDIR/aliencarnage/AlienCar" "ALIENCAR"; }
[ -d "$GAMEDIR/duke1" ] && {
  echo "  Duke Nukem 1"
  if [ -d "$GAMEDIR/duke1/DUKE" ]; then copy_game "$GAMEDIR/duke1/DUKE" "DUKE1"
  else copy_game "$GAMEDIR/duke1" "DUKE1"; fi
}
[ -d "$GAMEDIR/kroz" ] && { echo "  Kingdom of Kroz"; copy_game "$GAMEDIR/kroz" "KROZ"; }
[ -d "$GAMEDIR/supaplex" ] && { echo "  Supaplex"; copy_game "$GAMEDIR/supaplex" "SUPAPLEX"; }

if [ -f "$IMGDIR/fd/GAMES.TXT" ]; then
  mcopy -D o "$IMGDIR/fd/GAMES.TXT" "d:/GAMES.TXT"
fi

# =========================================================================
# 6. Install FreeDOS open-source games from LiveCD
# =========================================================================
if [ -n "$LIVEISO" ]; then
  LIVE_MNT=$(hdiutil attach "$LIVEISO" -readonly -nobrowse 2>/dev/null | tail -1 | awk '{print $NF}')
  echo "  Mounted LiveCD at $LIVE_MNT"

  pkgdir="$LIVE_MNT/packages/games"
  if [ -d "$pkgdir" ]; then
    echo "Installing FreeDOS open-source games..."
    for z in "$pkgdir"/*.zip; do
      [ -f "$z" ] || continue
      local_name=$(basename "$z" .zip | tr '[:lower:]' '[:upper:]')
      echo "  $local_name"
      tmpdir="/tmp/fdgame_$$"
      mkdir -p "$tmpdir"
      unzip -o -q "$z" -d "$tmpdir" -x 'SOURCE/*' 'source/*' 2>/dev/null || true
      # Games packages put executables in BIN/ and game data in GAMES/
      for d in "$tmpdir"/*/; do
        [ -d "$d" ] || continue
        dname=$(basename "$d" | tr '[:lower:]' '[:upper:]')
        if [ "$dname" = "BIN" ] || [ "$dname" = "APPINFO" ] || [ "$dname" = "DOC" ] || \
           [ "$dname" = "HELP" ] || [ "$dname" = "NLS" ] || [ "$dname" = "LINKS" ] || \
           [ "$dname" = "BATLINKS" ]; then
          # Skip metadata dirs, copy BIN contents to root so games find their exes
          if [ "$dname" = "BIN" ]; then
            for f in "$d"/*; do
              [ -f "$f" ] && mcopy -D o "$f" "d:/$(basename "$f")" 2>/dev/null || true
            done
          fi
        else
          copy_tree "$d" "d:/$dname"
        fi
      done
      rm -rf "$tmpdir"
    done
  fi

  hdiutil detach "$LIVE_MNT" -quiet 2>/dev/null || true
fi

echo ""
echo "Games disk created: $OUTIMG"
echo "Size: $(ls -lh "$OUTIMG" | awk '{print $5}')"
echo ""
echo "Contents:"
mdir d: 2>/dev/null || echo "(mdir failed)"
echo ""
echo "Free space:"
minfo d: 2>/dev/null | grep -i "free\|total" || true
