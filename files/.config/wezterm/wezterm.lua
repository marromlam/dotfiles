local wezterm = require("wezterm")
local navigate = require("navigate")
local navigate = {}

local mux = wezterm.mux
local utils = require("utils")
local my_keys = require("keys")


-- function to change the theme attenting to if the ~/.daybird file exists
-- if it does, then it's day time, otherwise it's night time

local is_windows = package.config:sub(1,1) == "\\" and true or false

local function get_theme()
    if is_windows then
        local day = utils.file_exists("C:\\Users\\marcos.romero\\.daybird")
    else
        local day = utils.file_exists("~/.daybird")
    end
    print(day)
    if day then
	    return "Gruvbox light, light (base16)"
    else
	    return "Gruvbox dark, light (base16)"
    end
end


if is_windows then
  default_prog = "wsl.exe"
else
  default_prog = nil
end

--[[ wezterm.on("gui-startup", function() ]]
--[[     local tab, pane, window = mux.spawn_window {} ]]
--[[     window:gui_window():maximize() ]]
--[[ end) ]]


-- JUST TO RECYCLE --    colors = {        split = colors.surface0,
-- JUST TO RECYCLE --        foreground = colors.text,
-- JUST TO RECYCLE --        background = colors.base,
-- JUST TO RECYCLE --        cursor_bg = colors.rosewater,
-- JUST TO RECYCLE --        cursor_border = colors.rosewater,
-- JUST TO RECYCLE --        cursor_fg = colors.base,
-- JUST TO RECYCLE --        selection_bg = colors.surface2,
-- JUST TO RECYCLE --        selection_fg = colors.text,
-- JUST TO RECYCLE --        visual_bell = colors.surface0,
-- JUST TO RECYCLE --        indexed = {
-- JUST TO RECYCLE --            [16] = colors.peach,
-- JUST TO RECYCLE --            [17] = colors.rosewater,
-- JUST TO RECYCLE --        },
-- JUST TO RECYCLE --        scrollbar_thumb = colors.surface2,
-- JUST TO RECYCLE --        compose_cursor = colors.flamingo,
-- JUST TO RECYCLE --        ansi = {
-- JUST TO RECYCLE --            colors.surface1,
-- JUST TO RECYCLE --            colors.red,
-- JUST TO RECYCLE --            colors.green,
-- JUST TO RECYCLE --            colors.yellow,
-- JUST TO RECYCLE --            colors.blue,
-- JUST TO RECYCLE --            colors.pink,
-- JUST TO RECYCLE --            colors.teal,
-- JUST TO RECYCLE --            colors.subtext0,
-- JUST TO RECYCLE --        },
-- JUST TO RECYCLE --        brights = {
-- JUST TO RECYCLE --            colors.subtext0,
-- JUST TO RECYCLE --            colors.red,
-- JUST TO RECYCLE --            colors.green,
-- JUST TO RECYCLE --            colors.yellow,
-- JUST TO RECYCLE --            colors.blue,
-- JUST TO RECYCLE --            colors.pink,
-- JUST TO RECYCLE --            colors.teal,
-- JUST TO RECYCLE --            colors.surface1,
-- JUST TO RECYCLE --        },
-- JUST TO RECYCLE --        tab_bar = {
-- JUST TO RECYCLE --            background = colors.crust,
-- JUST TO RECYCLE --            active_tab = {
-- JUST TO RECYCLE --                bg_color = "none",
-- JUST TO RECYCLE --                fg_color = colors.subtext1,
-- JUST TO RECYCLE --                intensity = "Bold",
-- JUST TO RECYCLE --                underline = "None",
-- JUST TO RECYCLE --                italic = false,
-- JUST TO RECYCLE --                strikethrough = false,
-- JUST TO RECYCLE --            },
-- JUST TO RECYCLE --            inactive_tab = {
-- JUST TO RECYCLE --                bg_color = colors.crust,
-- JUST TO RECYCLE --                fg_color = colors.surface2,
-- JUST TO RECYCLE --            },
-- JUST TO RECYCLE --            inactive_tab_hover = {
-- JUST TO RECYCLE --                bg_color = colors.mantle,
-- JUST TO RECYCLE --                fg_color = colors.subtext0,
-- JUST TO RECYCLE --            },
-- JUST TO RECYCLE --            new_tab = {
-- JUST TO RECYCLE --                bg_color = colors.crust,
-- JUST TO RECYCLE --                fg_color = colors.subtext0,
-- JUST TO RECYCLE --            },
-- JUST TO RECYCLE --            new_tab_hover = {
-- JUST TO RECYCLE --                bg_color = colors.crust,
-- JUST TO RECYCLE --                fg_color = colors.subtext0,
-- JUST TO RECYCLE --            },
-- JUST TO RECYCLE --        },
-- JUST TO RECYCLE --    },



