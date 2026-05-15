#!/usr/bin/env python3
"""
Fetch GitHub Copilot premium request utilisation via `gh` CLI.
Compatible with agent-usage-tmux plugin interface.
"""

import argparse
import json
import subprocess
import time


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--field",
        choices=["percent", "reset_at", "reset_in"],
        default="percent",
    )
    return parser.parse_args()


def fetch_quota():
    result = subprocess.run(
        ["gh", "api", "/copilot_internal/user"],
        capture_output=True, text=True, timeout=10,
    )
    if result.returncode != 0:
        raise SystemExit(f"gh api failed: {result.stderr.strip()}")
    return json.loads(result.stdout)


def main():
    args = parse_args()
    data = fetch_quota()
    p = data["quota_snapshots"]["premium_interactions"]

    if p.get("unlimited"):
        print(100 if args.field == "percent" else 0)
        return

    percent_remaining = round(p.get("percent_remaining", 0))

    reset_at = 0
    reset_str = data.get("quota_reset_date_utc", "")
    if reset_str:
        from datetime import datetime, timezone
        try:
            reset_dt = datetime.fromisoformat(reset_str.replace("Z", "+00:00"))
            reset_at = int(reset_dt.timestamp())
        except ValueError:
            pass

    reset_in = max(0, reset_at - int(time.time()))

    if args.field == "percent":
        print(percent_remaining)
    elif args.field == "reset_at":
        print(reset_at)
    else:
        print(reset_in)


if __name__ == "__main__":
    main()
