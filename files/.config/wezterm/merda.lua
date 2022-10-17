local wezterm = require 'wezterm';
--
--



local LEFT_ARROW = utf8.char(0xff0b3)
-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = utf8.char(0xe0b0)

local COL_BG = "#282a36"
local COL_BG_ALT = "#6272a4"
local COL_FG = "#f8f8f2"
local COL_FG_ALT = "#bd93f9"
local COL_ACCENT = "#ff79c6"

--
-- -- wezterm.on("update-right-status", function(window, pane)
-- --   -- Each element holds the text for a cell in a "powerline" style << fade
-- --   local cells = {};
-- --
-- --   -- Figure out the cwd and host of the current pane.
-- --   -- This will pick up the hostname for the remote host if your
-- --   -- shell is using OSC 7 on the remote host.
-- --   local cwd_uri = pane:get_current_working_dir()
-- --   if cwd_uri then
-- --     cwd_uri = cwd_uri:sub(8);
-- --     local slash = cwd_uri:find("/")
-- --     local cwd = ""
-- --     local hostname = ""
-- --     if slash then
-- --       hostname = cwd_uri:sub(1, slash-1)
-- --       -- Remove the domain name portion of the hostname
-- --       local dot = hostname:find("[.]")
-- --       if dot then
-- --         hostname = hostname:sub(1, dot-1)
-- --       end
-- --       -- and extract the cwd from the uri
-- --       cwd = cwd_uri:sub(slash)
-- --
-- --       table.insert(cells, cwd);
-- --       table.insert(cells, hostname);
-- --     end
-- --   end
-- --
-- --   -- I like my date/time in this style: "Wed Mar 3 08:14"
-- --   local date = wezterm.strftime("%a %b %-d %H:%M");
-- --   table.insert(cells, date);
-- --
-- --   -- An entry for each battery (typically 0 or 1 battery)
-- --   for _, b in ipairs(wezterm.battery_info()) do
-- --     table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
-- --   end
-- --
-- --   -- The powerline < symbol
-- --   local LEFT_ARROW = utf8.char(0xe0b3);
-- --   -- The filled in variant of the < symbol
-- --   local SOLID_LEFT_ARROW = utf8.char(0xe0b2)
-- --
-- --   -- Color palette for the backgrounds of each cell
-- --   local colors = {
-- --     "#3c1361",
-- --     "#52307c",
-- --     "#663a82",
-- --     "#7c5295",
-- --     "#b491c8",
-- --   };
-- --
-- --   -- Foreground color for the text across the fade
-- --   local text_fg = "#c0c0c0";
-- --
-- --   -- The elements to be formatted
-- --   local elements = {};
-- --   -- How many cells have been formatted
-- --   local num_cells = 0;
-- --
-- --   -- Translate a cell into elements
-- --   function push(text, is_last)
-- --     local cell_no = num_cells + 1
-- --     table.insert(elements, {Foreground={Color=text_fg}})
-- --     table.insert(elements, {Background={Color=colors[cell_no]}})
-- --     table.insert(elements, {Text=" "..text.." "})
-- --     if not is_last then
-- --       table.insert(elements, {Foreground={Color=colors[cell_no+1]}})
-- --       table.insert(elements, {Text=SOLID_LEFT_ARROW})
-- --     end
-- --     num_cells = num_cells + 1
-- --   end
-- --
-- --   while #cells > 0 do
-- --     local cell = table.remove(cells, 1)
-- --     push(cell, #cells == 0)
-- --   end
-- --
-- --   window:set_right_status(wezterm.format(elements));
-- -- end);
--
-- return {
--   color_scheme = "Gruvbox Dark",
--   -- use_fancy_tab_bar = false,
--   window_background_opacity = 0.9,
--   tab_bar_style = {
--     active_tab_left = wezterm.format({
--       {Background={Color="#0b0022"}},
--       {Foreground={Color="#2b2042"}},
--       {Text=SOLID_LEFT_ARROW},
--     }),
--     active_tab_right = wezterm.format({
--       {Background={Color="#0b0022"}},
--       {Foreground={Color="#2b2042"}},
--       {Text=SOLID_RIGHT_ARROW},
--     }),
--     inactive_tab_left = wezterm.format({
--       {Background={Color="#0b0022"}},
--       {Foreground={Color="#1b1032"}},
--       {Text=SOLID_LEFT_ARROW},
--     }),
--     inactive_tab_right = wezterm.format({
--       {Background={Color="#0b0022"}},
--       {Foreground={Color="#1b1032"}},
--       {Text=SOLID_RIGHT_ARROW},
--     }),
--   },
-- }
-- 615cc95efad

-- wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
-- 	-- edge icon
-- 	local edge_background = COL_BG
-- 	-- inactive tab
-- 	local background = COL_BG_ALT
-- 	local foreground = COL_FG
--
-- 	if tab.is_active then
-- 		background = COL_FG_ALT
-- 		foreground = COL_BG
-- 	elseif hover then
-- 		background = COL_ACCENT
-- 		foreground = COL_FG
-- 	end
--
-- 	local edge_foreground = background
-- 	clean_title = strip_home_name(tab.active_pane.title)
--
-- 	return {
-- 		{ Background = { Color = edge_background } },
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = SOLID_LEFT_ARROW },
-- 		{ Background = { Color = background } },
-- 		{ Foreground = { Color = foreground } },
-- 		{ Text = clean_title },
-- 		{ Background = { Color = edge_background } },
-- 		{ Foreground = { Color = edge_foreground } },
-- 		{ Text = SOLID_RIGHT_ARROW },
-- 	}
-- end)
--
-- return {
--     window_padding = {
--     left = 0,
--     right = 0,
--     top = 0,
--     bottom = 0,
--   },
--   font_size = 14.0,
--     font = wezterm.font_with_fallback({
--     "Victor Mono",
--     "DengXian",
--   }),
--   color_scheme = "Gruvbox Dark",
--   use_fancy_tab_bar = false,
--   colors = {
--     tab_bar = {
--       -- The color of the strip that goes along the top of the window
--       -- (does not apply when fancy tab bar is in use)
--       background = "#fb0022",
--
--       -- The active tab is the one that has focus in the window
--       active_tab = {
--         -- The color of the background area for the tab
--         bg_color = "#2b2042",
--         -- The color of the text for the tab
--         fg_color = "#c0c0c0",
--
--         -- Specify whether you want "Half", "Normal" or "Bold" intensity for the
--         -- label shown for this tab.
--         -- The default is "Normal"
--         intensity = "Normal",
--
--         -- Specify whether you want "None", "Single" or "Double" underline for
--         -- label shown for this tab.
--         -- The default is "None"
--         underline = "None",
--
--         -- Specify whether you want the text to be italic (true) or not (false)
--         -- for this tab.  The default is false.
--         italic = false,
--
--         -- Specify whether you want the text to be rendered with strikethrough (true)
--         -- or not for this tab.  The default is false.
--         strikethrough = false,
--       },
--
--       -- Inactive tabs are the tabs that do not have focus
--       inactive_tab = {
--         bg_color = "#1b1032",
--         fg_color = "#808080",
--
--         -- The same options that were listed under the `active_tab` section above
--         -- can also be used for `inactive_tab`.
--       },
--
--       -- You can configure some alternate styling when the mouse pointer
--       -- moves over inactive tabs
--       inactive_tab_hover = {
--         bg_color = "#3b3052",
--         fg_color = "#909090",
--         italic = true,
--
--         -- The same options that were listed under the `active_tab` section above
--         -- can also be used for `inactive_tab_hover`.
--       },
--
--       -- The new tab button that let you create new tabs
--       new_tab = {
--         bg_color = "#1b1032",
--         fg_color = "#808080",
--
--         -- The same options that were listed under the `active_tab` section above
--         -- can also be used for `new_tab`.
--       },
--
--       -- You can configure some alternate styling when the mouse pointer
--       -- moves over the new tab button
--       new_tab_hover = {
--         bg_color = "#3b3052",
--         fg_color = "#909090",
--         italic = true,
--
--         -- The same options that were listed under the `active_tab` section above
--         -- can also be used for `new_tab_hover`.
--       }
--     }
--   },
-- }



