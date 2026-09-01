# Dracula Pro - Tmux Theme
# The classic Dracula Pro theme with purple tones and precise contrast
# Author: Dracula Pro
# Version: 1.0.0

# Color definitions
STATUS_BAR_BG_COLOR="#111111"
# STATUS_BAR_BG_COLOR="#22212C"
STATUS_BAR_FG_COLOR="#CDCDC8"
STATUS_BAR_FG_COLOR="#FFCDC8"
ACTIVE_FG_COLOR="#F8F8F2"
INACTIVE_FG_COLOR="#7970A9"

# Bubble colors for session/windows
# Bubbles share the statusbar background — text color differentiates active/inactive
SESSION_BUBBLE_BG_COLOR="$STATUS_BAR_BG_COLOR"
SESSION_BUBBLE_FG_COLOR="$STATUS_BAR_FG_COLOR"
SESSION_BUBBLEON_BG_COLOR="$STATUS_BAR_BG_COLOR"
SESSION_BUBBLEON_FG_COLOR="#8AFF80"

WINDOW_BUBBLE_BG_COLOR="$STATUS_BAR_BG_COLOR"
WINDOW_BUBBLE_FG_COLOR="$STATUS_BAR_FG_COLOR"
WINDOW_BUBBLEON_BG_COLOR="$STATUS_BAR_BG_COLOR"
WINDOW_BUBBLEON_FG_COLOR="$ACTIVE_FG_COLOR"

# Powerline-style separators
LBORDER="<"
RBORDER=">"
WINDOW_INNER_BORDER="<"
SESSION_INNER_BORDER=" "

# Icons
SESSION_ICON="󱂬"
BELL_ICON="⚘"

# ============================================================================
# General Options
# ============================================================================

set-option -g status on
set-option -g status-position top
set-option -g status-style fg=$STATUS_BAR_FG_COLOR,bg=$STATUS_BAR_BG_COLOR
set-option -g status-justify centre
set-option -g status-left-length 50
set-option -g status-right-length 50

# Pane borders
set-option -g pane-active-border-style fg=#7970A9
set-option -g pane-border-style fg=#504C67

# Window notifications
set-option -g monitor-activity off
set-option -g visual-activity off

# Message style (command line)
set-option -g message-style bg=#7970A9,fg=#22212C,bold
set-option -g message-command-style bg=#7970A9,fg=#22212C,bold

# Copy mode / selection style (subtle selection color with light text)
set-window-option -g mode-style bg=#454158,fg=#F8F8F2
set-window-option -g copy-mode-match-style bg=#8AFF80,fg=#22212C
set-window-option -g copy-mode-current-match-style bg=#FF80BF,fg=#22212C
set-window-option -g copy-mode-mark-style bg=#FFFF80,fg=#22212C

# ============================================================================
# Status Bar Left (Session)
# ============================================================================

# Session bubble - inactive (normal mode)
STATUS_INACTIVE=""\
"#[fg=$SESSION_BUBBLE_BG_COLOR bg=$SESSION_BUBBLE_BG_COLOR]$LBORDER"\
"#[fg=$INACTIVE_FG_COLOR bg=$SESSION_BUBBLE_BG_COLOR]$SESSION_INNER_BORDER$SESSION_ICON #S$SESSION_INNER_BORDER"\
"#[fg=$SESSION_BUBBLE_BG_COLOR bg=$SESSION_BUBBLE_BG_COLOR]$RBORDER"

# Session bubble - active (prefix mode)
STATUS_ACTIVE=""\
"#[fg=$SESSION_BUBBLEON_BG_COLOR bg=$SESSION_BUBBLEON_BG_COLOR]$LBORDER"\
"#[fg=$SESSION_BUBBLEON_FG_COLOR bg=$SESSION_BUBBLEON_BG_COLOR]$SESSION_INNER_BORDER$SESSION_ICON #S$SESSION_INNER_BORDER"\
"#[fg=$SESSION_BUBBLEON_BG_COLOR bg=$SESSION_BUBBLEON_BG_COLOR]$RBORDER"

# Show active style when prefix is pressed
set-option -g status-left "#{?client_prefix,$STATUS_ACTIVE,$STATUS_INACTIVE}"

# ============================================================================
# Status Bar Right
# ============================================================================

set-option -g status-right ""\
"#[fg=$SESSION_BUBBLE_BG_COLOR bg=$SESSION_BUBBLE_BG_COLOR]$LBORDER"\
"#[fg=$INACTIVE_FG_COLOR bg=$SESSION_BUBBLE_BG_COLOR] %H:%M "\
"#[fg=$SESSION_BUBBLE_BG_COLOR bg=$SESSION_BUBBLE_BG_COLOR]$RBORDER"

# ============================================================================
# Window Status Format
# ============================================================================

# Bell and zoom indicators
LICON="$WINDOW_INNER_BORDER#{?window_bell_flag,#[fg=#FF9580]$BELL_ICON, }"
RICON="#{?window_active,#{?window_zoomed_flag,⧉, }, }$WINDOW_INNER_BORDER"

# Window number formatting (uses helper script if available)
WNUM='#($HOME/.config/tmux/helpers/window_to_num #I) '

# Inactive window bubble
WINDOW_INACTIVE=""\
"#[bg=$WINDOW_BUBBLE_BG_COLOR fg=$WINDOW_BUBBLE_BG_COLOR]"\
"#[bg=$WINDOW_BUBBLE_BG_COLOR fg=$INACTIVE_FG_COLOR]$LICON"\
"#[dim]${WNUM}#W"\
"$RICON#[bg=$WINDOW_BUBBLE_BG_COLOR,fg=$WINDOW_BUBBLE_BG_COLOR,nodim]"

# Active window bubble
WINDOW_ACTIVE=""\
"#[bg=$WINDOW_BUBBLEON_BG_COLOR fg=$WINDOW_BUBBLEON_BG_COLOR]"\
"#[bg=$WINDOW_BUBBLEON_BG_COLOR fg=$ACTIVE_FG_COLOR]$LICON"\
"#[bold]${WNUM}#W"\
"$RICON#[bg=$WINDOW_BUBBLEON_BG_COLOR fg=$WINDOW_BUBBLEON_BG_COLOR]"

set-window-option -g window-status-format "$WINDOW_INACTIVE"
set-window-option -g window-status-current-format "$WINDOW_ACTIVE"
set-window-option -g window-status-separator ""

# Window status styling
set-window-option -g window-status-activity-style bg=$STATUS_BAR_BG_COLOR,fg=#FFFF80
set-window-option -g window-status-bell-style bg=#FF9580,fg=#22212C,bold
