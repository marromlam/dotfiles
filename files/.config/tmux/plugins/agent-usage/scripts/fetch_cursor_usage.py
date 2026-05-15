#!/usr/bin/env python3
"""
Fetch Cursor premium request utilisation via Cursor API.
Reads auth token from Windows SQLite db (via WSL /mnt/c path).
Compatible with agent-usage-tmux plugin interface.
"""

import argparse
import json
import sqlite3
import time
import urllib.request


VSCDB_PATH = "/mnt/c/Users/marcos.romero/AppData/Roaming/Cursor/User/globalStorage/state.vscdb"
CURSOR_API_URL = "https://cursor.com/api/usage"


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--field",
        choices=["percent", "reset_at", "reset_in"],
        default="percent",
    )
    return parser.parse_args()


def get_session_token():
    import jwt as pyjwt
    conn = sqlite3.connect(f"file:{VSCDB_PATH}?mode=ro", uri=True)
    try:
        cur = conn.cursor()
        cur.execute("SELECT value FROM ItemTable WHERE key = 'cursorAuth/accessToken'")
        row = cur.fetchone()
    finally:
        conn.close()

    if not row or not row[0]:
        raise SystemExit("No Cursor auth token found")

    jwt_token = row[0]
    decoded = pyjwt.decode(jwt_token, options={"verify_signature": False})
    sub = decoded.get("sub", "")
    user_id = sub.split("|")[1] if "|" in sub else sub
    return user_id, f"{user_id}%3A%3A{jwt_token}"


def fetch_usage(user_id, session_token):
    url = f"{CURSOR_API_URL}?user={user_id}"
    req = urllib.request.Request(
        url,
        headers={
            "Cookie": f"WorkosCursorSessionToken={session_token}",
            "Content-Type": "application/json",
            "User-Agent": "Mozilla/5.0",
        },
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read())


def main():
    args = parse_args()

    try:
        user_id, session_token = get_session_token()
        data = fetch_usage(user_id, session_token)
    except Exception:
        print(50 if args.field == "percent" else 0)
        return

    gpt4 = data.get("gpt-4", {})
    used = gpt4.get("numRequests", 0)
    limit = gpt4.get("maxRequestUsage") or 500

    remaining = max(0, limit - used)
    percent = round((remaining / limit) * 100) if limit else 0

    if args.field == "percent":
        print(percent)
    else:
        print(0)


if __name__ == "__main__":
    main()