local wezterm = require("wezterm")

local LEFT_ARROW = utf8.char(0xff0b3)
-- The filled in variant of the < symbol
local SOLID_LEFT_ARROW = "" -- utf8.char(0xe0b2)
-- The filled in variant of the > symbol
local SOLID_RIGHT_ARROW = ""  --utf8.char(0xe0b0)

local COL_BG = "#4d2021"
local COL_BG_ALT = "#6272a4"
local COL_FG = "#f8f8f2"
local COL_FG_ALT = "#bd93f9"
local COL_ACCENT = "#ff79c6"

function strip_home_name(text)
	local username = os.getenv("USER")
	clean_text = text:gsub("/home/" .. username, "~")
	return clean_text
end

wezterm.on("format-window-title", function(tab, pane, tabs, panes, config)
	local zoomed = ""
	if tab.active_pane.is_zoomed then
		zoomed = "[Z] "
	end

	local index = ""
	if #tabs > 1 then
		index = string.format("[%d/%d] ", tab.tab_index + 1, #tabs)
	end

	local clean_title = strip_home_name(tab.active_pane.title)
	return zoomed .. index .. clean_title
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- edge icon
	local edge_background = COL_BG
	-- inactive tab
	local background = COL_BG_ALT
	local foreground = COL_FG

	if tab.is_active then
		background = COL_FG_ALT
		foreground = COL_BG
	elseif hover then
		background = COL_ACCENT
		foreground = COL_FG
	end

	local edge_foreground = background
	clean_title = strip_home_name(tab.active_pane.title)

	return {
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = " " .. SOLID_LEFT_ARROW },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = clean_title },
		{ Background = { Color = edge_background } },
		{ Foreground = { Color = edge_foreground } },
		{ Text = SOLID_RIGHT_ARROW },
	}
