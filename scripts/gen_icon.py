#!/usr/bin/env python3
"""Generate qxDOS app icon with green phosphor dot C> prompt.

Style matches the ioscpm icon (A> prompt) but uses C> for DOS.

Requires: pip3 install Pillow
"""

import math
import os
import sys

try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    print("Pillow not installed. Run: pip3 install Pillow")
    sys.exit(1)

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
ASSETS_DIR = os.path.join(SCRIPT_DIR, "..", "qxDOS", "Assets.xcassets")
ICON_DIR = os.path.join(ASSETS_DIR, "AppIcon.appiconset")
LOGO_DIR = os.path.join(ASSETS_DIR, "AppLogo.imageset")

# 5x7 bitmap font characters (and 6-wide block cursor)
CHARS = {
    'C': [
        "01110",
        "10001",
        "10000",
        "10000",
        "10000",
        "10001",
        "01110",
    ],
    '>': [
        "10000",
        "01000",
        "00100",
        "00010",
        "00100",
        "01000",
        "10000",
    ],
    'BLOCK': [
        "111111",
        "111111",
        "111111",
        "111111",
        "111111",
        "111111",
        "111111",
    ],
    'D': [
        "11110",
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "11110",
    ],
    'O': [
        "01110",
        "10001",
        "10001",
        "10001",
        "10001",
        "10001",
        "01110",
    ],
    'S': [
        "01110",
        "10001",
        "10000",
        "01110",
        "00001",
        "10001",
        "01110",
    ],
}

GREEN = (51, 255, 51)

# Mac icon sizes (filename, pixel size)
MAC_SIZES = [
    ("icon_16.png", 16),
    ("icon_32.png", 32),
    ("icon_64.png", 64),
    ("icon_128.png", 128),
    ("icon_256.png", 256),
    ("icon_512.png", 512),
    ("icon_1024_mac.png", 1024),
]


def draw_char_dots(draw, bitmap, x, y, radius, spacing, color):
    """Draw a character from its bitmap as phosphor dots."""
    for row_idx, row in enumerate(bitmap):
        for col_idx, pixel in enumerate(row):
            if pixel == '1':
                cx = x + col_idx * spacing
                cy = y + row_idx * spacing
                draw.ellipse(
                    [cx - radius, cy - radius, cx + radius, cy + radius],
                    fill=color
                )


def calc_width(text, spacing, gap):
    """Calculate pixel width of a string rendered in dot font."""
    width = 0
    for i, ch in enumerate(text):
        if ch == ' ':
            width += spacing * 2
            continue
        bitmap = CHARS.get(ch)
        if bitmap:
            width += len(bitmap[0]) * spacing
            if i < len(text) - 1:
                width += gap
    return width


