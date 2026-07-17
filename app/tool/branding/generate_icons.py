"""Step 6.1 (§16.2) — genera tutti gli asset icona dal vettoriale emblem.svg.

Pipeline: rasterizza `assets/images/emblem.svg` a 1024px (trasparente) con
Microsoft Edge headless, poi compone con Pillow:

  web/favicon.png                    64px, fondo bianco
  web/icons/Icon-{192,512}.png       emblema ~88%, fondo bianco
  web/icons/Icon-maskable-*.png      emblema ~62% (safe-zone maskable), fondo bianco
  assets/branding/icon_master.png    1024px fondo bianco  -> flutter_launcher_icons
  assets/branding/icon_adaptive_fg.png 1024px trasparente -> adaptive icon Android
  assets/branding/splash_emblem.png  640px trasparente    -> flutter_native_splash
  assets/branding/splash_android12.png 1152px, contenuto nel cerchio da 768px (Android 12+)

Uso:  python tool/branding/generate_icons.py   (da app/; richiede Edge + Pillow)
Poi:  dart run flutter_launcher_icons && dart run flutter_native_splash:create
"""
from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

APP = Path(__file__).resolve().parents[2]
SVG = APP / "assets" / "images" / "emblem.svg"
BRANDING = APP / "assets" / "branding"
WEB = APP / "web"

EDGE_CANDIDATES = [
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
]


def render_svg_1024() -> Image.Image:
    edge = next((p for p in EDGE_CANDIDATES if Path(p).exists()), None)
    if edge is None:
        sys.exit("Edge non trovato: serve per rasterizzare l'SVG.")
    with tempfile.TemporaryDirectory() as td:
        tmp = Path(td)
        (tmp / "emblem.svg").write_bytes(SVG.read_bytes())
        (tmp / "icon.html").write_text(
            "<!DOCTYPE html><html><head><style>html,body{margin:0;padding:0;"
            "background:transparent}img{display:block;width:1024px;height:1024px}"
            "</style></head><body><img src='emblem.svg'></body></html>"
        )
        out = tmp / "emblem_1024.png"
        subprocess.run(
            [
                edge, "--headless", "--disable-gpu",
                "--default-background-color=00000000",
                "--window-size=1024,1024",
                f"--screenshot={out}",
                (tmp / "icon.html").as_uri(),
            ],
            check=True, capture_output=True, timeout=120,
        )
        return Image.open(out).convert("RGBA").copy()


def compose(emblem: Image.Image, canvas_px: int, emblem_ratio: float,
            background: tuple | None) -> Image.Image:
    """Emblema centrato a `emblem_ratio` del canvas; bg bianco o trasparente."""
    mode_bg = (255, 255, 255, 255) if background else (0, 0, 0, 0)
    canvas = Image.new("RGBA", (canvas_px, canvas_px), mode_bg)
    size = round(canvas_px * emblem_ratio)
    scaled = emblem.resize((size, size), Image.LANCZOS)
    offset = (canvas_px - size) // 2
    canvas.alpha_composite(scaled, (offset, offset))
    return canvas


def save(img: Image.Image, path: Path, opaque: bool = False) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    (img.convert("RGB") if opaque else img).save(path)
    print(f"  {path.relative_to(APP)}  {img.size[0]}px")


def main() -> None:
    print("render emblem.svg -> 1024px ...")
    emblem = render_svg_1024()

    white = (255, 255, 255, 255)
    print("compose:")
    # PWA / web (§16.2: 192/512 + maskable + favicon)
    save(compose(emblem, 192, 0.88, white), WEB / "icons" / "Icon-192.png", opaque=True)
    save(compose(emblem, 512, 0.88, white), WEB / "icons" / "Icon-512.png", opaque=True)
    save(compose(emblem, 192, 0.62, white), WEB / "icons" / "Icon-maskable-192.png", opaque=True)
    save(compose(emblem, 512, 0.62, white), WEB / "icons" / "Icon-maskable-512.png", opaque=True)
    save(compose(emblem, 64, 0.92, white), WEB / "favicon.png", opaque=True)

    # Sorgenti per flutter_launcher_icons / flutter_native_splash
    save(compose(emblem, 1024, 0.84, white), BRANDING / "icon_master.png", opaque=True)
    save(compose(emblem, 1024, 0.62, None), BRANDING / "icon_adaptive_fg.png")
    save(compose(emblem, 640, 1.0, None), BRANDING / "splash_emblem.png")
    # Android 12+: canvas 1152, contenuto entro il cerchio centrale da 768px.
    save(compose(emblem, 1152, 640 / 1152, None), BRANDING / "splash_android12.png")

    print("OK. Ora: dart run flutter_launcher_icons && "
          "dart run flutter_native_splash:create")


if __name__ == "__main__":
    main()