kkk

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
	--[[ base = "#24273A", ]]
  --
	bg = "#e4e7aA",
	bg_alt = "#f3f3f3",
  --
	fg = "#14171A",
	fg_alt = "#24272A",
  --
	mantle = "#1E2030",
	--[[ crust = "#181926", ]]
	crust = "#f81926",
}


local current_colors = wezterm.color.load_base16_scheme("C:/Users/marcos.romero/.config/wezterm/themes/horizon-light.yml")

current_colors.tab_bar = {
	    		background = colors.bg_alt,
	    		active_tab = {
	    			bg_color = current_colors.background,
	    			fg_color = current_colors.foreground,
	    			intensity = "Bold",
	    		},
	    		inactive_tab = {
	    			bg_color = colors.bg_alt,
	    			fg_color = colors.fg_alt,
	    		},
	    		inactive_tab_hover = {
	    			bg_color = colors.bg_alt,
	    			fg_color = colors.fg_alt,
	    		},
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
		-- { Attribute = { Intensity = "Half" } },
		{ Text = "   " },
		{ Text = string.format(" %s  ", tab.tab_index + 1) },
		"ResetAttributes",
		-- { Text = get_process(tab) },
		{ Text = "   " },
		-- { Text = get_current_working_dir(tab) },
		-- { Foreground = { Color = colors.base } },
		-- { Text = "  ▕" },
	})
end)

wezterm.on("update-right-status", function(window)
	window:set_right_status(wezterm.format({
		-- { Attribute = { Intensity = "Bold" } },
		--[[ { Text = wezterm.strftime(" %A, %d %B %Y %I:%M %p ") }, ]]
		{ Text = get_current_working_dir(tab) },
	}))
end)

-- wezterm.font("FiraCode NF")

return {
  default_prog = default_prog,
	font = wezterm.font_with_fallback({
    --[[ "FiraCode NF", ]]
    --[[ "FiraCode Nerd Font", ]]
    --[[ "Iosevka", ]]
    --[[ { family = 'JetBrains Mono', weight = 'Medium' }, ]]
    --[[ {family="Iosevka Term SS05", weight = "Regular" }, ]]
    "Hack Nerd Font",
    -- "DejaVu Sans Mono",
    -- "ComicMono NF",
	  -- "Victor Mono",
	  -- "Liga SFMono Nerd Font",
	  -- "Apple Color Emoji",
	}),
	font_size = 13.5,
	line_height = 0.93,
  cell_width = 1.01,
	--[[ max_fps = 60, ]]
	--[[ enable_wayland = false, ]]
	pane_focus_follows_mouse = false,
	warn_about_missing_glyphs = false,
	show_update_window = false,
	check_for_updates = false,
	-- window_decorations = "RESIZE",
	window_close_confirmation = "NeverPrompt",
	audible_bell = "Disabled",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
	initial_cols = 80,
	initial_rows = 40,
	inactive_pane_hsb = {
		saturation = 1.0,
		brightness = 0.85,
	},
	enable_scroll_bar = false,
	tab_bar_at_bottom = false,
	use_fancy_tab_bar = false,
	show_new_tab_button_in_tab_bar = false,
	window_background_opacity = 1.0,
	tab_max_width = 50,
	hide_tab_bar_if_only_one_tab = true,
	disable_default_key_bindings = false,
	--front_end = "WebGpu",
  --
  -- Set color scheme {{{
	-- color_scheme = "Gruvbox dark, hard (base16)",
	-- color_scheme = "Gruvbox light, hard (base16)",
  colors = current_colors,
  -- }}}
  -- keys {{{
  keys = utils.merge_lists(my_keys, navigate),
  -- }}}
  --
  -- hyperlinks {{{
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
	-- }}}
	--
	-- Domains {{{
	unix_domains = {
		{
			name = "wsl",
			serve_command = { "wsl", "wezterm-mux-server", "--daemonize" },
		},
	},
	-- default_gui_startup_args = { 'connect', 'wsl' },
  -- }}}
}

-- vim: fdm=marker
