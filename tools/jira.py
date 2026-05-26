#!/usr/bin/env python3
"""
Jira CLI — interact with Atlassian Jira from the terminal.
Usage:
    python tools/jira.py config              # Setup credentials
    python tools/jira.py list                # List issues
    python tools/jira.py create <summary>    # Create issue (then type description, Ctrl+Z/END to finish)
    python tools/jira.py get <issue-key>     # Show issue details
    python tools/jira.py update <issue-key> <status-name>  # Transition status
"""

import json, os, sys, base64
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError

CONFIG_FILE = Path(__file__).parent / "jira_config.json"
JIRA_BASE = "https://fabriciolamorte.atlassian.net"
PROJECT_KEY = "KAN"


def _load_config() -> dict:
    if not CONFIG_FILE.exists():
        print("No config found. Run: python tools/jira.py config")
        sys.exit(1)
    with open(CONFIG_FILE) as f:
        return json.load(f)


def _save_config(email: str, token: str) -> None:
    with open(CONFIG_FILE, "w") as f:
        json.dump({"email": email, "token": token}, f)
    CONFIG_FILE.chmod(0o600)
    print(f"Config saved to {CONFIG_FILE}")


def _auth_header(cfg: dict) -> str:
    raw = f"{cfg['email']}:{cfg['token']}"
    return "Basic " + base64.b64encode(raw.encode()).decode()


def _api_get(path: str, cfg: dict, base_path: str = "") -> dict:
    url = f"{JIRA_BASE}{base_path or '/rest/api/2'}{path}"
    req = Request(url, headers={"Authorization": _auth_header(cfg), "Accept": "application/json"})
    with urlopen(req, timeout=15) as resp:
        return json.loads(resp.read())


def _api_post(path: str, body: dict, cfg: dict, base_path: str = "") -> dict:
    url = f"{JIRA_BASE}{base_path or '/rest/api/2'}{path}"
    data = json.dumps(body).encode()
    req = Request(url, data=data, headers={
        "Authorization": _auth_header(cfg),
        "Content-Type": "application/json",
        "Accept": "application/json",
    })
    try:
        with urlopen(req, timeout=15) as resp:
            return json.loads(resp.read())
    except HTTPError as e:
        err = e.read().decode()
        print(f"HTTP {e.code}: {err[:500]}")
        sys.exit(1)


# ── Commands ─────────────────────────────────────

def cmd_config():
    email = input("Email: ").strip()
    token = input("API Token: ").strip()
    _save_config(email, token)


def cmd_list():
    cfg = _load_config()
    data = _api_get(f"/board/{2}/issue?maxResults=30&fields=summary,status", cfg, "/rest/agile/1.0")
    issues = data.get("issues", [])
    if not issues:
        print("No issues found.")
        return
    print(f"{'Key':<14} {'Status':<18} {'Summary'}")
    print("-" * 80)
    for iss in issues:
        key = iss["key"]
        fields = iss.get("fields", {})
        status = fields.get("status", {}).get("name", "?")
        summary = fields.get("summary", "?")
        print(f"{key:<14} {status:<18} {summary}")


def cmd_create(summary: str):
    cfg = _load_config()
    print("Description (Ctrl+Z then Enter to finish, or type END on a blank line):")
    desc_lines = []
    try:
        while True:
            line = input()
            if line.strip() == "END":
                break
            desc_lines.append(line)
    except EOFError:
        pass
    description = "\n".join(desc_lines).strip()
    if not description:
        description = "Created via jira.py CLI"

    body = {
        "fields": {
            "project": {"key": PROJECT_KEY},
            "summary": summary,
            "description": description,
            "issuetype": {"name": "Task"},
        }
    }
    result = _api_post("/issue", body, cfg)
    key = result.get("key", "?")
    print(f"Created: {JIRA_BASE}/browse/{key}")


def cmd_get(issue_key: str):
    cfg = _load_config()
    data = _api_get(f"/issue/{issue_key}", cfg)
    fields = data.get("fields", {})
    print(f"Key:     {data['key']}")
    print(f"Summary: {fields.get('summary', '?')}")
    print(f"Status:  {fields.get('status', {}).get('name', '?')}")
    desc = fields.get("description", "")
    if desc:
        print(f"Description: {desc[:500]}")
    print(f"URL: {JIRA_BASE}/browse/{data['key']}")


def cmd_update(issue_key: str, status_name: str):
    cfg = _load_config()
    transitions = _api_get(f"/issue/{issue_key}/transitions", cfg)
    target = None
    for t in transitions.get("transitions", []):
        if t["to"]["name"].lower() == status_name.lower():
            target = t
            break
    if not target:
        available = [t["to"]["name"] for t in transitions.get("transitions", [])]
        print(f"Status '{status_name}' not available. Available: {', '.join(available)}")
        sys.exit(1)
    _api_post(f"/issue/{issue_key}/transitions", {"transition": {"id": target["id"]}}, cfg)
    print(f"{issue_key} → {target['to']['name']}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    cmd = sys.argv[1]
    args = sys.argv[2:]

    if cmd == "config":
        cmd_config()
    elif cmd == "list":
        cmd_list()
    elif cmd == "create":
        if not args:
            print("Usage: python tools/jira.py create <summary>")
            sys.exit(1)
        cmd_create(" ".join(args))
    elif cmd == "get":
        if not args:
            print("Usage: python tools/jira.py get <issue-key>")
            sys.exit(1)
        cmd_get(args[0])
    elif cmd == "update":
        if len(args) < 2:
            print("Usage: python tools/jira.py update <issue-key> <status>")
            sys.exit(1)
        cmd_update(args[0], args[1])
    else:
        print(f"Unknown command: {cmd}")
        print(__doc__)
        sys.exit(1)
