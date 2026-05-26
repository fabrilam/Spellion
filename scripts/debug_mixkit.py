import urllib.request, re

url = "https://mixkit.co/free-sound-effects/punch/"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
resp = urllib.request.urlopen(req, timeout=15)
html = resp.read().decode("utf-8", errors="replace")

# Search for 'item-grid-card'
lines = html.split("\n")
imports = [i for i, line in enumerate(lines) if "item-grid-card" in line]
print(f'Lines with "item-grid-card": {len(imports)}')

if imports:
    for line_no in imports[:3]:
        start = max(0, line_no - 1)
        end = min(len(lines), line_no + 10)
        for i in range(start, end):
            print(f"  L{i}: {lines[i][:200]}")
        print("  ---")

# Also search for data-algolia-analytics-item-id
id_lines = [i for i, line in enumerate(lines) if "data-algolia-analytics-item-id" in line]
print(f'\nLines with "data-algolia-analytics-item-id": {len(id_lines)}')
if id_lines:
    for line_no in id_lines[:5]:
        print(f"  L{line_no}: {lines[line_no][:200]}")

# Search for the card structure differently
cards = html.split('class="item-grid-card')
print(f'\nSplit by "item-grid-card": {len(cards)-1} cards found')

# Check first card
if len(cards) > 1:
    card = cards[1]
    print(f"\nFirst card preview (500 chars):")
    print(card[:500])
