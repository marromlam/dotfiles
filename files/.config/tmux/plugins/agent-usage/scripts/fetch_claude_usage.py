#!/usr/bin/env python3
"""
Estimate Claude Code Max plan usage from ~/.claude/history.jsonl.
Compatible with agent-usage-tmux plugin interface.
"""

import argparse
import json
import os
import subprocess
import time
from datetime import datetime, timezone


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--field",
        choices=["percent", "reset_at", "reset_in"],
        default="percent",
    )
    return parser.parse_args()


def get_limit():
    result = subprocess.run(
        ["tmux", "show-option", "-gqv", "@claude_monthly_limit"],
        capture_output=True, text=True,
    )
    val = result.stdout.strip()
    try:
        return int(val)
    except (ValueError, TypeError):
        return 500


def billing_period_start():
    billing_day = int(os.environ.get("CLAUDE_BILLING_DAY", "1"))
    now = datetime.now(timezone.utc)
    start = now.replace(day=billing_day, hour=0, minute=0, second=0, microsecond=0)
    if start > now:
        # rolled back to previous month
        if start.month == 1:
            start = start.replace(year=start.year - 1, month=12)
        else:
            start = start.replace(month=start.month - 1)
    return start


def next_billing_start(period_start):
    if period_start.month == 12:
        return period_start.replace(year=period_start.year + 1, month=1)
    return period_start.replace(month=period_start.month + 1)


def count_messages(since_ts_ms):
    history = os.path.expanduser("~/.claude/history.jsonl")
    if not os.path.exists(history):
        return 0
    count = 0
    with open(history) as f:
        for line in f:
            try:
                entry = json.loads(line)
                if entry.get("timestamp", 0) >= since_ts_ms:
                    count += 1
            except (json.JSONDecodeError, KeyError):
                pass
    return count


def main():
    args = parse_args()

    period_start = billing_period_start()
    period_start_ms = int(period_start.timestamp() * 1000)
    next_start = next_billing_start(period_start)
    reset_at = int(next_start.timestamp())
    reset_in = max(0, reset_at - int(time.time()))

    if args.field == "reset_at":
        print(reset_at)
        return
    if args.field == "reset_in":
        print(reset_in)
        return

    limit = get_limit()
    used = count_messages(period_start_ms)
    remaining = max(0, limit - used)
    percent = round(remaining / limit * 100) if limit > 0 else 100
    print(percent)


if __name__ == "__main__":
    main()
