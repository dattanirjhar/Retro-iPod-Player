#!/usr/bin/env python3
"""Assemble 20 simulator screenshots into a 5 x 4 grid.

Usage: make_grid.py <shots_dir> <dark|light> <output.png>
Expects files named NN-themeId-<mode>.png with NN = 01..20 in gallery order.
"""
import re, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

shots_dir, mode, out = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
files = sorted(p for p in shots_dir.iterdir() if re.match(rf"\d\d-.+-{mode}\.png$", p.name))
if len(files) != 20:
    sys.exit(f"expected 20 files named NN-themeId-{mode}.png, found {len(files)}")

cols, rows, gap, caption = 5, 4, 24, 36
first = Image.open(files[0])
w, h = first.size
scale = 390 / w
cw, ch = 390, round(h * scale)
page = Image.new("RGB", (gap + cols * (cw + gap), gap + rows * (ch + caption + gap)), (236, 237, 239))
draw = ImageDraw.Draw(page)
try:
    font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
except OSError:
    font = ImageFont.load_default()
for i, path in enumerate(files):
    img = Image.open(path).convert("RGB").resize((cw, ch))
    x = gap + (i % cols) * (cw + gap)
    y = gap + (i // cols) * (ch + caption + gap)
    page.paste(img, (x, y))
    draw.text((x, y + ch + 8), path.stem, fill=(20, 20, 20), font=font)
page.save(out, optimize=True)
print("wrote", out)
