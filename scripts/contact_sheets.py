#!/usr/bin/env python3
"""Design-review contact sheets for the 20 iPlayr themes, Dark and Light.

Reads the constants straight out of the Swift sources (ThemeTable.swift and
ModeTokens.swift); nothing is retyped here. Output: design/contact-dark.png and
design/contact-light.png, each a 5 x 4 grid in gallery order. This is a review
aid drawn with Pillow, not a render of the real app.
"""
import re, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
CORE = ROOT / "iPlayr/iPlayr/Core/Theme/ThemeCore"

# ---------- parse the Swift constants ----------
table_src = (CORE / "ThemeTable.swift").read_text()
mode_src = (CORE / "ModeTokens.swift").read_text()

override_re = re.compile(
    r'static let (\w+) = SurfaceOverride\(\s*screenBackground: \.hex\("(\w+)"\), panelBackground: \.hex\("(\w+)"\), '
    r'raisedPanel: \.hex\("(\w+)"\),\s*divider: \.hex\("(\w+)"\), progressTrack: \.hex\("(\w+)"\)\)', re.S)
overrides = {m[1]: dict(screen=m[2], panel=m[3], raised=m[4], divider=m[5], track=m[6]) for m in override_re.finditer(table_src)}

theme_re = re.compile(
    r'theme\("(\w+)", "([^"]+)", \.(\w+), body: "(\w+)", wheel: "(\w+)", glyph: "(\w+)", accent: "(\w+)",\s*'
    r'dark: \("(\w+)", "(\w+)", "(\w+)"\), light: \("(\w+)", "(\w+)", "(\w+)"\),\s*'
    r'style: \.(\w+), finish: \.(\w+), atmosphere: \.(\w+), compact: (true|false)'
    r'(?:, edge: "(\w+)")?(?:,\s*darkSurfaces: (\w+), lightSurfaces: (\w+))?', re.S)
themes = []
for m in theme_re.finditer(table_src):
    g = m.groups()
    themes.append(dict(id=g[0], name=g[1], group=g[2], body=g[3], wheel=g[4], glyph=g[5], accent=g[6],
                       dark=dict(sel=g[7], seltext=g[8], fill=g[9]), light=dict(sel=g[10], seltext=g[11], fill=g[12]),
                       style=g[13], finish=g[14], atmosphere=g[15], compact=g[16] == "true", edge=g[17],
                       darkSurfaces=overrides.get(g[18]) if g[18] else None,
                       lightSurfaces=overrides.get(g[19]) if g[19] else None))
assert len(themes) == 20, f"parsed {len(themes)} themes, expected 20"

mode_re = re.compile(
    r'static let (dark|light) = SurfaceTokens\(\s*screenBackground: \.hex\("(\w+)"\), panelBackground: \.hex\("(\w+)"\), '
    r'raisedPanel: \.hex\("(\w+)"\),\s*divider: \.hex\("(\w+)"\), primaryText: \.hex\("(\w+)"\), secondaryText: \.hex\("(\w+)"\),\s*'
    r'mutedText: \.hex\("(\w+)"\), progressTrack: \.hex\("(\w+)"\)', re.S)
modes = {m[1]: dict(screen=m[2], panel=m[3], raised=m[4], divider=m[5], primary=m[6], secondary=m[7], muted=m[8], track=m[9])
         for m in mode_re.finditer(mode_src)}
assert set(modes) == {"dark", "light"}, modes.keys()

# ---------- colour helpers mirroring ColorMath.swift ----------
def rgb(h):
    h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4))
def hsl(c):
    r, g, b = [x / 255 for x in c]; mx, mn = max(r, g, b), min(r, g, b); l = (mx + mn) / 2
    if mx == mn: return 0, 0, l
    d = mx - mn; s = d / (2 - mx - mn) if l > 0.5 else d / (mx + mn)
    if mx == r: h = (g - b) / d; h = h + 6 if h < 0 else h
    elif mx == g: h = (b - r) / d + 2
    else: h = (r - g) / d + 4
    return h * 60, s, l
