local wezterm = require("wezterm")
--[[ local navigate = require("navigate") ]]
local mux = wezterm.mux




local act = wezterm.action

local function isViProcess(pane) 
    -- get_foreground_process_name On Linux, macOS and Windows, 
    -- the process can be queried to determine this path. Other operating systems 
    -- (notably, FreeBSD and other unix systems) are not currently supported
    return pane:get_foreground_process_name():find('n?vim') ~= nil
    -- return pane:get_title():find("n?vim") ~= nil
end

local function conditionalActivatePane(window, pane, pane_direction, vim_direction)
    if isViProcess(pane) then
        window:perform_action(
            -- This should match the keybinds you set in Neovim.
            act.SendKey({ key = vim_direction, mods = 'ALT' }),
            pane
        )
    else
        window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
    end
end

wezterm.on('ActivatePaneDirection-right', function(window, pane)
    conditionalActivatePane(window, pane, 'Right', 'l')
end)
wezterm.on('ActivatePaneDirection-left', function(window, pane)
    conditionalActivatePane(window, pane, 'Left', 'h')
end)
wezterm.on('ActivatePaneDirection-up', function(window, pane)
    conditionalActivatePane(window, pane, 'Up', 'k')
end)
wezterm.on('ActivatePaneDirection-down', function(window, pane)
    conditionalActivatePane(window, pane, 'Down', 'j')
end)

navigate =  {
        { key = 'h', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-left') },
        { key = 'j', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-down') },
        { key = 'k', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-up') },
        { key = 'l', mods = 'CTRL', action = act.EmitEvent('ActivatePaneDirection-right') },
}











--[[ wezterm.on("gui-startup", function() ]]
--[[     local tab, pane, window = mux.spawn_window {} ]]
--[[     window:gui_window():maximize() ]]
--[[ end) ]]

local function is_vi_process(pane)
	return pane:get_foreground_process_name():find("n?vim") ~= nil
end

local function conditional_activate_pane(window, pane, pane_direction, vim_direction)
	if is_vi_process(pane) then
		window:perform_action(wezterm.action.SendKey({ key = vim_direction, mods = "ALT" }), pane)
	else
		window:perform_action(wezterm.action.ActivatePaneDirection(pane_direction), pane)
	end
end

wezterm.on("ActivatePaneDirection-right", function(window, pane)
	conditional_activate_pane(window, pane, "Right", "l")
end)
wezterm.on("ActivatePaneDirection-left", function(window, pane)
	conditional_activate_pane(window, pane, "Left", "h")
end)
wezterm.on("ActivatePaneDirection-up", function(window, pane)
	conditional_activate_pane(window, pane, "Up", "k")
end)
wezterm.on("ActivatePaneDirection-down", function(window, pane)
	conditional_activate_pane(window, pane, "Down", "j")
end)

local colors = {
	rosewater = "#F4DBD6",
	flamingo = "#F0C6C6",
	pink = "#F5BDE6",
	mauve = "#C6A0F6",
	red = "#ED8796",
	maroon = "#EE99A0",
	peach = "#F5A97F",
	yellow = "#EED49F",
	green = "#A6DA95",
	teal = "#8BD5CA",
	sky = "#91D7E3",
	sapphire = "#7DC4E4",
	blue = "#8AADF4",
	lavender = "#B7BDF8",

	text = "#CAD3F5",
	subtext1 = "#B8C0E0",
	subtext0 = "#A5ADCB",
	overlay2 = "#939AB7",
	overlay1 = "#8087A2",
	overlay0 = "#6E738D",
	surface2 = "#5B6078",
	surface1 = "#494D64",
	surface0 = "#363A4F",

	base = "#24273A",
	mantle = "#1E2030",
	crust = "#181926",
}

local function get_process(tab)
	local process_icons = {
		["docker"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = wezterm.nerdfonts.linux_docker },
		},
		["docker-compose"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = wezterm.nerdfonts.linux_docker },
		},
		["nvim"] = {
			{ Foreground = { Color = colors.green } },
			{ Text = wezterm.nerdfonts.custom_vim },
		},
		["vim"] = {
			{ Foreground = { Color = colors.green } },
			{ Text = wezterm.nerdfonts.dev_vim },
		},
		["node"] = {
			{ Foreground = { Color = colors.green } },
			{ Text = wezterm.nerdfonts.mdi_hexagon },
		},
		["zsh"] = {
			{ Foreground = { Color = colors.peach } },
			{ Text = wezterm.nerdfonts.dev_terminal },
		},
		["cmd.exe"] = {
			{ Foreground = { Color = colors.peach } },
			{ Text = wezterm.nerdfonts.dev_terminal },
		},
		["wslhost.exe"] = {
			{ Foreground = { Color = colors.peach } },
			{ Text = wezterm.nerdfonts.dev_terminal },
		},
		["bash"] = {
			{ Foreground = { Color = colors.subtext0 } },
			{ Text = wezterm.nerdfonts.cod_terminal_bash },
		},
		["htop"] = {
			{ Foreground = { Color = colors.yellow } },
			{ Text = wezterm.nerdfonts.mdi_chart_donut_variant },
		},
		["cargo"] = {
			{ Foreground = { Color = colors.peach } },
			{ Text = wezterm.nerdfonts.dev_rust },
		},
		["go"] = {
			{ Foreground = { Color = colors.sapphire } },
			{ Text = wezterm.nerdfonts.mdi_language_go },
		},
		["lazydocker"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = wezterm.nerdfonts.linux_docker },
		},
		["git"] = {
			{ Foreground = { Color = colors.peach } },
			{ Text = wezterm.nerdfonts.dev_git },
		},
		["lazygit"] = {
			{ Foreground = { Color = colors.peach } },
			{ Text = wezterm.nerdfonts.dev_git },
		},
		["lua"] = {
			{ Foreground = { Color = colors.blue } },
			{ Text = wezterm.nerdfonts.seti_lua },
		},
		["wget"] = {
			{ Foreground = { Color = colors.yellow } },
			{ Text = wezterm.nerdfonts.mdi_arrow_down_box },
		},
		["curl"] = {
			{ Foreground = { Color = colors.yellow } },
			{ Text = wezterm.nerdfonts.mdi_flattr },
		},
		["gh"] = {
			{ Foreground = { Color = colors.mauve } },
			{ Text = wezterm.nerdfonts.dev_github_badge },
		},
	}

	local process_name = string.gsub(tab.active_pane.foreground_process_name, "(.*[/\\])(.*)", "%2")

	if process_name == "" then
		process_name = "zsh"
	end

	return wezterm.format(
		process_icons[process_name]
			or { { Foreground = { Color = colors.sky } }, { Text = string.format("[%s]", process_name) } }
	)
