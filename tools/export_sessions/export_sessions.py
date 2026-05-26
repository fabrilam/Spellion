#!/usr/bin/env python3
"""
Export OpenCode sessions from SQLite database to Markdown.

Usage:
    python export_sessions.py --list
    python export_sessions.py --list --limit 50
    python export_sessions.py --session ses_XXXXX --output sesion.md
    python export_sessions.py --session ses_XXXXX --limit 100 --output sesion.md
    python export_sessions.py --list --db "C:/path/to/opencode.db"
    python export_sessions.py --session ses_XXXXX --db "C:/path/to/opencode.db"
"""

import sqlite3
import json
import sys
import os
import argparse
from datetime import datetime
from pathlib import Path

MAX_OUTPUT_LENGTH = 5000


def find_db():
    """Find opencode.db in common platform-specific locations."""
    candidates = []

    if sys.platform == "win32":
        appdata = os.environ.get("APPDATA", "")
        localappdata = os.environ.get("LOCALAPPDATA", "")
        candidates = [
            Path(appdata) / "opencode" / "opencode.db",
            Path(localappdata) / "opencode" / "opencode.db",
            Path.home() / ".local" / "share" / "opencode" / "opencode.db",
            Path.home() / ".local" / "state" / "opencode" / "opencode.db",
            Path.home() / "AppData" / "Roaming" / "opencode" / "opencode.db",
        ]
    else:
        candidates = [
            Path.home() / ".local" / "share" / "opencode" / "opencode.db",
            Path.home() / ".local" / "state" / "opencode" / "opencode.db",
            Path(os.environ.get("XDG_DATA_HOME", ""))
            / "opencode" / "opencode.db",
            Path(os.environ.get("XDG_STATE_HOME", ""))
            / "opencode" / "opencode.db",
        ]

    seen = set()
    for p in candidates:
        resolved = p.resolve()
        if resolved.exists() and str(resolved) not in seen:
            seen.add(str(resolved))
            return str(resolved)

    return None


def connect_db(db_path):
    conn = sqlite3.connect(db_path)
    conn.execute("PRAGMA locking_mode = NORMAL")
    conn.row_factory = sqlite3.Row
    return conn


def list_sessions(conn, limit=20):
    """Return recent sessions ordered by creation time (newest first)."""
    query = """
        SELECT
            s.id,
            s.title,
            s.slug,
            s.directory,
            s.time_created,
            (SELECT COUNT(*) FROM message WHERE session_id = s.id) AS msg_count
        FROM session s
        ORDER BY s.time_created DESC
        LIMIT ?
    """
    return conn.execute(query, (limit,)).fetchall()


def get_messages(conn, session_id, limit=None):
    """Return all message+part rows for a session, ordered chronologically."""
    query = """
        SELECT
            m.id AS msg_id,
            m.time_created AS msg_time,
            json_extract(m.data, '$.role') AS role,
            p.id AS part_id,
            p.data AS part_data,
            p.time_created AS part_time
        FROM message m
        JOIN part p ON p.message_id = m.id
        WHERE m.session_id = ?
        ORDER BY m.time_created, p.time_created
    """
    rows = conn.execute(query, (session_id,)).fetchall()

    if limit is not None:
        seen = set()
        limited = []
        for r in rows:
            seen.add(r["msg_id"])
            if len(seen) > limit:
                break
            limited.append(r)
        return limited

    return rows


def format_ts(ts_ms):
    """Convert UNIX millisecond timestamp to a readable string."""
    if not ts_ms:
        return "unknown"
    return datetime.fromtimestamp(ts_ms / 1000).strftime("%Y-%m-%d %H:%M:%S")


