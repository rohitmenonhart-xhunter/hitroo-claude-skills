#!/usr/bin/env python3
"""Report a PNG (mode, size, transparent share) and optionally downscale it for the web, keeping the original in src/.
    png_check.py <file.png> [--max-width N]"""
import os
import shutil
import sys

try:
    from PIL import Image
except ImportError:  # no Pillow: fall back to the file's header only
    Image = None


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__); sys.exit(2)
    path = sys.argv[1]
    max_w = int(sys.argv[sys.argv.index("--max-width") + 1]) if "--max-width" in sys.argv else None
    if Image is None:
        print(f"{path}: {os.path.getsize(path)/1e3:.0f} KB (install Pillow for mode/alpha checks)"); return
    im = Image.open(path)
    alpha = im.getchannel("A") if im.mode in ("RGBA", "LA") else None
    transparent = 0.0
    if alpha is not None:
        hist = alpha.histogram(); transparent = hist[0] / max(1, sum(hist))
    print(f"{path}: {im.mode} {im.width}x{im.height} {os.path.getsize(path)/1e3:.0f} KB transparent {100*transparent:.0f}%")
    if max_w and im.width > max_w:
        src_dir = os.path.join(os.path.dirname(path) or ".", "src"); os.makedirs(src_dir, exist_ok=True)
        keep = os.path.join(src_dir, os.path.basename(path))
        if not os.path.exists(keep): shutil.copy(path, keep)
        im = im.convert("RGBA") if alpha is not None else im
        im = im.resize((max_w, round(im.height * max_w / im.width)), Image.LANCZOS)
        im.save(path, optimize=True)
        print(f"  downscaled to {im.width}x{im.height} {os.path.getsize(path)/1e3:.0f} KB (original kept in {keep})")


if __name__ == "__main__":
    main()