end

local function get_current_working_dir(tab)
	local current_dir = tab.active_pane.current_working_dir
	local HOME_DIR = string.format("file://%s", os.getenv("HOME"))

	return current_dir == HOME_DIR and "  ~"
		or string.format("  %s", string.gsub(current_dir, "(.*[/\\])(.*)", "%2"))
end

wezterm.on("format-tab-title", function(tab)
	return wezterm.format({
		{ Attribute = { Intensity = "Half" } },
		{ Text = string.format(" %s  ", tab.tab_index + 1) },
		"ResetAttributes",
		{ Text = get_process(tab) },
		{ Text = " " },
		{ Text = get_current_working_dir(tab) },
		{ Foreground = { Color = colors.base } },
		{ Text = "  ▕" },
	})
end)

wezterm.on("update-right-status", function(window)
	window:set_right_status(wezterm.format({
		{ Attribute = { Intensity = "Bold" } },
		{ Text = wezterm.strftime(" %A, %d %B %Y %I:%M %p ") },
	}))
end)

-- wezterm.font("FiraCode NF")

return {
	font = wezterm.font_with_fallback({
         "FiraCode NF"
	--    "Victor Mono",
	--    "Liga SFMono Nerd Font",
	--    "Apple Color Emoji",
	}),
	font_size = 14.0,
	--[[ max_fps = 60, ]]
	--[[ enable_wayland = false, ]]
	pane_focus_follows_mouse = false,
	warn_about_missing_glyphs = false,
	show_update_window = false,
	check_for_updates = false,
	line_height = 1.0,
	--[[ window_decorations = "RESIZE", ]]
	window_close_confirmation = "NeverPrompt",
	audible_bell = "Disabled",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	initial_cols = 232,
	initial_rows = 54,
	inactive_pane_hsb = {
		saturation = 1.0,
		brightness = 0.85,
	},
	enable_scroll_bar = true,
	tab_bar_at_bottom = false,
	use_fancy_tab_bar = false,
	show_new_tab_button_in_tab_bar = false,
	window_background_opacity = 1.0,
	tab_max_width = 50,
	hide_tab_bar_if_only_one_tab = true,
	disable_default_key_bindings = false,
	--front_end = "WebGpu",
	-- colors = {
	-- 	split = colors.surface0,
	-- 	foreground = colors.text,
	-- 	background = colors.base,
	-- 	cursor_bg = colors.rosewater,
	-- 	cursor_border = colors.rosewater,
	-- 	cursor_fg = colors.base,
	-- 	selection_bg = colors.surface2,
	-- 	selection_fg = colors.text,
	-- 	visual_bell = colors.surface0,
	-- 	indexed = {
	-- 		[16] = colors.peach,
	-- 		[17] = colors.rosewater,
	-- 	},
	-- 	scrollbar_thumb = colors.surface2,
	-- 	compose_cursor = colors.flamingo,
	-- 	ansi = {
	-- 		colors.surface1,
	-- 		colors.red,
	-- 		colors.green,
	-- 		colors.yellow,
	-- 		colors.blue,
	-- 		colors.pink,
	-- 		colors.teal,
	-- 		colors.subtext0,
	-- 	},
	-- 	brights = {
	-- 		colors.subtext0,
	-- 		colors.red,
	-- 		colors.green,
	-- 		colors.yellow,
	-- 		colors.blue,
	-- 		colors.pink,
	-- 		colors.teal,
	-- 		colors.surface1,
	-- 	},
	-- 	tab_bar = {
	-- 		background = colors.crust,
	-- 		active_tab = {
	-- 			bg_color = "none",
	-- 			fg_color = colors.subtext1,
	-- 			intensity = "Bold",
	-- 			underline = "None",
	-- 			italic = false,
	-- 			strikethrough = false,
	-- 		},
	-- 		inactive_tab = {
	-- 			bg_color = colors.crust,
	-- 			fg_color = colors.surface2,
	-- 		},
	-- 		inactive_tab_hover = {
	-- 			bg_color = colors.mantle,
	-- 			fg_color = colors.subtext0,
	-- 		},
	-- 		new_tab = {
	-- 			bg_color = colors.crust,
	-- 			fg_color = colors.subtext0,
	-- 		},
	-- 		new_tab_hover = {
	-- 			bg_color = colors.crust,
	-- 			fg_color = colors.subtext0,
	-- 		},
	-- 	},
	-- },
	--[[ color_scheme = "Gruvbox dark, hard (base16)", ]]
	color_scheme = "Gruvbox light, hard (base16)",
	--[[ keys = utils.merge_lists({ ]]
	--[[ 	{ ]]
	--[[ 		mods = "ALT", ]]
	--[[ 		key = [[\]], ]]
	--[[ 		action = wezterm.action({ ]]
	--[[ 			SplitHorizontal = { domain = "CurrentPaneDomain" }, ]]
	--[[ 		}), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		mods = "CTRL", ]]
	--[[ 		key = [[d]], ]]
	--[[ 		action = wezterm.action({ ]]
	--[[ 			SplitHorizontal = { domain = "CurrentPaneDomain" }, ]]
	--[[ 		}), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		mods = "CTRL", ]]
	--[[ 		key = [[D]], ]]
	--[[ 		action = wezterm.action({ ]]
	--[[ 			SplitVertical = { domain = "CurrentPaneDomain" }, ]]
	--[[ 		}), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		mods = "ALT|SHIFT", ]]
	--[[ 		key = [[|]], ]]
	--[[ 		action = wezterm.action.SplitPane({ ]]
	--[[ 			top_level = true, ]]
	--[[ 			direction = "Right", ]]
	--[[ 			size = { Percent = 50 }, ]]
	--[[ 		}), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		mods = "ALT", ]]
	--[[ 		key = [[-]], ]]
	--[[ 		action = wezterm.action({ ]]
	--[[ 			SplitVertical = { domain = "CurrentPaneDomain" }, ]]
	--[[ 		}), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		mods = "ALT|SHIFT", ]]
	--[[ 		key = [[_]], ]]
	--[[ 		action = wezterm.action.SplitPane({ ]]
	--[[ 			top_level = true, ]]
	--[[ 			direction = "Down", ]]
	--[[ 			size = { Percent = 50 }, ]]
	--[[ 		}), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		key = "t", ]]
	--[[ 		mods = "CTRL", ]]
	--[[ 		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		key = "n", ]]
	--[[ 		mods = "ALT", ]]
	--[[ 		action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }), ]]
	--[[ 	}, ]]
	--[[ 	{ ]]
	--[[ 		key = "Q", ]]
	--[[ 		mods = "ALT", ]]
	--[[ 		action = wezterm.action({ CloseCurrentTab = { confirm = false } }), ]]
	--[[ 	}, ]]
	--[[ 	{ key = "q", mods = "ALT", action = wezterm.action.CloseCurrentPane({ confirm = false }) }, ]]
	--[[ 	{ key = "z", mods = "ALT", action = wezterm.action.TogglePaneZoomState }, ]]
	--[[ 	{ key = "F11", mods = "", action = wezterm.action.ToggleFullScreen }, ]]
	--[[ 	{ key = "h", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Left", 1 }) }, ]]
	--[[ 	{ key = "j", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Down", 1 }) }, ]]
	--[[ 	{ key = "k", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Up", 1 }) }, ]]
	--[[ 	{ key = "l", mods = "ALT|SHIFT", action = wezterm.action.AdjustPaneSize({ "Right", 1 }) }, ]]
	--[[]]
	--[[ 	{ key = "h", mods = "ALT", action = wezterm.action.EmitEvent("ActivatePaneDirection-left") }, ]]
	--[[ 	{ key = "j", mods = "ALT", action = wezterm.action.EmitEvent("ActivatePaneDirection-down") }, ]]
	--[[ 	{ key = "k", mods = "ALT", action = wezterm.action.EmitEvent("ActivatePaneDirection-up") }, ]]
	--[[ 	{ key = "l", mods = "ALT", action = wezterm.action.EmitEvent("ActivatePaneDirection-right") }, ]]
	--[[]]
	--[[ 	{ key = "[", mods = "ALT", action = wezterm.action({ ActivateTabRelative = -1 }) }, ]]
	--[[ 	{ key = "]", mods = "ALT", action = wezterm.action({ ActivateTabRelative = 1 }) }, ]]
	--[[ 	{ key = "{", mods = "SHIFT|ALT", action = wezterm.action.MoveTabRelative(-1) }, ]]
	--[[ 	{ key = "}", mods = "SHIFT|ALT", action = wezterm.action.MoveTabRelative(1) }, ]]
	--[[ 	{ key = "v", mods = "ALT", action = wezterm.action.ActivateCopyMode }, ]]
	--[[ 	{ key = "c", mods = "CTRL|SHIFT", action = wezterm.action({ CopyTo = "Clipboard" }) }, ]]
	--[[ 	{ key = "v", mods = "CTRL|SHIFT", action = wezterm.action({ PasteFrom = "Clipboard" }) }, ]]
	--[[ 	{ key = "=", mods = "CTRL", action = wezterm.action.IncreaseFontSize }, ]]
	--[[ 	{ key = "-", mods = "CTRL", action = wezterm.action.DecreaseFontSize }, ]]
	--[[ 	{ key = "1", mods = "ALT", action = wezterm.action({ ActivateTab = 0 }) }, ]]
	--[[ 	{ key = "2", mods = "ALT", action = wezterm.action({ ActivateTab = 1 }) }, ]]
	--[[ 	{ key = "3", mods = "ALT", action = wezterm.action({ ActivateTab = 2 }) }, ]]
	--[[ 	{ key = "4", mods = "ALT", action = wezterm.action({ ActivateTab = 3 }) }, ]]
	--[[ 	{ key = "5", mods = "ALT", action = wezterm.action({ ActivateTab = 4 }) }, ]]
	--[[ 	{ key = "6", mods = "ALT", action = wezterm.action({ ActivateTab = 5 }) }, ]]
	--[[ 	{ key = "7", mods = "ALT", action = wezterm.action({ ActivateTab = 6 }) }, ]]
	--[[ 	{ key = "8", mods = "ALT", action = wezterm.action({ ActivateTab = 7 }) }, ]]
	--[[ 	{ key = "9", mods = "ALT", action = wezterm.action({ ActivateTab = 8 }) }, ]]
	--[[ }, navigate), ]]
  keys = navigate,
	hyperlink_rules = {
		{
			regex = "\\b\\w+://[\\w.-]+:[0-9]{2,15}\\S*\\b",
			format = "$0",
		},
		{
			regex = "\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},
		{
			regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
			format = "mailto:$0",
		},
		{
			regex = [[\bfile://\S*\b]],
			format = "$0",
		},
		{
			regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
			format = "$0",
		},
		{
			regex = [[\b[tT](\d+)\b]],
			format = "https://example.com/tasks/?t=$1",
		},
	},
	-- dfadsfasdf
	-- dsafadsfasdf
	-- adsfasdfasdf
	-- afadsfsdf
	unix_domains = {
		{
			name = "wsl",
			serve_command = { "wsl", "wezterm-mux-server", "--daemonize" },
		},
	},
	-- default_gui_startup_args = { 'connect', 'wsl' },
}