end)

return {
	-- color_scheme = "ayu_dark",
	default_cursor_style = "BlinkingBar",
	font_size = 17.0,
	font = wezterm.font_with_fallback({
        "Fira Code",
		"Victor Mono",
		"Font Awesome 6 Free Regular",
		"Font Awesome 6 Free Solid",
		"Font Awesome 6 Free Brands Regular",
		"Font Awesome 5 Free Regular",
		"Font Awesome 5 Free Solid",
		"Font Awesome 5 Brands Regular",
	}),
	warn_about_missing_glyphs = false,
	check_for_updates = false,
	-- Tab Bar Options
	use_fancy_tab_bar = false,
	enable_tab_bar = true,
	hide_tab_bar_if_only_one_tab = true,
	show_tab_index_in_tab_bar = false,
	-- tab_max_width = 25,
	-- Padding
	window_padding = { left = 10, right = 0, top = 0, bottom = 0 },
	-- Misc
	adjust_window_size_when_changing_font_size = true,
	-- -- Theme
  color_scheme = "Gruvbox Dark",
	-- colors = {
	-- 	background = COL_BG,
	-- 	foreground = COL_FG,
	-- 	selection_bg = COL_ACCENT,
	-- 	tab_bar = {
	-- 		background = COL_BG,
	-- 		new_tab = {
	-- 			bg_color = COL_BG,
	-- 			fg_color = COL_FG,
	-- 		},
	-- 	},
	-- },
	inactive_pane_hsb = {
		saturation = 1.0,
		brightness = 0.8,
	},
	hyperlink_rules = {
		-- Linkify things that look like URLs
		-- This is actually the default if you don't specify any hyperlink_rules
		{
			regex = "\\b\\w+://(?:[\\w.-]+)\\.[a-z]{2,15}\\S*\\b",
			format = "$0",
		},

		-- match the URL with a PORT
		-- such 'http://localhost:3000/index.html'
		{
			regex = "\\b\\w+://(?:[\\w.-]+):\\d+\\S*\\b",
			format = "$0",
		},

		-- linkify email addresses
		{
			regex = "\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b",
			format = "mailto:$0",
		},

		-- file:// URI
		{
			regex = "\\bfile://\\S*\\b",
			format = "$0",
		},
	},
	-- keybindings
	-- disable_default_key_bindings = true,
	quick_select_alphabet = "colemak",
	leader = { key = "n", mods = "CMD", timeout_milliseconds = 2000 },
	keys = {
		{ key = "r", mods = "LEADER", action = "ReloadConfiguration" },
		--
		{
			key = "h",
			mods = "LEADER",
			action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }),
		},
    -- splits
		{ key = "D", mods = "CMD", action = wezterm.action({ SplitVertical = { domain = "CurrentPaneDomain" } }) },
		{ key = "d", mods = "CMD", action = wezterm.action({ SplitHorizontal = { domain = "CurrentPaneDomain" } }) },
    -- close
		{ key = "t", mods = "CMD", action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }) },
		{ key = "2", mods = "ALT", action = "ResetFontSize" },
    -- dfdfdfdfd
		{ key = "X", mods = "LEADER", action = wezterm.action({ CloseCurrentTab = { confirm = true } }) },
		{ key = "x", mods = "LEADER", action = wezterm.action({ CloseCurrentPane = { confirm = true } }) },
		{ key = "z", mods = "CMD", action = "TogglePaneZoomState" },
		{ key = "f", mods = "LEADER", action = "QuickSelect" },
		{ key = "w", mods = "LEADER", action = "ActivateCopyMode" },
		{ key = "s", mods = "LEADER", action = wezterm.action({ Search = { CaseInSensitiveString = "" } }) },
		{ key = "PageUp", mods = "NONE", action = wezterm.action({ ScrollByPage = -1 }) },
		{ key = "PageDown", mods = "NONE", action = wezterm.action({ ScrollByPage = 1 }) },
		--
		{ key = "Tab", mods = "LEADER", action = wezterm.action({ ActivateTabRelative = 1 }) },
		{ key = "Tab", mods = "LEADER|SHIFT", action = wezterm.action({ ActivateTabRelative = -1 }) },
		-- movements
		{ key = "h", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Left" }) },
		{ key = "j", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Down" }) },
		{ key = "k", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Up" }) },
		{ key = "l", mods = "CTRL", action = wezterm.action({ ActivatePaneDirection = "Right" }) },
		{ key = "Enter", mods = "LEADER", action = wezterm.action({ ActivatePaneDirection = "Next" }) },
		{ key = "Enter", mods = "LEADER|SHIFT", action = wezterm.action({ ActivatePaneDirection = "Prev" }) },
		--
		-- 5 and 8 map to my arrow keys
		{ key = "2", mods = "ALT", action = "ResetFontSize" },
		{ key = "5", mods = "ALT", action = "DecreaseFontSize" },
		{ key = "8", mods = "ALT", action = "IncreaseFontSize" },
		--
		{ key = "w", mods = "ALT", action = wezterm.action({ CopyTo = "Clipboard" }) },
		{ key = "y", mods = "CTRL", action = wezterm.action({ PasteFrom = "Clipboard" }) },
	},
  ssh_domains = {
    {
      -- This name identifies the domain
      name = "test",
      -- The hostname or address to connect to. Will be used to match settings
      -- from your ssh config file
      remote_address = "master",
      -- The username to use on the remote host
      username = "marcos.romero",
    }
  },
    window_background_gradient = {
    -- Can be "Vertical" or "Horizontal".  Specifies the direction
    -- in which the color gradient varies.  The default is "Horizontal",
    -- with the gradient going from left-to-right.
    -- Linear and Radial gradients are also supported; see the other
    -- examples below
    orientation = "Vertical",

    -- Specifies the set of colors that are interpolated in the gradient.
    -- Accepts CSS style color specs, from named colors, through rgb
    -- strings and more
    colors = {
      "#1d2021",
      -- "#302b63",
      "#1d2021"
    },

    -- Instead of specifying `colors`, you can use one of a number of
    -- predefined, preset gradients.
    -- A list of presets is shown in a section below.
    -- preset = "Warm",

    -- Specifies the interpolation style to be used.
    -- "Linear", "Basis" and "CatmullRom" as supported.
    -- The default is "Linear".
    interpolation = "Linear",

    -- How the colors are blended in the gradient.
    -- "Rgb", "LinearRgb", "Hsv" and "Oklab" are supported.
    -- The default is "Rgb".
    blend = "Rgb",

    -- To avoid vertical color banding for horizontal gradients, the
    -- gradient position is randomly shifted by up to the `noise` value
    -- for each pixel.
    -- Smaller values, or 0, will make bands more prominent.
    -- The default value is 64 which gives decent looking results
    -- on a retina macbook pro display.
    -- noise = 64,

    -- By default, the gradient smoothly transitions between the colors.
    -- You can adjust the sharpness by specifying the segment_size and
    -- segment_smoothness parameters.
    -- segment_size configures how many segments are present.
    -- segment_smoothness is how hard the edge is; 0.0 is a hard edge,
    -- 1.0 is a soft edge.

    -- segment_size = 11,
    -- segment_smoothness = 0.0,
  },
}