def from_hsl(h, s, l):
    c = (1 - abs(2 * l - 1)) * s; hh = h % 360; x = c * (1 - abs((hh / 60) % 2 - 1)); m = l - c / 2
    r, g, b = [(c, x, 0), (x, c, 0), (0, c, x), (0, x, c), (x, 0, c), (c, 0, x)][int(hh // 60) % 6]
    return tuple(max(0, min(255, round((v + m) * 255))) for v in (r, g, b))
def adjust(c, d):
    h, s, l = hsl(c); return from_hsl(h, s, max(0, min(1, l + d)))
def is_light(c): return hsl(c)[2] >= 0.5
def lerp(a, b, t): return tuple(round(a[i] + (b[i] - a[i]) * t) for i in range(3))

# ---------- drawing ----------
def font(size, bold=False):
    for path in ["/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf" if bold else "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"]:
        if Path(path).exists(): return ImageFont.truetype(path, size)
    return ImageFont.load_default()

CELL_W, CELL_H, GAP, MARGIN = 360, 540, 24, 40
COLS, ROWS = 5, 4

def draw_cell(page, x0, y0, t, mode):
    surf = dict(modes[mode]); over = t["darkSurfaces"] if mode == "dark" else t["lightSurfaces"]
    if over: surf.update(over)
    acc = t[mode]
    body = rgb(t["body"]); wheel = rgb(t["wheel"]); glyph = rgb(t["glyph"])
    light_body = is_light(body)
    d = 0.02 if t["finish"] == "matte" else 0.06
    top, bot = adjust(body, d), adjust(body, -d)

    # body with vertical gradient and 40px corners (approximate by lines + mask)
    bw, bh = CELL_W, 470
    bodyimg = Image.new("RGBA", (bw, bh), (0, 0, 0, 0))
    bd = ImageDraw.Draw(bodyimg)
    for yy in range(bh):
        bd.line([(0, yy), (bw, yy)], fill=lerp(top, bot, yy / (bh - 1)) + (255,))
    if t["finish"] == "gloss":
        for yy in range(bh // 2):
            a = int(255 * (0.22 * (1 - yy / (bh // 2))))
            bd.line([(0, yy), (bw, yy)], fill=(255, 255, 255, a))
    mask = Image.new("L", (bw, bh), 0); ImageDraw.Draw(mask).rounded_rectangle([0, 0, bw - 1, bh - 1], radius=40, fill=255)
    page.paste(bodyimg, (x0, y0), mask)
    pd = ImageDraw.Draw(page, "RGBA")
    # edge or rim
    if t["edge"]: edge = rgb(t["edge"]) + (255,)
    elif light_body: edge = adjust(body, -0.18) + (255,)
    else: edge = (255, 255, 255, int(255 * 0.18))
    pd.rounded_rectangle([x0, y0, x0 + bw - 1, y0 + bh - 1], radius=40, outline=edge, width=1)

    # screen: bezel 6px, panel 300x150 scaled to cell
    sx, sy, sw, sh = x0 + 30, y0 + 26, bw - 60, 150
    bezel = rgb("1A1D22") if light_body else rgb("0B0D10")
    pd.rounded_rectangle([sx - 6, sy - 6, sx + sw + 6, sy + sh + 6], radius=10, fill=bezel + (255,))
    pd.rectangle([sx, sy, sx + sw, sy + sh], fill=rgb(surf["screen"]) + (255,))
    # status bar
    pd.rectangle([sx, sy, sx + sw, sy + 22], fill=rgb(surf["panel"]) + (255,))
    pd.line([(sx, sy + 22), (sx + sw, sy + 22)], fill=rgb(surf["divider"]) + (255,), width=1)
    pd.text((sx + 8, sy + 4), "Music", fill=rgb(surf["primary"]) + (255,), font=font(12, True))
    # battery (primaryText ink)
    ink = rgb(surf["primary"]) + (255,)
    pd.rounded_rectangle([sx + sw - 30, sy + 6, sx + sw - 8, sy + 16], radius=2, outline=ink, width=1)
    pd.rectangle([sx + sw - 28, sy + 8, sx + sw - 14, sy + 14], fill=ink)
    # selected row
    ry = sy + 26
    pd.rectangle([sx, ry, sx + sw, ry + 24], fill=rgb(acc["sel"]) + (255,))
    pd.text((sx + 10, ry + 5), "Cover Flow", fill=rgb(acc["seltext"]) + (255,), font=font(13))
    pd.text((sx + sw - 18, ry + 4), "›", fill=rgb(acc["seltext"]) + (255,), font=font(14, True))
    # two text rows
    pd.text((sx + 10, ry + 31), "Playlists", fill=rgb(surf["primary"]) + (255,), font=font(13))
    pd.text((sx + 10, ry + 53), "Artists", fill=rgb(surf["secondary"]) + (255,), font=font(13))
    # progress bar
    py = sy + sh - 22
    pd.rounded_rectangle([sx + 40, py, sx + sw - 40, py + 6], radius=3, fill=rgb(surf["track"]) + (255,))
    pd.rounded_rectangle([sx + 40, py, sx + 40 + int((sw - 80) * 0.55), py + 6], radius=3, fill=rgb(acc["fill"]) + (255,))
    pd.text((sx + 8, py - 5), "1:24", fill=rgb(surf["secondary"]) + (255,), font=font(10))
    pd.text((sx + sw - 34, py - 5), "-2:10", fill=rgb(surf["secondary"]) + (255,), font=font(10))

    # wheel
    ratio = 0.76 if t["compact"] else 0.70
    dia = int(bw * ratio); cx, cy = x0 + bw // 2, sy + sh + 6 + 20 + dia // 2
    r = dia // 2
    hair = (0, 0, 0, int(255 * 0.14)) if light_body else (255, 255, 255, int(255 * 0.18))
    if t["style"] == "classic":
        pd.ellipse([cx - r, cy - r, cx + r, cy + r], fill=wheel + (255,))
        if t["finish"] == "gloss":
            pd.ellipse([cx - int(r * 0.7), cy - int(r * 0.72), cx - int(r * 0.1), cy - int(r * 0.12)], fill=(255, 255, 255, 20))
        pd.ellipse([cx - r + 1, cy - r + 1, cx + r - 1, cy + r - 1], outline=adjust(wheel, -0.10) + (255,), width=1)
    else:
        pd.ellipse([cx - r + 1, cy - r + 1, cx + r - 1, cy + r - 1], outline=wheel + (255,), width=2)
    pd.ellipse([cx - r, cy - r, cx + r, cy + r], outline=hair, width=1)
    # centre button = body colour in both styles
    cr = int(dia * 0.36 / 2)
    stroke = wheel + (int(255 * (0.40 if t["style"] == "classic" else 0.60)),)
    pd.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], fill=body + (255,))
    pd.ellipse([cx - cr + 1, cy - cr + 1, cx + cr - 1, cy + cr - 1], outline=stroke, width=1 if t["style"] == "classic" else 2)
    pd.ellipse([cx - cr, cy - cr, cx + cr, cy + cr], outline=hair, width=1)
    # labels at 68% radius
    lr = int(r * 0.68); gl = glyph + (255,)
    f = font(11, True)
    w = pd.textlength("MENU", font=f)
    pd.text((cx - w / 2, cy - lr - 7), "MENU", fill=gl, font=f)
    def tri(px, py, dirn, size=6):
        if dirn > 0: pd.polygon([(px - size, py - size), (px + size, py), (px - size, py + size)], fill=gl)
        else: pd.polygon([(px + size, py - size), (px - size, py), (px + size, py + size)], fill=gl)
    tri(cx + lr - 7, cy, 1); tri(cx + lr + 5, cy, 1)
    tri(cx - lr - 5, cy, -1); tri(cx - lr + 7, cy, -1)
    tri(cx - 6, cy + lr, 1); pd.rectangle([cx + 4, cy + lr - 6, cx + 6, cy + lr + 6], fill=gl); pd.rectangle([cx + 8, cy + lr - 6, cx + 10, cy + lr + 6], fill=gl)

    # caption
    cap = ImageDraw.Draw(page)
    cap.text((x0, y0 + bh + 8), t["name"], fill=(20, 20, 20), font=font(15, True))
    cap.text((x0, y0 + bh + 30), f'body #{t["body"]}  wheel #{t["wheel"]}  {"Classic" if t["style"] == "classic" else "Minimal + Icons"}  {t["finish"]}',
             fill=(90, 90, 90), font=font(12))

def render(mode):
    W = MARGIN * 2 + COLS * CELL_W + (COLS - 1) * GAP
    H = MARGIN * 2 + 50 + ROWS * CELL_H + (ROWS - 1) * GAP
    # RGB page: Pillow only alpha-blends "RGBA" draws onto RGB images.
    page = Image.new("RGB", (W, H), (236, 237, 239))
    hd = ImageDraw.Draw(page)
    hd.text((MARGIN, MARGIN), f"iPlayr themes - {mode.title()} mode  (20 themes, gallery order; selected row and progress use that mode's constants)",
            fill=(20, 20, 20), font=font(18, True))
    for i, t in enumerate(themes):
        col, row = i % COLS, i // COLS
        x0 = MARGIN + col * (CELL_W + GAP); y0 = MARGIN + 50 + row * (CELL_H + GAP)
        draw_cell(page, x0, y0, t, mode)
    out = ROOT / "design" / f"contact-{mode}.png"
    page.save(out, optimize=True)
    return out

if __name__ == "__main__":
    for mode in ("dark", "light"):
        print("wrote", render(mode))