def export_session(conn, session_id, output, limit=None):
    """Export a single session to a Markdown file."""
    session = conn.execute(
        "SELECT id, title, time_created FROM session WHERE id = ?",
        (session_id,),
    ).fetchone()

    if not session:
        print(f"Error: session '{session_id}' not found.", file=sys.stderr)
        sys.exit(1)

    messages = get_messages(conn, session_id, limit)

    if not messages:
        print(f"Session '{session_id}' has no messages.", file=sys.stderr)
        sys.exit(1)

    unique_msg_ids = set(m["msg_id"] for m in messages)

    lines = []
    title = session["title"] or "Untitled Session"
    lines.append(f"# {title}")
    lines.append("")
    lines.append(f"- **Session ID:** `{session['id']}`")
    lines.append(f"- **Started:** {format_ts(session['time_created'])}")
    lines.append(f"- **Messages:** {len(unique_msg_ids)}")
    lines.append("")

    current_msg_id = None
    current_role = None
    current_parts = []

    def flush_message():
        nonlocal current_msg_id, current_role, current_parts
        if current_parts and current_role:
            lines.extend(format_message(current_role, current_parts))
        current_msg_id = None
        current_role = None
        current_parts = []

    for m in messages:
        if m["msg_id"] != current_msg_id:
            flush_message()
            current_msg_id = m["msg_id"]
            current_role = m["role"]
            current_parts = []

        try:
            part_data = json.loads(m["part_data"])
        except json.JSONDecodeError:
            part_data = {"type": "text", "text": m["part_data"]}

        current_parts.append(part_data)

    flush_message()

    with open(output, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")

    print(f"Exported {len(unique_msg_ids)} messages to {output}")
    return output


def format_message(role, parts):
    """Format a single message with text parts and tool calls into Markdown lines."""
    lines = []
    text_parts = []
    tool_parts = []
    skip_types = {"step-start", "step-finish"}

    for p in parts:
        ptype = p.get("type", "text")
        if ptype in skip_types:
            continue
        if ptype == "text" or ptype is None:
            text = p.get("text", "").strip()
            if text:
                text_parts.append(text)
        elif ptype == "tool":
            tool_parts.append(p)

    if not text_parts and not tool_parts:
        return lines

    lines.append("---")
    lines.append("")

    label = "User" if role == "user" else "Assistant"
    lines.append(f"## {label}")
    lines.append("")

    for text in text_parts:
        lines.append(text)
        lines.append("")

    for tool in tool_parts:
        tool_name = tool.get("tool", "unknown")
        state = tool.get("state", {})
        tool_input = state.get("input")
        tool_output = state.get("output")

        lines.append(f"### Tool: `{tool_name}`")
        lines.append("")

        if tool_input is not None:
            lines.append("**Input:**")
            lines.append("")
            lines.append("```json")
            if isinstance(tool_input, dict | list):
                lines.append(json.dumps(tool_input, indent=2, ensure_ascii=False))
            else:
                lines.append(str(tool_input))
            lines.append("```")
            lines.append("")

        if tool_output is not None:
            output_str = str(tool_output)
            truncated = len(output_str) > MAX_OUTPUT_LENGTH
            if truncated:
                output_str = output_str[:MAX_OUTPUT_LENGTH]
            lines.append("**Output:**" + (" *(truncated)*" if truncated else ""))
            lines.append("")
            lines.append("```")
            lines.append(output_str)
            lines.append("```")
            lines.append("")

    return lines


def main():
    parser = argparse.ArgumentParser(
        description="Export OpenCode sessions to Markdown"
    )
    parser.add_argument(
        "--list",
        action="store_true",
        help="List recent sessions with metadata",
    )
    parser.add_argument(
        "--session",
        type=str,
        help="Session ID to export (e.g. ses_1d0e4bc43ffe...)",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=None,
        help="Limit number of messages (for --session or --list)",
    )
    parser.add_argument(
        "--output",
        type=str,
        default="sesion.md",
        help="Output file path (default: sesion.md)",
    )
    parser.add_argument(
        "--db",
        type=str,
        default=None,
        help="Path to opencode.db (auto-detected if not provided)",
    )

    args = parser.parse_args()

    if not args.list and not args.session:
        parser.print_help()
        print("\nError: use --list or --session (or both).", file=sys.stderr)
        sys.exit(1)

    db_path = args.db or find_db()
    if not db_path:
        print(
            "Error: opencode.db not found. Specify the path with --db.",
            file=sys.stderr,
        )
        sys.exit(1)

    conn = connect_db(db_path)

    if args.list:
        limit = args.limit or 20
        sessions = list_sessions(conn, limit=limit)

        if not sessions:
            print("No sessions found.")
            conn.close()
            return

        header = f"{'ID':50s} {'Title':50s} {'Date':22s} {'Msgs':>5s}  Project"
        sep = "-" * len(header)
        print(header)
        print(sep)

        for s in sessions:
            title = (s["title"] or "Untitled")[:48]
            date = format_ts(s["time_created"])
            directory = (s["directory"] or "")[:30]
            print(
                f"{s['id']:50s} {title:50s} {date:22s} {s['msg_count']:5d}  {directory}"
            )

    if args.session:
        export_session(conn, args.session, args.output, args.limit)

    conn.close()


if __name__ == "__main__":
    main()
