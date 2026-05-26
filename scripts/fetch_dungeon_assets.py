#!/usr/bin/env python3
"""
Fetch dungeon assets for Spellion.
Downloads CC0 sounds from Mixkit and prints instructions for textures.

Usage:
  python scripts/fetch_dungeon_assets.py          # download all
  python scripts/fetch_dungeon_assets.py --list   # just list sounds
"""

import urllib.request, re, html, sys, os, json

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
AUDIO_DIR = os.path.join(BASE_DIR, "assets", "audio", "_unused")
TEXTURES_DIR = os.path.join(BASE_DIR, "assets", "textures", "dungeon")
SOUND_GROUPS_PATH = os.path.join(BASE_DIR, "autoload", "audio_manager.gd")

os.makedirs(AUDIO_DIR, exist_ok=True)
os.makedirs(TEXTURES_DIR, exist_ok=True)

DUNGEON_SOUNDS = {
    "coin": {
        "tag": "coin",
        "folder": "item_drop",
        "desc": "Metal bling for ring/amulet drops"
    },
    "metal": {
        "tag": "metal",
        "folder": "item_drop",
        "desc": "Metal clang for armor/weapon drops"
    },
    "chest": {
        "tag": "chest",
        "folder": "interact",
        "desc": "Chest open/close"
    },
    "door": {
        "tag": "door",
        "folder": "interact",
        "desc": "Dungeon door sounds"
    },
    "dungeon_ambient": {
        "tag": "dungeon-ambient",
        "folder": "ambient",
        "desc": "Dark dungeon atmosphere"
    },
    "stone": {
        "tag": "stone",
        "folder": "impact",
        "desc": "Stone impact for walls/destructibles"
    },
    "wood_break": {
        "tag": "wood-break",
        "folder": "destructible",
        "desc": "Barrel/crate breaking"
    },
}

TEXTURE_SOURCES = {
    "wall_stone_brick": {
        "url": "https://opengameart.org/content/simple-stone-wall-texture",
        "filename": "wall_stone_brick.png",
        "desc": "Stone brick wall for dungeon rooms",
        "fallback": "procedural"
    },
    "floor_stone_tile": {
        "url": "https://opengameart.org/content/stone-floor-tileable",
        "filename": "floor_stone_tile.png",
        "desc": "Tiled stone floor for dungeon",
        "fallback": "procedural"
    },
    "wood_planks": {
        "url": "https://opengameart.org/content/wooden-planks-texture",
        "filename": "wood_planks.png",
        "desc": "Wood texture for barrels, crates, doors",
        "fallback": "procedural"
    },
    "marble_altar": {
        "url": "https://opengameart.org/content/marble-texture-0",
        "filename": "marble_altar.png",
        "desc": "Marble stone for altars and special floors",
        "fallback": "procedural"
    },
}


def fetch_sounds(tag, folder):
    """Fetch Mixkit sounds by tag and save to folder."""
    url = f"https://mixkit.co/free-sound-effects/{tag}/"
    print(f"  Fetching {url}...")
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    try:
        resp = urllib.request.urlopen(req, timeout=15)
    except Exception as e:
        print(f"  ERROR: {e}")
        return []
    html_content = resp.read().decode("utf-8", errors="replace")

    results = []
    idx = 0
    while True:
        card_start = html_content.find('class="item-grid-card', idx)
        if card_start < 0: break
        div_end = html_content.find('>', card_start)
        if div_end < 0: break
        id_match = re.search(r'data-audio-player-item-id-value="(\d+)"', html_content[card_start:card_start+500])
        if not id_match:
            idx = div_end + 1
            continue
        sid = id_match.group(1)
        meta_start = html_content.find('item-grid-card__meta', div_end)
        if meta_start < 0:
            idx = div_end + 1
            continue
        meta_end = html_content.find('item-grid-sfx-preview__actions', meta_start)
        if meta_end < 0: meta_end = meta_start + 1000
        meta_section = html_content[meta_start:meta_end + 500]
        title_match = re.search(r'item-grid-card__title">(.*?)</h2>', meta_section, re.DOTALL)
        title = html.unescape(re.sub(r'<[^>]+>', '', title_match.group(1))).strip() if title_match else "?"
        results.append((sid, title))
        idx = meta_end + 1

    out_dir = os.path.join(AUDIO_DIR, folder)
    os.makedirs(out_dir, exist_ok=True)

    downloaded = []
    for sid, title in results:
        safe_title = re.sub(r'[^a-z0-9]+', '_', title.lower()).strip('_')
        fname = f"mixkit_{sid}_{safe_title}.mp3"
        out_path = os.path.join(out_dir, fname)
        if os.path.exists(out_path):
            downloaded.append((sid, title, fname, "exists"))
            continue
        dl_url = f"https://assets.mixkit.co/active_storage/sfx/{sid}/{sid}-preview.mp3"
        try:
            urllib.request.urlretrieve(dl_url, out_path)
            downloaded.append((sid, title, fname, "downloaded"))
        except:
            downloaded.append((sid, title, fname, "failed"))

    return downloaded


