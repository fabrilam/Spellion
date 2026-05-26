from PIL import Image
import os

img = Image.open("assets/saved_references/items.png").convert("RGBA")
w, h = img.size
out_dir = "assets/textures/items"
os.makedirs(out_dir, exist_ok=True)

TEAL = (64, 96, 96, 255)
TOL = 40

def is_teal(px):
    return abs(px[0]-TEAL[0]) < TOL and abs(px[1]-TEAL[1]) < TOL and abs(px[2]-TEAL[2]) < TOL and px[3] > 200

def is_white(px):
    return px[0] > 240 and px[1] > 240 and px[2] > 240

# Build content projection: for each row, count teal + non-white pixels
row_content = [0] * h
for y in range(h):
    c = 0
    for x in range(w):
        px = img.getpixel((x, y))
        if not is_white(px):
            c += 1
    row_content[y] = c

# Find horizontal bands
bands = []
in_band = False
start = 0
for y in range(h):
    if row_content[y] > w * 0.05 and not in_band:
        start = y
        in_band = True
    elif row_content[y] <= w * 0.05 and in_band:
        if y - start > 15:
            bands.append((start, y))
        in_band = False
if in_band and h - start > 15:
    bands.append((start, h))

print(f"Found {len(bands)} horizontal bands")

idx = 0
for y1, y2 in bands:
    # Build column projection for this band
    col_content = [0] * w
    for x in range(w):
        c = 0
        for y in range(y1, y2):
            if not is_white(img.getpixel((x, y))):
                c += 1
        col_content[x] = c

    # Find vertical strips within this band
    cols = []
    in_col = False
    start_x = 0
    for x in range(w):
        if col_content[x] > (y2 - y1) * 0.05 and not in_col:
            start_x = x
            in_col = True
        elif col_content[x] <= (y2 - y1) * 0.05 and in_col:
            if x - start_x > 8:
                cols.append((start_x, x))
            in_col = False
    if in_col and w - start_x > 8:
        cols.append((start_x, w))

    print(f"  Band y={y1}-{y2} (h={y2-y1}): {len(cols)} items")

    for x1, x2 in cols:
        rw, rh = x2 - x1, y2 - y1

        margin = 2
        cx1 = max(0, x1 - margin)
        cy1 = max(0, y1 - margin)
        cx2 = min(w, x2 + margin)
        cy2 = min(h, y2 + margin)

        icon = img.crop((cx1, cy1, cx2, cy2))

        # Make teal background transparent, keep non-teal content
        pix = icon.load()
        for iy in range(icon.height):
            for ix in range(icon.width):
                px = icon.getpixel((ix, iy))
                if is_teal(px):
                    icon.putpixel((ix, iy), (0, 0, 0, 0))

        fname = f"icon_{idx:03d}_{rw}x{rh}.png"
        icon.save(os.path.join(out_dir, fname))
        print(f"    {fname} at ({x1},{y1})")
        idx += 1

print(f"\nTotal: {idx} icons saved to {out_dir}/")
