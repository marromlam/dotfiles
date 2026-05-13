curl -fsSL https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json |
python3 -c '
import sys, json

data = json.load(sys.stdin)

for name, info in data.items():
    if name == "METADATA":
        continue
    glyph = info.get("char")
    if glyph:
        print(f"{glyph}  U+{ord(glyph):04X}  {name}")
' > nerdfont-icons.txt
cat nerdfont-icons.txt
