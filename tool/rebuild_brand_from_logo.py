"""Rebuild DriveFlow branding assets from the ChatGPT master logo."""

from __future__ import annotations

from pathlib import Path

from PIL import Image

SRC = Path(
    r"C:\Users\pedro\AppData\Roaming\Cursor\User\workspaceStorage"
    r"\6251db7404e00596246923a7ce1747a6\images"
    r"\ChatGPT Image 12 de jul. de 2026, 11_05_39-6a0d2bfc-450e-44b6-b381-1c758c839e02.png"
)
OUT = Path(__file__).resolve().parents[1] / "assets" / "branding"
BRAND = (0x00, 0x64, 0xF5)


def closest_brand_blue(img: Image.Image) -> Image.Image:
    """Normalize near-blue background to exact #0064F5; keep white glyph."""
    rgba = img.convert("RGBA")
    pixels = rgba.load()
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            if a < 20:
                continue
            # White / near-white glyph
            if r > 220 and g > 220 and b > 220:
                pixels[x, y] = (255, 255, 255, 255)
                continue
            # Blue-ish background → brand blue
            if b > r and b > g:
                pixels[x, y] = (*BRAND, 255)
                continue
            # Soft anti-alias on edges: blend toward white or blue by luminance
            lum = (r + g + b) / 3
            if lum > 160:
                t = (lum - 160) / 95
                t = max(0.0, min(1.0, t))
                pixels[x, y] = (
                    int(BRAND[0] + (255 - BRAND[0]) * t),
                    int(BRAND[1] + (255 - BRAND[1]) * t),
                    int(BRAND[2] + (255 - BRAND[2]) * t),
                    255,
                )
            else:
                pixels[x, y] = (*BRAND, 255)
    return rgba


def extract_glyph(rgba: Image.Image) -> Image.Image:
    """White glyph on transparent — for adaptive foreground + splash."""
    out = Image.new("RGBA", rgba.size, (0, 0, 0, 0))
    src = rgba.load()
    dst = out.load()
    w, h = rgba.size
    for y in range(h):
        for x in range(w):
            r, g, b, a = src[x, y]
            if a < 20:
                continue
            # Distance from brand blue vs white
            dist_blue = abs(r - BRAND[0]) + abs(g - BRAND[1]) + abs(b - BRAND[2])
            dist_white = (255 - r) + (255 - g) + (255 - b)
            if dist_white < dist_blue:
                # Opacity from how white it is
                strength = max(0, min(255, int(255 - dist_white / 3)))
                if strength > 12:
                    dst[x, y] = (255, 255, 255, strength)
    return out


def content_bbox(glyph: Image.Image, alpha_thresh: int = 20) -> tuple[int, int, int, int]:
    alpha = glyph.split()[3]
    return alpha.getbbox() or (0, 0, glyph.width, glyph.height)


def fit_glyph(
    glyph: Image.Image,
    canvas: int,
    fill_ratio: float,
) -> Image.Image:
    """Center glyph on transparent canvas with target fill ratio."""
    box = content_bbox(glyph)
    cropped = glyph.crop(box)
    target = int(canvas * fill_ratio)
    cw, ch = cropped.size
    scale = target / max(cw, ch)
    nw, nh = max(1, int(cw * scale)), max(1, int(ch * scale))
    resized = cropped.resize((nw, nh), Image.LANCZOS)
    out = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
    out.paste(resized, ((canvas - nw) // 2, (canvas - nh) // 2), resized)
    return out


def rounded_mark(master_rgb: Image.Image, size: int = 512, radius_ratio: float = 0.22) -> Image.Image:
    from PIL import ImageDraw

    base = master_rgb.resize((size, size), Image.LANCZOS).convert("RGBA")
    mask = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(mask)
    r = int(size * radius_ratio)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=r, fill=255)
    out = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    out.paste(base, mask=mask)
    return out


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    raw = Image.open(SRC)
    print("source", raw.size, raw.mode)

    normalized = closest_brand_blue(raw)
    # Master: opaque 1024 RGB
    master = normalized.convert("RGB").resize((1024, 1024), Image.LANCZOS)
    # Re-normalize after resize for cleaner edges
    master_rgba = closest_brand_blue(master.convert("RGBA"))
    master = Image.new("RGB", (1024, 1024), BRAND)
    master.paste(master_rgba, mask=master_rgba.split()[3])

    glyph = extract_glyph(normalized)
    # Adaptive foreground — safe zone ~66% (fill ~0.52–0.58)
    foreground = fit_glyph(glyph, 1024, 0.56)
    # Splash — larger glyph on transparent
    splash = fit_glyph(glyph, 512, 0.62)
    # In-app rounded tile
    mark = rounded_mark(master, 512, 0.22)

    master.save(OUT / "icon_master_1024.png", "PNG")
    foreground.save(OUT / "icon_foreground_1024.png", "PNG")
    splash.save(OUT / "splash_logo.png", "PNG")
    mark.save(OUT / "mark_df.png", "PNG")
    # Keep original reference
    normalized.convert("RGB").resize((1024, 1024), Image.LANCZOS).save(
        OUT / "logo_source_1024.png", "PNG"
    )
    print("wrote", sorted(p.name for p in OUT.iterdir()))


if __name__ == "__main__":
    main()