def main():
    do_list = "--list" in sys.argv

    print("=" * 60)
    print("SPELLION - Dungeon Asset Fetcher")
    print("=" * 60)
    print()

    # --- SOUNDS ---
    print("--- DUNGEON SOUNDS ---")
    all_sounds = {}
    for key, info in DUNGEON_SOUNDS.items():
        tag = info["tag"]
        folder = info["folder"]
        print(f"\n[{key}] {info['desc']} (tag: {tag})")
        if do_list:
            print(f"  (use --list only, skipping download)")
        else:
            results = fetch_sounds(tag, folder)
            for sid, title, fname, status in results:
                icon = {"downloaded": "[OK]", "exists": "[--]", "failed": "[FAIL]"}[status]
                print(f"  {icon} {fname}")
                if key not in all_sounds:
                    all_sounds[key] = []
                all_sounds[key].append(fname)

    # Generate audio_manager sound groups
    if not do_list and all_sounds:
        print("\n\nGenerated sound groups to add to audio_manager.gd:\n")
        print("  # Dungeon item drops")
        if "coin" in all_sounds:
            names = [s.replace(".mp3","") for s in all_sounds["coin"]]
            print(f'  "item_drop_ring": [{", ".join(f"preload(\"res://assets/audio/_unused/item_drop/{n}.mp3\")" for n in names)}],')
        if "metal" in all_sounds:
            names = [s.replace(".mp3","") for s in all_sounds["metal"]]
            print(f'  "item_drop_clang": [{", ".join(f"preload(\"res://assets/audio/_unused/item_drop/{n}.mp3\")" for n in names)}],')
        if "chest" in all_sounds:
            names = [s.replace(".mp3","") for s in all_sounds["chest"]]
            print(f'  "chest_open": preload("res://assets/audio/_unused/interact/{names[0]}.mp3"),')
        if "wood_break" in all_sounds:
            names = [s.replace(".mp3","") for s in all_sounds["wood_break"]]
            print(f'  "destructible_break": preload("res://assets/audio/_unused/destructible/{names[0]}.mp3"),')

    # --- TEXTURES ---
    print("\n\n--- DUNGEON TEXTURES (manual download suggested) ---")
    print("These textures need manual download from OpenGameArt:\n")
    for key, info in TEXTURE_SOURCES.items():
        print(f"  [{key}] {info['desc']}")
        print(f"         URL: {info['url']}")
        print(f"         Save as: assets/textures/dungeon/{info['filename']}")
        if info['fallback'] == 'procedural':
            print(f"         (fallback: procedural generation in GDScript)")
        print()

    print("After placing textures, import them in Godot.")
    print()

    # Generate README
    readme_path = os.path.join(TEXTURES_DIR, "README.md")
    with open(readme_path, "w") as f:
        f.write("# Dungeon Textures\n\nPlace downloaded CC0 textures here.\n\n")
        for key, info in TEXTURE_SOURCES.items():
            f.write(f"## {key}\n")
            f.write(f"{info['desc']}\n")
            f.write(f"Source: {info['url']}\n")
            f.write(f"Filename: {info['filename']}\n\n")

    print(f"Texture README written to {readme_path}")
    print("\nDone!")


if __name__ == "__main__":
    main()
