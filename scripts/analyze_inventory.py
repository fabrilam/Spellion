from PIL import Image
img = Image.open("assets/saved_references/inventory.png").convert("RGBA")
w, h = img.size
print(f"Image size: {w}x{h}")

BORDER = (57, 49, 29, 255)
def is_border(px):
    return abs(px[0]-57)<15 and abs(px[1]-49)<15 and abs(px[2]-29)<15

def is_dark(px):
    return px[0] < 60 and px[1] < 60 and px[2] < 60

print("\n=== Transition points (BORDER <-> INSIDE) ===")
prev_inside = False
for y in range(h):
    dark = sum(1 for x in range(0, w, 2) if is_dark(img.getpixel((x, y))))
    border = sum(1 for x in range(0, w, 2) if is_border(img.getpixel((x, y))))
    inside = dark > 15
    if inside != prev_inside:
        print(f"  y={y}: {'INSIDE' if inside else 'BORDER'} (dark={dark}, border={border})")
        prev_inside = inside

print("\n=== Horizontal slot bands ===")
prev_slot = False
sy = 0
for y in range(h):
    dark = sum(1 for x in range(0, w, 2) if is_dark(img.getpixel((x, y))))
    is_slot = dark > 15
    if is_slot and not prev_slot:
        sy = y
        prev_slot = True
    elif not is_slot and prev_slot:
        if y - sy > 10:
            print(f"  Band: y={sy}-{y} (h={y-sy})")
        prev_slot = False
if prev_slot and h - sy > 10:
    print(f"  Band: y={sy}-{h} (h={h-sy})")
