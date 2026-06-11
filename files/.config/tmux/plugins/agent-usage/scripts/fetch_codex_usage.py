#!/usr/bin/env python3
"""
Fetch OpenAI Codex daily token usage via the OpenAI usage API.
Compatible with agent-usage-tmux plugin interface.
Requires OPENAI_API_KEY in environment; returns 100% remaining if not set.
"""

import argparse
import json
import os
import subprocess
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--field",
        choices=["percent", "reset_at", "reset_in", "active"],
        default="percent",
    )
    return parser.parse_args()


def get_budget():
    result = subprocess.run(
        ["tmux", "show-option", "-gqv", "@codex_daily_budget"],
        capture_output=True, text=True,
    )
    val = result.stdout.strip()
    try:
        return int(val)
    except (ValueError, TypeError):
        return 100_000


def midnight_utc():
    now = datetime.now(timezone.utc)
    midnight = now.replace(hour=0, minute=0, second=0, microsecond=0)
    # next midnight
    next_midnight_ts = int(midnight.timestamp()) + 86400
    return next_midnight_ts


def fetch_usage(api_key):
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    url = f"https://api.openai.com/v1/usage?date={today}"
    req = urllib.request.Request(
        url,
        headers={"Authorization": f"Bearer {api_key}"},
    )
    with urllib.request.urlopen(req, timeout=10) as resp:
        return json.loads(resp.read())


def main():
    args = parse_args()

    reset_at = midnight_utc()
    reset_in = max(0, reset_at - int(time.time()))

    if args.field == "reset_at":
        print(reset_at)
        return
    if args.field == "reset_in":
        print(reset_in)
        return

    api_key = os.environ.get("OPENAI_API_KEY", "")
    if args.field == "active":
        print(1 if api_key else 0)
        return
    if not api_key:
        print(100)
        return

    budget = get_budget()

    try:
        data = fetch_usage(api_key)
        used = sum(
            entry.get("n_context_tokens_total", 0) + entry.get("n_generated_tokens_total", 0)
            for entry in data.get("data", [])
        )
        remaining = max(0, budget - used)
        percent = round(remaining / budget * 100) if budget > 0 else 100
        print(min(100, percent))
    except Exception:
        print(100)


if __name__ == "__main__":
    main()
