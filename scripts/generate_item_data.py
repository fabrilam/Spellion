#!/usr/bin/env python3
"""Auto-generate _item_data.json from filenames with default names & descriptions."""

import os, json, re

ITEMS_DIR = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "assets", "textures", "items"))
DB_FILE = os.path.join(ITEMS_DIR, "_item_data.json")

# Map filename prefix -> (category, display_name_template, description_template)
CLASS_MAP = {
    "sword":    ("Sword",    "Sword",     "A sharp blade for close combat."),
    "axe":      ("Axe",      "Axe",       "A heavy axe for powerful strikes."),
    "dagger":   ("Dagger",   "Dagger",    "A quick and nimble blade."),
    "bow":      ("Bow",      "Bow",       "A ranged weapon for distant foes."),
    "staff":    ("Staff",    "Staff",     "A magical conduit for spells."),
    "club":     ("Mace",     "Club",      "A blunt instrument of crushing force."),
    "shield":   ("Shield",   "Shield",    "Protects against incoming attacks."),
    "armor":    ("Armor",    "Armor",     "Body armor for defense."),
    "headgear": ("Helmet",   "Headgear",  "Protective headwear."),
    "ring":     ("Ring",     "Ring",      "A ring imbued with magical power."),
    "amulet":   ("Amulet",   "Amulet",    "An amulet radiating mystical energy."),
    "lifepotionbig":  ("Potion",  "Greater Life Potion", "Restores a large amount of health."),
    "lifepotion":     ("Potion",  "Life Potion",         "Restores health."),
    "manapotionbig":  ("Potion",  "Greater Mana Potion", "Restores a large amount of mana."),
    "manapotion":     ("Potion",  "Mana Potion",         "Restores mana."),
    "spellbook":("Misc",    "Spellbook", "A tome of forgotten knowledge."),
    "questitem":("Quest",   "Quest Item","An important item for the journey ahead."),
    "icon":     ("Misc",    "Unknown",   "An unidentified item."),
}

QUALITIES = ["Rusty", "Old", "Worn", "Fine", "Sturdy", "Keen", "Superior", "Flawless", "Arcane"]
WEAPON_TYPES = {"Sword": "Sword", "Axe": "Axe", "Dagger": "Dagger", "Bow": "Bow", "Staff": "Staff", "Mace": "Club"}
ARMOR_TYPES = {"Armor": "Armor", "Helmet": "Helm", "Shield": "Shield"}

def detect_item(file):
    name_lower = file.lower().replace(".png", "")

    # Find matching prefix
    for prefix, (cat, display, desc) in sorted(CLASS_MAP.items(), key=lambda x: -len(x[0])):
        if name_lower.startswith(prefix):
            # Extract number if present
            num_match = re.search(r'\((\d+)\)', name_lower)
            num = int(num_match.group(1)) if num_match else 0

            if prefix == "icon":
                display = "Unknown Item"
                desc = "An unidentified item."
            else:
                # Generate name with quality based on number
                quality_idx = (num - 1) % len(QUALITIES) if num > 0 else 0
                quality = QUALITIES[quality_idx]
                display = f"{quality} {display}" if num > 0 else display

                # Generate tier-based description
                if cat in ("Sword", "Axe", "Dagger", "Bow", "Staff", "Mace"):
                    tier = (num - 1) // len(QUALITIES) + 1 if num > 0 else 1
                    dmg = 5 + tier * 3
                    desc = f"Deals {dmg} base damage. A {quality.lower()} {display.lower()}."
                elif cat in ("Armor", "Helmet", "Shield"):
                    tier = (num - 1) // len(QUALITIES) + 1 if num > 0 else 1
                    arm = 3 + tier * 2
                    desc = f"Provides {arm} defense. {quality} protection."
                elif cat == "Ring":
                    stats = ["strength", "agility", "intelligence", "vitality"]
                    desc = f"Grants +{num} to {stats[(num-1) % len(stats)]}."
                elif cat == "Amulet":
                    desc = f"Enhances magical affinity. +{num} spell power."
                elif cat == "Potion":
                    desc = desc
                elif cat == "Quest":
                    desc = f"A key item. Chapter {num}."

            return {
                "file": file,
                "name": display,
                "category": cat,
                "desc": desc,
            }

    return {
        "file": file,
        "name": "Unknown",
        "category": "Uncategorized",
        "desc": "An unknown item.",
    }

def main():
    pngs = sorted(f for f in os.listdir(ITEMS_DIR) if f.lower().endswith(".png") and not f.startswith("_"))
    items = [detect_item(f) for f in pngs]

    with open(DB_FILE, "w", encoding="utf-8") as fp:
        json.dump(items, fp, indent=2, ensure_ascii=False)

    cats = {}
    for it in items:
        cats.setdefault(it["category"], 0)
        cats[it["category"]] += 1

    print(f"Generated data for {len(items)} items → {DB_FILE}")
    for c, n in sorted(cats.items()):
        print(f"  {c}: {n}")

if __name__ == "__main__":
    main()
