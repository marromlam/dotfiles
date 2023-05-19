local wezterm = require("wezterm")
local act = wezterm.action


return {
  {
		key = [[R]],
    mods = 'CTRL|ALT',
    action = wezterm.action.ReloadConfiguration,
  },
    -- splits and window management {{{
		{
			mods = "CTRL|ALT",
			key = [[d]],
			action = wezterm.action({
				SplitHorizontal = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			mods = "CTRL|ALT|SHIFT",
			key = [[d]],
			action = wezterm.action({
				SplitVertical = { domain = "CurrentPaneDomain" },
			}),
		},
		{
			mods = "CTRL|ALT",
			key = "t",
			action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
		},
		{
			key = "W",
			mods = "CTRL|ALT",
			action = wezterm.action({ CloseCurrentTab = { confirm = false } }),
		},
		{ key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
  -- }}}
		{ key = "z", mods = "CTRL|ALT", action = wezterm.action.TogglePaneZoomState },
		{ key = "F11", mods = "", action = wezterm.action.ToggleFullScreen },
		{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) },

		{ key = "[", mods = "ALT", action = wezterm.action({ ActivateTabRelative = -1 }) },
		{ key = "]", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "{", mods = "SHIFT|ALT", action = wezterm.action.MoveTabRelative(-1) },
		{ key = "}", mods = "SHIFT|ALT", action = wezterm.action.MoveTabRelative(1) },
    -- }}}
     -- copy and paste {{{
		{ key = "v", mods = "ALT", action = wezterm.action.ActivateCopyMode },
		{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) },
     -- }}}
		{ key = "=", mods = "CTRL|ALT", action = wezterm.action.IncreaseFontSize },
		{ key = "-", mods = "CTRL|ALT", action = wezterm.action.DecreaseFontSize },
     -- shorcuts {{{
		{ key = "1", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 0 }) },
		{ key = "2", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 1 }) },
		{ key = "3", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 2 }) },
		{ key = "4", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 3 }) },
		{ key = "5", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 4 }) },
		{ key = "6", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 5 }) },
		{ key = "7", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 6 }) },
		{ key = "8", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 7 }) },
		{ key = "9", mods = "CTRL|ALT", action = wezterm.action({ ActivateTab = 8 }) },
    { key = 'ESC', mods = 'CTRL|ALT', action = wezterm.action.ShowDebugOverlay },
    -- }}}
}


-- vim: foldmethod=marker
