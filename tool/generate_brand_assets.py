"""Generate DriveFlow DF monogram brand assets."""

from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw

OUT = Path(__file__).resolve().parents[1] / "assets" / "branding"
BRAND = (0x00, 0x64, 0xF5, 255)
WHITE = (255, 255, 255, 255)
CLEAR = (0, 0, 0, 0)


def make_df_layer(size: int, letter_h_ratio: float, color: tuple[int, int, int, int]) -> Image.Image:
    """Transparent canvas with a geometric DF monogram, optically centered."""
    img = Image.new("RGBA", (size, size), CLEAR)
    draw = ImageDraw.Draw(img)

    h = size * letter_h_ratio
    stroke = h * 0.20
    cx, cy = size / 2, size / 2
    total_w = h * 1.05
    left = cx - total_w / 2
    top = cy - h / 2

    # --- D ---
    d_w = h * 0.48
    draw.rectangle([left, top, left + stroke, top + h], fill=color)

    cx_d = left + stroke * 0.55
    pts: list[tuple[float, float]] = []
    for i in range(0, 61):
        a = -math.pi / 2 + math.pi * (i / 60)
        x = cx_d + (d_w - stroke * 0.1) * math.cos(a)
        y = cy + (h / 2) * math.sin(a)
        pts.append((x, y))
    for i in range(60, -1, -1):
        a = -math.pi / 2 + math.pi * (i / 60)
        r_in_x = max(d_w - stroke * 0.1 - stroke, 0)
        r_in_y = h / 2 - stroke
        x = cx_d + r_in_x * math.cos(a)
        y = cy + r_in_y * math.sin(a)
        pts.append((x, y))
    draw.polygon(pts, fill=color)
    draw.rectangle([left, top, left + stroke + 2, top + stroke], fill=color)
    draw.rectangle([left, top + h - stroke, left + stroke + 2, top + h], fill=color)

    # --- F ---
    f_left = left + d_w + h * 0.08
    f_bar_w = h * 0.42
    draw.rectangle([f_left, top, f_left + stroke, top + h], fill=color)
    draw.rectangle([f_left, top, f_left + f_bar_w, top + stroke], fill=color)
    mid_y = top + h * 0.42
    draw.rectangle([f_left, mid_y, f_left + f_bar_w * 0.78, mid_y + stroke], fill=color)

    return img


def icon_master(size: int = 1024) -> Image.Image:
    """Opaque full-bleed blue square + white DF (OS applies mask)."""
    df = make_df_layer(size, 0.42, WHITE)
    bg = Image.new("RGB", (size, size), BRAND[:3])
    bg.paste(Image.new("RGB", (size, size), BRAND[:3]))
    rgba = Image.new("RGBA", (size, size), BRAND)
    rgba = Image.alpha_composite(rgba, df)
    out = Image.new("RGB", (size, size), BRAND[:3])
    out.paste(rgba, mask=rgba.split()[3])
    return out


def icon_foreground(size: int = 1024) -> Image.Image:
    """Transparent adaptive foreground — letters in ~66% safe zone."""
    return make_df_layer(size, 0.38, WHITE)


def splash_logo(size: int = 512) -> Image.Image:
    """White DF on transparent for native splash."""
    return make_df_layer(size, 0.55, WHITE)


def mark_df(size: int = 512) -> Image.Image:
    """Rounded blue tile + white DF for in-app mark."""
    tile = Image.new("RGBA", (size, size), CLEAR)
    draw = ImageDraw.Draw(tile)
    radius = int(size * 0.22)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=radius, fill=BRAND)
    df = make_df_layer(size, 0.48, WHITE)
    return Image.alpha_composite(tile, df)


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    icon_master(1024).save(OUT / "icon_master_1024.png", "PNG")
    icon_foreground(1024).save(OUT / "icon_foreground_1024.png", "PNG")
    splash_logo(512).save(OUT / "splash_logo.png", "PNG")
    mark_df(512).save(OUT / "mark_df.png", "PNG")
    print("Generated:", sorted(p.name for p in OUT.iterdir()))


if __name__ == "__main__":
    main()
