"""Read/write Google Spreadsheets.
Usage:
  python tools/sheets.py list                     # list configured sheets
  python tools/sheets.py discover                 # discover all accessible sheets
  python tools/sheets.py <name>                   # show worksheets
  python tools/sheets.py <name> <range>          # read range (e.g. A1:E20)
  python tools/sheets.py <name> set <cell> <val>  # write single cell
  python tools/sheets.py <name> append <range> <val1>,<val2>,...
"""
import json, os, sys

SCOPE_SHEETS = "https://www.googleapis.com/auth/spreadsheets"
KEY_GLOB = "gen-lang-client-*.json"

def _find_key():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    matches = __import__("glob").glob(os.path.join(root, KEY_GLOB))
    if matches:
        return matches[0]
    raise FileNotFoundError(f"No service account key found matching {KEY_GLOB}")

def _get_service():
    from google.oauth2 import service_account
    from googleapiclient.discovery import build
    creds = service_account.Credentials.from_service_account_file(_find_key(), scopes=[SCOPE_SHEETS])
    return build("sheets", "v4", credentials=creds)

def _load_config():
    path = os.path.join(os.path.dirname(__file__), "sheets_config.json")
    if os.path.exists(path):
        with open(path) as f:
            return json.load(f)
    return {}

def get_sheet_id(name: str) -> str:
    config = _load_config()
    entry = config.get(name)
    if not entry:
        for k, v in config.items():
            if k == name or v.get("id") == name:
                return v["id"]
        print(f"Sheet '{name}' not found. Available: {list(config.keys())}")
        sys.exit(1)
    return entry["id"]

def list_sheets():
    config = _load_config()
    if not config:
        print("No sheets configured. Run: python tools/sheets.py discover")
        return
    for name, info in config.items():
        print(f"  {name:30s} ({info['id']})")

def get_worksheets(spreadsheet_id: str):
    service = _get_service()
    meta = service.spreadsheets().get(spreadsheetId=spreadsheet_id).execute()
    return [(s["properties"]["title"], s["properties"]["sheetId"]) for s in meta.get("sheets", [])]

def read_range(spreadsheet_id: str, range_name: str):
    service = _get_service()
    result = service.spreadsheets().values().get(spreadsheetId=spreadsheet_id, range=range_name).execute()
    return result.get("values", [])

def discover_sheets():
    """Discover all spreadsheets the service account can access via Drive API (readonly)."""
    from google.oauth2 import service_account
    from googleapiclient.discovery import build

    SCOPE_DRIVE = "https://www.googleapis.com/auth/drive.readonly"
    key_file = _find_key()
    creds = service_account.Credentials.from_service_account_file(key_file, scopes=[SCOPE_DRIVE])
    drive = build("drive", "v3", credentials=creds)

    config = _load_config()
    page_token = None
    count = 0
    while True:
        resp = drive.files().list(
            q="mimeType='application/vnd.google-apps.spreadsheet' and trashed=false",
            fields="files(id, name, modifiedTime), nextPageToken",
            pageToken=page_token,
            pageSize=100,
        ).execute()
        for f in resp.get("files", []):
            if f["name"] not in config:
                config[f["name"]] = {"id": f["id"]}
                print(f"  + {f['name']}")
                count += 1
        page_token = resp.get("nextPageToken")
        if not page_token:
            break

    path = os.path.join(os.path.dirname(__file__), "sheets_config.json")
    with open(path, "w") as f:
        json.dump(config, f, indent=2, ensure_ascii=False)
    print(f"\n{count} new sheets added. Total: {len(config)}")
    return config

def write_range(spreadsheet_id: str, range_name: str, values: list[list]):
    service = _get_service()
    body = {"values": values}
    service.spreadsheets().values().update(
        spreadsheetId=spreadsheet_id, range=range_name,
        valueInputOption="USER_ENTERED", body=body
    ).execute()

def append_row(spreadsheet_id: str, range_name: str, values: list):
    service = _get_service()
    body = {"values": [values]}
    service.spreadsheets().values().append(
        spreadsheetId=spreadsheet_id, range=range_name,
        valueInputOption="USER_ENTERED", insertDataOption="INSERT_ROWS", body=body
    ).execute()

if __name__ == "__main__":
    args = sys.argv[1:]

    if not args or args[0] == "list":
        list_sheets()
    elif args[0] == "discover":
        discover_sheets()
    else:
        # First arg is sheet name
        sheet_id = get_sheet_id(args[0])
        if len(args) == 1:
            worksheets = get_worksheets(sheet_id)
            print(f"Sheets in '{args[0]}':")
            for name, sid in worksheets:
                print(f"  {name} (sheetId={sid})")
        elif args[1] == "set":
            if len(args) < 4:
                print("Usage: sheets.py <name> set <cell> <value>")
                sys.exit(1)
            cell = args[2]
            val = " ".join(args[3:])
            write_range(sheet_id, cell, [[val]])
            print(f"  Wrote '{val}' to {cell}")
        elif args[1] == "append":
            if len(args) < 4:
                print("Usage: sheets.py <name> append <range> <val1>,<val2>,...")
                sys.exit(1)
            range_name = args[2]
            values = [v.strip() for v in " ".join(args[3:]).split(",")]
            append_row(sheet_id, range_name, values)
            print(f"  Appended row to {range_name}: {values}")
        else:
            data = read_range(sheet_id, args[1])
            if data:
                for row in data:
                    print("\t".join(str(c) for c in row))
            else:
                print("(empty)")

