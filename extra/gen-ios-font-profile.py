#!/usr/bin/env python3
"""
Generate a .mobileconfig profile to install JetBrainsMono Nerd Font on iOS.
Run on macOS, then AirDrop the output file to your iPhone/iPad.
"""

import base64
import plistlib
import uuid
from pathlib import Path

FONTS_DIR = Path.home() / "Library" / "Fonts"
OUTPUT = Path.home() / "Desktop" / "JetBrainsMonoNerdFont.mobileconfig"

VARIANTS = [
    "JetBrainsMonoNerdFontMono-Regular.ttf",
    "JetBrainsMonoNerdFontMono-Bold.ttf",
    "JetBrainsMonoNerdFontMono-Italic.ttf",
    "JetBrainsMonoNerdFontMono-BoldItalic.ttf",
]


def font_payload(ttf_path: Path) -> dict:
    data = ttf_path.read_bytes()
    return {
        "Font": data,
        "PayloadDescription": f"Adds {ttf_path.stem}",
        "PayloadDisplayName": ttf_path.stem,
        "PayloadIdentifier": f"com.dotfiles.font.{ttf_path.stem.lower()}",
        "PayloadType": "com.apple.font",
        "PayloadUUID": str(uuid.uuid4()),
        "PayloadVersion": 1,
    }


def main():
    payloads = []
    for name in VARIANTS:
        path = FONTS_DIR / name
        if not path.exists():
            print(f"  missing: {path}")
            continue
        payloads.append(font_payload(path))
        print(f"  added: {name}")

    if not payloads:
        raise SystemExit("No font files found — run from the Mac that has the fonts installed.")

    profile = {
        "PayloadContent": payloads,
        "PayloadDescription": "Installs JetBrainsMono Nerd Font Mono for use in iSH and other apps.",
        "PayloadDisplayName": "JetBrainsMono Nerd Font",
        "PayloadIdentifier": "com.dotfiles.fonts.jetbrainsmono",
        "PayloadRemovalDisallowed": False,
        "PayloadType": "Configuration",
        "PayloadUUID": str(uuid.uuid4()),
        "PayloadVersion": 1,
    }

    with open(OUTPUT, "wb") as f:
        plistlib.dump(profile, f, fmt=plistlib.FMT_XML)

    print(f"\nProfile written to: {OUTPUT}")
    print("Next steps:")
    print("  1. AirDrop the file to your iPhone/iPad")
    print("  2. Tap it → Settings → Profile Downloaded → Install")
    print("  3. In iSH: Settings → iSH → Font → select JetBrainsMono")


if __name__ == "__main__":
    main()
