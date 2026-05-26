from PIL import Image
from collections import Counter

img = Image.open("assets/saved_references/items.png").convert("RGBA")
w, h = img.size
print(f"Size: {w}x{h}")

# Find all non-white, non-black colors
colors = Counter()
for y in range(0, h, 2):
    for x in range(0, w, 2):
        r, g, b, a = img.getpixel((x, y))
        if r > 240 and g > 240 and b > 240:
            continue
        rq, gq, bq = r // 16 * 16, g // 16 * 16, b // 16 * 16
        colors[(rq, gq, bq, a)] += 1

print("\nTop 30 non-white colors:")
for color, count in colors.most_common(30):
    r, g, b, a = color
    hex_color = f"#{r:02x}{g:02x}{b:02x}"
    print(f"  RGBA({r},{g},{b},{a}) = {hex_color} x{count}")

# Find horizontal dividers (rows with many non-white pixels)
print("\nHorizontal dividers:")
for y in range(0, h):
    non_white = 0
    for x in range(0, w, 3):
        px = img.getpixel((x, y))
        if px[0] < 230 or px[1] < 230 or px[2] < 230:
            non_white += 1
    ratio = non_white / (w / 3)
    if ratio > 0.4:
        # Find dominant color in this row
        row_colors = Counter()
        for x in range(0, w, 3):
            px = img.getpixel((x, y))
            if px[0] < 230 or px[1] < 230 or px[2] < 230:
                rq, gq, bq = px[0] // 32 * 32, px[1] // 32 * 32, px[2] // 32 * 32
                row_colors[(rq, gq, bq)] += 1
        if row_colors:
            dc = row_colors.most_common(1)[0][0]
            print(f"  y={y:4d}: {ratio*100:.0f}% non-white, color RGB({dc[0]},{dc[1]},{dc[2]})")

# Find vertical dividers
print("\nVertical dividers:")
for x in range(0, w):
    non_white = 0
    for y in range(0, h, 3):
        px = img.getpixel((x, y))
        if px[0] < 230 or px[1] < 230 or px[2] < 230:
            non_white += 1
    ratio = non_white / (h / 3)
    if ratio > 0.4:
        col_colors = Counter()
        for y in range(0, h, 3):
            px = img.getpixel((x, y))
            if px[0] < 230 or px[1] < 230 or px[2] < 230:
                rq, gq, bq = px[0] // 32 * 32, px[1] // 32 * 32, px[2] // 32 * 32
                col_colors[(rq, gq, bq)] += 1
        if col_colors:
            dc = col_colors.most_common(1)[0][0]
            print(f"  x={x:4d}: {ratio*100:.0f}% non-white, color RGB({dc[0]},{dc[1]},{dc[2]})")
