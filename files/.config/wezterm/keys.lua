local wezterm = require("wezterm")
local act = wezterm.action

return {
	{
		key = [[q]],
		mods = LEADER_KEY,
		action = wezterm.action.QuitApplication,
	},
	{
		key = [[w]],
		mods = LEADER_KEY,
		action = wezterm.action.CloseCurrentTab({ confirm = true }),
	},
	{
		key = [[f]],
		mods = LEADER_KEY,
		action = wezterm.action({ Search = { CaseSensitiveString = "" } }),
	},
	{
		key = [[R]],
		mods = LEADER_KEY,
		action = wezterm.action.ReloadConfiguration,
	},
	-- splits and window management {{{
	{
		mods = LEADER_KEY,
		key = [[d]],
		action = wezterm.action({
			SplitHorizontal = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		mods = LEADER_KEY .. "|SHIFT",
		key = [[d]],
		action = wezterm.action({
			SplitVertical = { domain = "CurrentPaneDomain" },
		}),
	},
	{
		mods = LEADER_KEY,
		key = "t",
		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
	},
	{
		key = "W",
		mods = LEADER_KEY,
		action = wezterm.action({ CloseCurrentTab = { confirm = false } }),
	},
	{ key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) },
	-- }}}
	{ key = "z", mods = LEADER_KEY, action = wezterm.action.TogglePaneZoomState },
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
	{ key = "c", mods = LEADER_KEY, action = wezterm.action({ CopyTo = "Clipboard" }) },
	{ key = "v", mods = LEADER_KEY, action = wezterm.action({ PasteFrom = "Clipboard" }) },
	-- }}}
	{ key = "=", mods = LEADER_KEY, action = wezterm.action.IncreaseFontSize },
	{ key = "-", mods = LEADER_KEY, action = wezterm.action.DecreaseFontSize },
	-- shorcuts {{{
	{ key = "1", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 0 }) },
	{ key = "2", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 1 }) },
	{ key = "3", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 2 }) },
	{ key = "4", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 3 }) },
	{ key = "5", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 4 }) },
	{ key = "6", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 5 }) },
	{ key = "7", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 6 }) },
	{ key = "8", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 7 }) },
	{ key = "9", mods = LEADER_KEY, action = wezterm.action({ ActivateTab = 8 }) },
	{ key = "L", mods = LEADER_KEY .. "|SHIFT", action = wezterm.action.ShowDebugOverlay },
	-- }}}
}

-- vim: fdm=marker ts=4 sw=4 sts=4 et
