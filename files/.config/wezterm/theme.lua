local wezterm = require("wezterm")

local M = {}

-- Dark themes
CUSTOM_NIGHT = wezterm.color.load_base16_scheme(WEZTERM_CONFIG .. "/themes/horizon-dark.yml")
-- CUSTOM_NIGHT = wezterm.color.get_builtin_schemes()["Gruvbox dark, hard (base16)"]
CUSTOM_NIGHT = wezterm.color.get_builtin_schemes()["3024 (base16)"]
CUSTOM_NIGHT = wezterm.color.get_builtin_schemes()["Tomorrow Night"]

-- Light themes
-- CUSTOM_DAY = wezterm.color.get_builtin_schemes()["Yousai (terminal.sexy)"]
-- CUSTOM_DAY = wezterm.color.get_builtin_schemes()["Gruvbox Light"]
CUSTOM_DAY = wezterm.color.get_builtin_schemes()["Horizon Bright (Gogh)"]
--[[ local custom_day = wezterm.color.get_builtin_schemes()["Gruvbox (Gogh)"] ]]
--[[ local custom_day = wezterm.color.get_builtin_schemes()['Belafonte Day'] ]]
--[[ local custom_day = wezterm.color.get_builtin_schemes()["Everforest Light (Gogh)"] ]]

-- for k, v in pairs(CUSTOM_DAY) do
-- 	wezterm.log_info(k, v)
-- end

CUSTOM_DAY.tab_bar = {
    background = "#bbc2cf",
    active_tab = {
        bg_color = CUSTOM_DAY.background,
        fg_color = CUSTOM_DAY.foreground,
        intensity = "Bold",
    },
    inactive_tab = {
        bg_color = "#bbc2cf",
        fg_color = CUSTOM_DAY.foreground,
    },
    inactive_tab_hover = {
        bg_color = "#bbc2cf",
        fg_color = CUSTOM_DAY.foreground,
    },
}

CUSTOM_NIGHT.tab_bar = {
    background = "#16181C",
    active_tab = {
        bg_color = CUSTOM_NIGHT.background,
        fg_color = CUSTOM_NIGHT.foreground,
        intensity = "Bold",
    },
    inactive_tab = {
        bg_color = "#16181C",
        fg_color = CUSTOM_NIGHT.foreground,
    },
    inactive_tab_hover = {
        bg_color = "#16181C",
        fg_color = CUSTOM_NIGHT.foreground,
    },
}

function M.scheme_for_appearance(appearance)
    if appearance:find("Dark") then
        -- os.remove("~/.daybird")
        return "CustomNight"
    else
        -- file = io.open("~/.daybird", "w")
        -- file:write("light")
        -- file:close()
        return "CustomDay"
    end
end

return M
