import json
with open("assets/textures/items/_item_data.json") as f:
    data = json.load(f)
print(f"Total items: {len(data)}\n")
cats = {}
for item in data:
    cats.setdefault(item["category"], 0)
    cats[item["category"]] += 1
print("Categories:", json.dumps(cats, indent=2))
print("\n--- Rings ---")
for item in data:
    if item["category"] == "Ring":
        print(f'  {item["file"]:20s} | {item["name"]:25s} | {item["desc"][:60]}')
