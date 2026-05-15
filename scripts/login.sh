#!/usr/bin/env bash
set -euo pipefail

# Rough equivalent of jessarcher/dotfiles `scripts/login.sh`, but portable:
# - Works on Linux + WSL (no Fedora-only assumptions)
# - Degrades gracefully if optional tools aren't installed

have() { command -v "$1" >/dev/null 2>&1; }

os_pretty() {
    if [[ -r /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        printf "%s" "${PRETTY_NAME:-${NAME:-Linux}}"
    else
        uname -s
    fi
}

root_usage() {
    if have df; then
        local used total
        used="$(df -h --output=used / 2>/dev/null | tail -n1 | tr -d ' \n' || true)"
        total="$(df -h --output=size / 2>/dev/null | tail -n1 | tr -d ' \n' || true)"
        [[ -n "${used}${total}" ]] && printf "%s/%s" "$used" "$total"
    fi
}

mem_usage() {
    if have free; then
        local used total
        used="$(free -m 2>/dev/null | awk '/^Mem:/ {printf \"%.1fG\", $3/1000}' || true)"
        total="$(free -m 2>/dev/null | awk '/^Mem:/ {printf \"%.0fG\", $2/1000}' || true)"
        [[ -n "${used}${total}" ]] && printf "%s/%s" "$used" "$total"
    fi
}

cpu_temp() {
    if have sensors; then
        # Best-effort: first temperature-like token we can find.
        sensors 2>/dev/null | awk '
      /CPU|Package id 0|Tctl|Tdie/ {
        for (i=1; i<=NF; i++) if ($i ~ /^[+]?([0-9]+\\.[0-9]+|[0-9]+)°C$/) { gsub(/^\\+/,\"\",$i); print $i; exit }
      }' || true
    fi
}

load_avg() {
    if [[ -r /proc/loadavg ]]; then
        awk '{printf "%s %s %s", $1, $2, $3}' /proc/loadavg
    else
        uptime 2>/dev/null | awk -F'load average: ' '{print $2}' | tr -d '\n' || true
    fi
}

render() {
    local os root mem temp load
    os="$(os_pretty)"
    root="$(root_usage)"
    mem="$(mem_usage)"
    temp="$(cpu_temp)"
    load="$(load_avg)"

    # Keep the line stable even if some stats are missing.
    printf "\n"
    printf "     ⣷⣝⢿⣷⣄    %s  %s\n" "󰣇" "$os"
    printf "  ⠲⣶⣶⡿⠟ ⠙⢿⣷⣄"
    [[ -n "$root" ]] && printf "  󰋊 %s" "$root"
    [[ -n "$mem" ]] && printf "  󰍛 %s" "$mem"
    [[ -n "$temp" ]] && printf "   %s" "$temp"
    [[ -n "$load" ]] && printf "  󱑤 %s" "$load"
    printf "\n\n"
}

if have lolcat; then
    render | lolcat --truecolor --seed=22 --spread=6
else
    render
fi
