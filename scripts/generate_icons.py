"""Regenerate platform launcher icons from assets/images/image.png."""

import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, "assets", "images", "image.png")


def load_master(size: int = 1024) -> Image.Image:
    img = Image.open(SRC).convert("RGBA")
    # Crop the logo region (no text), centered.
    cx, cy, half = 314, 474, 280
    crop = img.crop((cx - half, cy - half, cx + half, cy + half))
    return crop.resize((size, size), Image.LANCZOS)


def with_background(img: Image.Image, color=(255, 255, 255, 255)) -> Image.Image:
    bg = Image.new("RGBA", img.size, color)
    bg.alpha_composite(img)
    return bg


def save_resized(master: Image.Image, path: str, size: int, flatten=True) -> None:
    out = master.resize((size, size), Image.LANCZOS)
    if flatten:
        out = with_background(out).convert("RGB")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    out.save(path)


def main() -> None:
    master = load_master(1024)

    # Android launcher icons
    android_sizes = {
        "mipmap-mdpi": 48,
        "mipmap-hdpi": 72,
        "mipmap-xhdpi": 96,
        "mipmap-xxhdpi": 144,
        "mipmap-xxxhdpi": 192,
    }
    android_root = os.path.join(ROOT, "android", "app", "src", "main", "res")
    for folder, sz in android_sizes.items():
        save_resized(master, os.path.join(android_root, folder, "ic_launcher.png"), sz)

    # iOS app icon set
    ios_sizes = {
        "Icon-App-20x20@1x.png": 20,
        "Icon-App-20x20@2x.png": 40,
        "Icon-App-20x20@3x.png": 60,
        "Icon-App-29x29@1x.png": 29,
        "Icon-App-29x29@2x.png": 58,
        "Icon-App-29x29@3x.png": 87,
        "Icon-App-40x40@1x.png": 40,
        "Icon-App-40x40@2x.png": 80,
        "Icon-App-40x40@3x.png": 120,
        "Icon-App-60x60@2x.png": 120,
        "Icon-App-60x60@3x.png": 180,
        "Icon-App-76x76@1x.png": 76,
        "Icon-App-76x76@2x.png": 152,
        "Icon-App-83.5x83.5@2x.png": 167,
        "Icon-App-1024x1024@1x.png": 1024,
    }
    ios_root = os.path.join(ROOT, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    for name, sz in ios_sizes.items():
        save_resized(master, os.path.join(ios_root, name), sz)

    # macOS app icon set
    macos_sizes = {
        "app_icon_16.png": 16,
        "app_icon_32.png": 32,
        "app_icon_64.png": 64,
        "app_icon_128.png": 128,
        "app_icon_256.png": 256,
        "app_icon_512.png": 512,
        "app_icon_1024.png": 1024,
    }
    macos_root = os.path.join(ROOT, "macos", "Runner", "Assets.xcassets", "AppIcon.appiconset")
    for name, sz in macos_sizes.items():
        save_resized(master, os.path.join(macos_root, name), sz)

    # Web icons (PWA)
    web_icons_root = os.path.join(ROOT, "web", "icons")
    save_resized(master, os.path.join(web_icons_root, "Icon-192.png"), 192)
    save_resized(master, os.path.join(web_icons_root, "Icon-512.png"), 512)
    # Maskable: pad logo to ~80% of frame so it survives circular masking.
    for sz, name in [(192, "Icon-maskable-192.png"), (512, "Icon-maskable-512.png")]:
        canvas = Image.new("RGBA", (sz, sz), (255, 255, 255, 255))
        inner = int(sz * 0.78)
        offset = (sz - inner) // 2
        small = master.resize((inner, inner), Image.LANCZOS)
        canvas.alpha_composite(small, (offset, offset))
        canvas.convert("RGB").save(os.path.join(web_icons_root, name))
    # Favicon
    save_resized(master, os.path.join(ROOT, "web", "favicon.png"), 32)

    # Windows .ico (multi-resolution)
    ico_path = os.path.join(ROOT, "windows", "runner", "resources", "app_icon.ico")
    ico_master = with_background(master).convert("RGB")
    ico_master.save(
        ico_path,
        format="ICO",
        sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)],
    )

    print("Icons generated.")


if __name__ == "__main__":
    main()
