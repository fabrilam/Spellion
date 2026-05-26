#!/usr/bin/env python3
"""
Fetch and list Mixkit sound effects by tag.
Usage:
  python scripts/fetch_mixkit_sounds.py punch
  python scripts/fetch_mixkit_sounds.py punch --download 2198
"""

import urllib.request, re, html, sys, os

TAG = sys.argv[1] if len(sys.argv) > 1 else "punch"
DOWNLOAD_ID = None
if "--download" in sys.argv:
    idx = sys.argv.index("--download")
    DOWNLOAD_ID = sys.argv[idx + 1] if idx + 1 < len(sys.argv) else None

OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "_unused")
os.makedirs(OUT_DIR, exist_ok=True)

url = f"https://mixkit.co/free-sound-effects/{TAG}/"
print(f"Fetching {url}...")
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
resp = urllib.request.urlopen(req, timeout=15)
html_content = resp.read().decode("utf-8", errors="replace")

# Each card is wrapped in <div class="item-grid-card ...">
results = []
idx = 0
while True:
    # Find next card start
    card_start = html_content.find('class="item-grid-card', idx)
    if card_start < 0:
        break
    # Find the end of this card's <div> opening
    div_end = html_content.find('>', card_start)
    if div_end < 0:
        break
    
    # Extract ID from data-audio-player-item-id-value
    id_match = re.search(r'data-audio-player-item-id-value="(\d+)"', html_content[card_start:card_start+500])
    if not id_match:
        idx = div_end + 1
        continue
    sid = id_match.group(1)
    
    # Find the meta section within this card
    meta_start = html_content.find('item-grid-card__meta', div_end)
    if meta_start < 0:
        idx = div_end + 1
        continue
    meta_end = html_content.find('item-grid-sfx-preview__actions', meta_start)
    if meta_end < 0:
        meta_end = meta_start + 1000
    meta_section = html_content[meta_start:meta_end + 500]
    
    # Extract title
    title_match = re.search(r'item-grid-card__title">(.*?)</h2>', meta_section, re.DOTALL)
    title = html.unescape(re.sub(r'<[^>]+>', '', title_match.group(1))).strip() if title_match else "?"
    
    # Extract tags
    tags_match = re.search(r'meta-links__links">(.*?)</div>', meta_section, re.DOTALL)
    tags = re.findall(r'href="[^"]+">(.*?)</a>', tags_match.group(1)) if tags_match else []
    
    # Duration
    dur_match = re.search(r'(\d+):(\d+)', meta_section)
    duration = f"{dur_match.group(1)}:{dur_match.group(2)}" if dur_match else "?"
    
    results.append((sid, title, tags, duration))
    idx = meta_end + 1

print(f"\n=== {len(results)} sounds for '{TAG}' ===\n")
print(f"{'ID':<6} {'Dur':<6} {'Title':<55} {'Tags'}")
print("-" * 100)
results.sort(key=lambda r: int(r[0]))
for sid, title, tags, duration in results:
    tag_str = ", ".join(tags[:5])
    print(f"{sid:<6} {duration:<6} {title:<55} {tag_str}")

if DOWNLOAD_ID:
    for sid, title, tags, duration in results:
        if sid == DOWNLOAD_ID:
            safe_title = re.sub(r'[^a-z0-9]+', '_', title.lower()).strip('_')
            fname = f"mixkit_{sid}_{safe_title}.mp3"
            out_path = os.path.join(OUT_DIR, fname)
            dl_url = f"https://assets.mixkit.co/active_storage/sfx/{sid}/{sid}-preview.mp3"
            print(f"\nDownloading -> {fname}...")
            urllib.request.urlretrieve(dl_url, out_path)
            size = os.path.getsize(out_path)
            print(f"Done: {fname} ({size} bytes)")
            break
    else:
        print(f"\nID {DOWNLOAD_ID} not found")

print()