def create_icon(size=1024):
    """Generate the qxDOS icon at the given size."""
    img = Image.new('RGB', (size, size), (0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Subtle radial gradient background
    cx, cy = size / 2, size / 2
    for y in range(size):
        for x in range(size):
            dx = (x - cx) / cx
            dy = (y - cy) / cy
            dist = math.sqrt(dx * dx + dy * dy)
            val = int(max(0, 12 - dist * 10))
            if val > 0:
                img.putpixel((x, y), (val, val, val))

    # Glow layer
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)

    # --- Large dots: C> cursor ---
    lr = 14           # dot radius
    ls = 38           # dot spacing
    lg = 18           # inter-character gap
    glow_r = int(lr * 2.2)

    # Layout: C  >  BLOCK   (with space before block cursor)
    parts = ['C', '>', 'BLOCK']
    widths = [len(CHARS[p][0]) * ls for p in parts]
    total_w = sum(widths) + lg + ls * 2  # gap after C, space before block
    px = (size - total_w) // 2
    py = 290

    def draw_with_glow(bitmap, x, y, r, sp):
        draw_char_dots(draw, bitmap, x, y, r, sp, GREEN)
        gr = int(r * 2.2)
        for ri, row in enumerate(bitmap):
            for ci, pixel in enumerate(row):
                if pixel == '1':
                    dcx = x + ci * sp
                    dcy = y + ri * sp
                    glow_draw.ellipse(
                        [dcx - gr, dcy - gr, dcx + gr, dcy + gr],
                        fill=(51, 255, 51, 30)
                    )

    # C
    draw_with_glow(CHARS['C'], px, py, lr, ls)
    x = px + widths[0] + lg
    # >
    draw_with_glow(CHARS['>'], x, py, lr, ls)
    x += widths[1] + ls * 2
    # block cursor
    draw_with_glow(CHARS['BLOCK'], x, py, lr, ls)

    # --- Small dots: DOS ---
    sr = 7
    ss = 19
    sg = 12
    dos_w = calc_width("DOS", ss, sg)
    dos_x = (size - dos_w) // 2
    dos_y = 590

    for ch in "DOS":
        bm = CHARS[ch]
        draw_with_glow(bm, dos_x, dos_y, sr, ss)
        dos_x += len(bm[0]) * ss + sg

    # Composite glow
    glow_blurred = glow.filter(ImageFilter.GaussianBlur(radius=12))
    glow_rgb = glow_blurred.convert('RGB')
    result = Image.blend(img, glow_rgb, 0.4)

    # Restore background gradient and redraw crisp dots on top
    draw2 = ImageDraw.Draw(result)
    for y in range(size):
        for x in range(size):
            r, g, b = result.getpixel((x, y))
            dx = (x - cx) / cx
            dy = (y - cy) / cy
            dist = math.sqrt(dx * dx + dy * dy)
            base = int(max(0, 12 - dist * 10))
            result.putpixel((x, y), (max(r, base), max(g, base), max(b, base)))

    # Redraw crisp dots
    px2 = (size - total_w) // 2
    draw_char_dots(draw2, CHARS['C'], px2, py, lr, ls, GREEN)
    x2 = px2 + widths[0] + lg
    draw_char_dots(draw2, CHARS['>'], x2, py, lr, ls, GREEN)
    x2 += widths[1] + ls * 2
    draw_char_dots(draw2, CHARS['BLOCK'], x2, py, lr, ls, GREEN)

    dos_x2 = (size - calc_width("DOS", ss, sg)) // 2
    for ch in "DOS":
        bm = CHARS[ch]
        draw_char_dots(draw2, bm, dos_x2, dos_y, sr, ss, GREEN)
        dos_x2 += len(bm[0]) * ss + sg

    return result


def generate_icon_contents_json():
    return """{
  "images" : [
    {
      "filename" : "appicon.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "dark"
        }
      ],
      "filename" : "appicon-dark.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "appearances" : [
        {
          "appearance" : "luminosity",
          "value" : "tinted"
        }
      ],
      "filename" : "appicon-tinted.png",
      "idiom" : "universal",
      "platform" : "ios",
      "size" : "1024x1024"
    },
    {
      "filename" : "icon_16.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "filename" : "icon_32.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_64.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "filename" : "icon_128.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "filename" : "icon_256.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "filename" : "icon_512.png",
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "filename" : "icon_1024_mac.png",
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}"""


def generate_logo_contents_json():
    return """{
  "images" : [
    {
      "filename" : "applogo.png",
      "idiom" : "universal",
      "scale" : "1x"
    },
    {
      "filename" : "applogo@2x.png",
      "idiom" : "universal",
      "scale" : "2x"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}"""


def main():
    os.makedirs(ICON_DIR, exist_ok=True)
    os.makedirs(LOGO_DIR, exist_ok=True)

    print("Rendering 1024x1024 icon...")
    icon = create_icon(1024)

    # iOS icon (single 1024x1024)
    icon.save(os.path.join(ICON_DIR, "appicon.png"), "PNG")
    print("  Saved appicon.png")

    # Dark variant (same image — already dark)
    icon.save(os.path.join(ICON_DIR, "appicon-dark.png"), "PNG")
    print("  Saved appicon-dark.png")

    # Tinted variant (white for iOS tinting)
    tinted = Image.new('RGB', (1024, 1024), (255, 255, 255))
    tinted.save(os.path.join(ICON_DIR, "appicon-tinted.png"), "PNG")
    print("  Saved appicon-tinted.png")

    # Mac sizes
    for filename, sz in MAC_SIZES:
        resized = icon.resize((sz, sz), Image.LANCZOS)
        path = os.path.join(ICON_DIR, filename)
        resized.save(path, "PNG")
        print(f"  Saved {filename} ({sz}x{sz})")

    # Contents.json
    with open(os.path.join(ICON_DIR, "Contents.json"), "w") as f:
        f.write(generate_icon_contents_json())
    print("  Saved AppIcon Contents.json")

    # AppLogo for in-app display
    icon.resize((256, 256), Image.LANCZOS).save(
        os.path.join(LOGO_DIR, "applogo.png"), "PNG")
    icon.resize((512, 512), Image.LANCZOS).save(
        os.path.join(LOGO_DIR, "applogo@2x.png"), "PNG")
    with open(os.path.join(LOGO_DIR, "Contents.json"), "w") as f:
        f.write(generate_logo_contents_json())
    print("  Saved AppLogo images")

    # Top-level Assets.xcassets Contents.json
    top_contents = os.path.join(ASSETS_DIR, "Contents.json")
    with open(top_contents, "w") as f:
        f.write('{\n  "info" : {\n    "author" : "xcode",\n    "version" : 1\n  }\n}\n')

    print(f"\nDone! Generated app icon + logo.")


if __name__ == "__main__":
    main()
