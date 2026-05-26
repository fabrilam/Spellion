"""
Download weapons from multiple sources.
Uses itch.io API + alternative sources.
"""
import urllib.request, re, os, json

ASSETS = os.path.join(os.path.dirname(__file__), "..", "assets")
OUT_QUAT = os.path.join(ASSETS, "models", "weapons", "_source_quaternius")
os.makedirs(OUT_QUAT, exist_ok=True)

# Try the itch.io API to get game data and download URLs
print("Trying itch.io API...")
try:
    api_url = "https://itch.io/api/1/game/2122055"
    req = urllib.request.Request(api_url, headers={"User-Agent": "Mozilla/5.0"})
    resp = urllib.request.urlopen(req, timeout=15)
    data = json.loads(resp.read())
    game = data.get("game", {})
    print(f"Game: {game.get('title', '?')}")
    uploads = game.get("uploads", [])
    for up in uploads:
        print(f"  Upload: {up.get('filename', '?')} - {up.get('size', '?')}")
except Exception as e:
    print(f"  API error: {e}")

# Try the itch.io file download endpoint directly
# For free assets, the URL pattern is:
# https://quaternius.itch.io/lowpoly-medieval-weapons/download/<upload_id>
print("\nTrying file download endpoints...")
for upload_id in ["2122055", "2122056", "2122057"]:
    dl_url = f"https://quaternius.itch.io/lowpoly-medieval-weapons/download/{upload_id}"
    try:
        dreq = urllib.request.Request(dl_url, headers={"User-Agent": "Mozilla/5.0"})
        dresp = urllib.request.urlopen(dreq, timeout=15)
        # If we get HTML back, it's the download page, not the file
        content = dresp.read()
        if len(content) > 1000 and content[:10] != b"PK":
            print(f"  {upload_id}: Got HTML page (need session)")
        else:
            fname = f"weapons_{upload_id}.zip"
            with open(os.path.join(OUT_QUAT, fname), "wb") as f:
                f.write(content)
            print(f"  {upload_id}: Downloaded {fname} ({len(content)} bytes)")
    except Exception as e:
        print(f"  {upload_id}: {e}")

# Alternative: Use the direct CDN URL from known upload IDs
# Quaternius's assets are often at:
# https://img.itch.zone/aW1hZ2Uv.../original/filename.zip
# We need the actual upload hash from the page data

print("\nSearching for upload hashes...")
try:
    url = "https://quaternius.itch.io/lowpoly-medieval-weapons"
    req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
    resp = urllib.request.urlopen(req, timeout=15)
    html = resp.read().decode("utf-8", errors="replace")
    
    # Look for img.itch.zone URLs with zip
    for m in re.finditer(r'(https?://img\.itch\.zone[^"\'<>]+\.zip)', html):
        u = m.group(1)
        fname = u.split("/")[-1].split("?")[0]
        if not fname.endswith(".zip"):
            fname = "weapons_from_cdn.zip"
        print(f"Found CDN URL: {u[:80]}...")
        try:
            dreq = urllib.request.Request(u, headers={"User-Agent": "Mozilla/5.0"})
            dresp = urllib.request.urlopen(dreq, timeout=30)
            content = dresp.read()
            with open(os.path.join(OUT_QUAT, fname), "wb") as f:
                f.write(content)
            print(f"  Downloaded: {fname} ({len(content)} bytes)")
        except Exception as e:
            print(f"  Download failed: {e}")
except Exception as e:
    print(f"  Page fetch error: {e}")

print("\nDone.")

