#!/usr/bin/env bash
# Renders AI quota widgets for tmux statusline.
# Default: compact inline (icon + %).
# --popup: detailed floating-window view with full bars.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON="${PYTHON:-python3}"

# ---------------------------------------------------------------------------
# Data fetchers
# ---------------------------------------------------------------------------

_run_cmd() {
    local agent="$1" field="$2"
    local opt="@agent_usage_cmd_${agent}"
    local cmd
    cmd="$(tmux show-option -gqv "$opt" 2>/dev/null)"
    if [[ -z "$cmd" ]]; then
        case "$agent" in
        copilot) cmd="$PYTHON $SCRIPT_DIR/fetch_copilot_usage.py" ;;
        cursor)  cmd="$PYTHON $SCRIPT_DIR/fetch_cursor_usage.py" ;;
        claude)  cmd="$PYTHON $SCRIPT_DIR/fetch_claude_usage.py" ;;
        codex)   cmd="$PYTHON $SCRIPT_DIR/fetch_codex_usage.py" ;;
        esac
    fi
    [[ -n "$field" ]] && cmd="$cmd --field $field"
    eval "$cmd" 2>/dev/null || echo "0"
}

get_percentage() { _run_cmd "$1" percent; }
get_reset_in()   { _run_cmd "$1" reset_in; }
get_active()     { _run_cmd "$1" active; }

# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

_color_for_pct() {
    local pct="$1"
    if ((pct >= 60)); then echo "colour71"
    elif ((pct >= 30)); then echo "colour214"
    else echo "colour160"; fi
}

format_reset() {
    local reset_in="$1"
    [[ "$reset_in" =~ ^[0-9]+$ ]] || reset_in=0
    local hours=$(( reset_in / 3600 ))
    local minutes=$(( (reset_in % 3600) / 60 ))
    if ((hours >= 48)); then
        printf "%dd" "$(( hours / 24 ))"
    elif ((hours >= 1)); then
        printf "%dh" "$hours"
    else
        printf "%02d:%02d" "$hours" "$minutes"
    fi
}

# ---------------------------------------------------------------------------
# Compact mode (status bar)
# ---------------------------------------------------------------------------

render_compact_agent() {
    local agent="$1" icon="$2"
    local pct active
    pct=$(get_percentage "$agent")
    # agents that support active flag
    case "$agent" in
    codex)
        active=$(get_active "$agent")
        if [[ "$active" == "0" ]]; then
            printf "#[fg=colour240,bold]%s—#[default]" "$icon"
            return
        fi
        ;;
    esac
    local color
    color=$(_color_for_pct "$pct")
    printf "#[fg=%s,bold]%s%d%%#[default]" "$color" "$icon" "$pct"
}

render_compact() {
    render_compact_agent "copilot" "⊙"
    printf " "
    render_compact_agent "claude" "◇"
    printf " "
    render_compact_agent "codex" "⬡"
}

# ---------------------------------------------------------------------------
# Popup mode (display-popup terminal)
# ---------------------------------------------------------------------------

_ansi_color() {
    # maps colour71/colour214/colour160 to ANSI sequences
    case "$1" in
    colour71)  printf '\033[32m' ;;  # green
    colour214) printf '\033[33m' ;;  # yellow
    colour160) printf '\033[31m' ;;  # red
    colour240) printf '\033[90m' ;;  # dark grey
    *)         printf '\033[0m'  ;;
    esac
}
_ansi_reset() { printf '\033[0m'; }

render_popup_bar() {
    local pct="$1" width=14
    local empty_bg_char="░"
    local color
    color=$(_color_for_pct "$pct")

    local filled=$(( pct * width / 100 ))
    local empty=$(( width - filled ))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty;  i++)); do bar+="$empty_bg_char"; done

    printf "%s%s%s" "$(_ansi_color "$color")" "$bar" "$(_ansi_reset)"
}

render_popup_row() {
    local agent="$1" icon="$2" label="$3"
    local pct reset_in reset_label active

    case "$agent" in
    codex)
        active=$(get_active "$agent")
        if [[ "$active" == "0" ]]; then
            printf "  %s %-8s  %s%s%s\n" \
                "$icon" "$label" \
                "$(_ansi_color colour240)" "n/a  (set OPENAI_API_KEY to enable)" "$(_ansi_reset)"
            return
        fi
        ;;
    esac

    pct=$(get_percentage "$agent")
    reset_in=$(get_reset_in "$agent")
    reset_label=$(format_reset "$reset_in")

    local color
    color=$(_color_for_pct "$pct")

    printf "  %s %-8s  %s%3d%%%s  " \
        "$icon" "$label" "$(_ansi_color "$color")" "$pct" "$(_ansi_reset)"
    render_popup_bar "$pct"
    printf "  %s%s%s\n" "$(_ansi_color "$color")" "$reset_label" "$(_ansi_reset)"
}

render_popup() {
    local divider="  ──────────────────────────────────────────"
    printf "\n"
    render_popup_row "copilot" "⊙" "Copilot"
    printf "%s\n" "$divider"
    render_popup_row "claude"  "◇" "Claude"
    printf "%s\n" "$divider"
    render_popup_row "codex"   "⬡" "Codex"
    printf "\n"
    printf "  \033[90mq to close\033[0m\n"
}

# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if [[ "$1" == "--popup" ]]; then
    render_popup
else
    render_compact
fi
