local wezterm = require('wezterm')
local navigate = require('navigate')
local navigate = {}

-- which os we use
local is_windows = package.config:sub(1, 1) == '\\' and true or false

-- first we want to know where the config is placed
if is_windows then
    DEFAULT_PROG = { 'wsl.exe' }
    WEZTERM_CONFIG = 'C:/Users/marcos.romero/.config/wezterm'
    LEADER_KEY = 'CTRL|ALT'
else
    DEFAULT_PROG = nil
    WEZTERM_CONFIG = os.getenv('HOME') .. '/.config/wezterm'
    LEADER_KEY = 'CMD'
end

local utils = require('utils')
local my_keys = require('keys')
local theme = require('theme')

local function is_inside_vim(pane)
    local tty = pane:get_tty_name()
    if tty == nil then return false end

    local success, stdout, stderr = wezterm.run_child_process({
        'sh',
        '-c',
        'ps -o state= -o comm= -t'
            .. wezterm.shell_quote_arg(tty)
            .. ' | '
            .. "grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|tmux)(diff)?$'",
    })
    wezterm.log_info('is_inside_vim: ' .. tostring(success))

    return success
end

local function is_outside_vim(pane) return not is_inside_vim(pane) end

local function bind_if(cond, key, mods, action)
    local function callback(win, pane)
        if cond(pane) then
            win:perform_action(action, pane)
        else
            win:perform_action(
                wezterm.action.SendKey({ key = key, mods = mods }),
                pane
            )
        end
    end

    return { key = key, mods = mods, action = wezterm.action_callback(callback) }
end

navigate = {
    bind_if(
        is_outside_vim,
        'h',
        'CTRL',
        wezterm.action.ActivatePaneDirection('Left')
    ),
    bind_if(
        is_outside_vim,
        'l',
        'CTRL',
        wezterm.action.ActivatePaneDirection('Right')
    ),
    bind_if(
        is_outside_vim,
        'j',
        'CTRL',
        wezterm.action.ActivatePaneDirection('Down')
    ),
    bind_if(
        is_outside_vim,
        'k',
        'CTRL',
        wezterm.action.ActivatePaneDirection('Up')
    ),
}

local colors = {
    rosewater = '#F4DBD6',
    flamingo = '#F0C6C6',
    pink = '#F5BDE6',
    mauve = '#C6A0F6',
    red = '#ED8796',
    maroon = '#EE99A0',
    peach = '#F5A97F',
    yellow = '#EED49F',
    green = '#A6DA95',
    teal = '#8BD5CA',
    sky = '#91D7E3',
    sapphire = '#7DC4E4',
    blue = '#8AADF4',
    lavender = '#B7BDF8',

    text = '#CAD3F5',
    subtext1 = '#B8C0E0',
    subtext0 = '#A5ADCB',

    overlay2 = '#939AB7',
    overlay1 = '#8087A2',
    overlay0 = '#6E738D',

    surface2 = '#5B6078',
    surface1 = '#494D64',
    surface0 = '#363A4F',

    base = '#24273A',
    --[[ base = "#24273A", ]]
    --
    bg = '#e4e7aA',
    bg_alt = '#f3f3f3',
    --
    fg = '#14171A',
    fg_alt = '#24272A',
    --
    mantle = '#1E2030',
    --[[ crust = "#181926", ]]
    crust = '#f81926',
}

-- actions {{{

-- change theme when OS dark/light theme is swiched
wezterm.on('window-config-reloaded', function(window, pane)
    local overrides = window:get_config_overrides() or {}
    local appearance = window:get_appearance()
    local scheme = theme.scheme_for_appearance(appearance)
    if overrides.color_scheme ~= scheme then
        overrides.color_scheme = scheme
        window:set_config_overrides(overrides)
    end
end)

-- maximize on startup
-- wezterm.on("gui-startup", function()
--     local tab, pane, window = mux.spawn_window {}
--     window:gui_window():maximize()
-- end)

wezterm.on('format-tab-title', function(tab)
    return wezterm.format({
        -- { Attribute = { Intensity = "Half" } },
        { Text = '    ' },
        { Text = string.format(' %s  ', tab.tab_index + 1) },
        'ResetAttributes',
        -- { Text = get_process(tab) },
        { Text = '   ' },
        -- { Text = get_current_working_dir(tab) },
        -- { Foreground = { Color = colors.base } },
        -- { Text = "  ▕" },
    })
end)

-- wezterm.on("update-right-status", function(window)
--      window:set_right_status(wezterm.format({
--              -- { Attribute = { Intensity = "Bold" } },
--              --[[ { Text = wezterm.strftime(" %A, %d %B %Y %I:%M %p ") }, ]]
--              { Text = get_current_working_dir(tab) },
--      }))
-- end)

-- }}}

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

local function get_process(tab)
    local process_icons = {
        ['docker'] = {
            { Foreground = { Color = colors.blue } },
            { Text = wezterm.nerdfonts.linux_docker },
        },
        ['docker-compose'] = {
            { Foreground = { Color = colors.blue } },
            { Text = wezterm.nerdfonts.linux_docker },
        },
        ['nvim'] = {
            { Foreground = { Color = colors.green } },
            { Text = wezterm.nerdfonts.custom_vim },
        },
        ['vim'] = {
            { Foreground = { Color = colors.green } },
            { Text = wezterm.nerdfonts.dev_vim },
        },
        ['node'] = {
            { Foreground = { Color = colors.green } },
            { Text = wezterm.nerdfonts.mdi_hexagon },
        },
        ['zsh'] = {
            { Foreground = { Color = colors.peach } },
            { Text = wezterm.nerdfonts.dev_terminal },
        },
        ['cmd.exe'] = {
            { Foreground = { Color = colors.peach } },
            { Text = wezterm.nerdfonts.dev_terminal },
        },
        ['wslhost.exe'] = {
            { Foreground = { Color = colors.peach } },
            { Text = wezterm.nerdfonts.dev_terminal },
        },
        ['bash'] = {
            { Foreground = { Color = colors.subtext0 } },
            { Text = wezterm.nerdfonts.cod_terminal_bash },
        },
        ['htop'] = {
            { Foreground = { Color = colors.yellow } },
            { Text = wezterm.nerdfonts.mdi_chart_donut_variant },
        },
        ['cargo'] = {
            { Foreground = { Color = colors.peach } },
            { Text = wezterm.nerdfonts.dev_rust },
        },
        ['go'] = {
            { Foreground = { Color = colors.sapphire } },
            { Text = wezterm.nerdfonts.mdi_language_go },
        },
        ['lazydocker'] = {
            { Foreground = { Color = colors.blue } },
            { Text = wezterm.nerdfonts.linux_docker },
        },
        ['git'] = {
            { Foreground = { Color = colors.peach } },
            { Text = wezterm.nerdfonts.dev_git },
        },
        ['lazygit'] = {
            { Foreground = { Color = colors.peach } },
            { Text = wezterm.nerdfonts.dev_git },
        },
        ['lua'] = {
            { Foreground = { Color = colors.blue } },
            { Text = wezterm.nerdfonts.seti_lua },
        },
        ['wget'] = {
            { Foreground = { Color = colors.yellow } },
            { Text = wezterm.nerdfonts.mdi_arrow_down_box },
        },
        ['curl'] = {
            { Foreground = { Color = colors.yellow } },
            { Text = wezterm.nerdfonts.mdi_flattr },
        },
        ['gh'] = {
            { Foreground = { Color = colors.mauve } },
            { Text = wezterm.nerdfonts.dev_github_badge },
        },
    }

    local process_name = string.gsub(
        tab.active_pane.foreground_process_name,
        '(.*[/\\])(.*)',
        '%2'
    )

    if process_name == '' then process_name = 'zsh' end

    return wezterm.format(process_icons[process_name] or {
        { Foreground = { Color = colors.sky } },
        { Text = string.format('[%s]', process_name) },
    })
end

wezterm.log_info('Successfully loaded wezterm.lua. Returning config.')

return {
    default_prog = DEFAULT_PROG,
<<<<<<< Updated upstream
    font = wezterm.font_with_fallback({
        -- 'Cartograph CF',
        'Monaspace Neon',
        --     -- 'Monolisa',
        --     --[[ "FiraCode NF", ]]
        -- 'FiraCode Nerd Font',
        -- 'Hack Nerd Font', -- nerd fonts extracted from there
        --     -- 'Iosevka',
        --     --[[ { family = 'JetBrains Mono', weight = 'Medium' }, ]]
        --     --[[ {family="Iosevka Term SS05", weight = "Regular" }, ]]
        --     -- { family = "Hack Nerd Font", scale = 0.85 }, -- nerd fonts extracted from there
        --     -- { family = 'Fira Code Nerd Font',    scale = 0.55 }, -- nerd fonts extracted from there
        --     -- { family="Symbols Nerd Font Mono", scale=0.5}, -- nerd fonts extracted from there
        -- 'Victor Mono',
        { family = 'Symbols Nerd Font Mono', scale = 0.75 },
        --     -- "SF Pro",
        --     -- "DejaVu Sans Mono",
        --     -- "ComicMono NF",
        --     -- "Liga SFMono Nerd Font",
    }),
    font_rules = {
        --     -- Non-italic {{{
        --     {
        --         italic = false,
        --         intensity = 'Normal',
        --         font = wezterm.font('Monaspace Neon', { weight = 'Regular' }),
        --     },
        --     {
        --         italic = false,
        --         intensity = 'Normal',
        --         -- intensity = 'Half', -- Normal+Half: Documentation
        --         underline = 'Single',
        --         font = wezterm.font('Monaspace Xenon', { weight = 'Regular' }),
        --     },
        --     {
        --         italic = false,
        --         intensity = 'Bold',
        --         font = wezterm.font('Monaspace Neon', { weight = 'Black' }),
        --     },
        --     -- }}}
        -- Italic {{{
        {
            italic = true,
            intensity = 'Normal', -- Italic+Normal: normal italic text
            font = wezterm.font('Monaspace Radon', { weight = 'Regular' }),
        },
        {
            italic = true,
            intensity = 'Half', -- Italic+Half: Copilot
            font = wezterm.font('Monaspace Krypton', { weight = 'Black' }),
        },
        {
            italic = true,
            intensity = 'Bold', -- Italic+Bold: Documentation
            font = wezterm.font(
                'Monaspace Neon',
                { weight = 'Black', style = 'Italic' }
            ),
        },
        -- }}}
    },
||||||| Stash base
    font = wezterm.font_with_fallback({
        'Cartograph CF',
        --     -- 'Monolisa',
        --     --[[ "FiraCode NF", ]]
        'FiraCode Nerd Font',
        -- 'Hack Nerd Font', -- nerd fonts extracted from there
        --     -- 'Iosevka',
        --     --[[ { family = 'JetBrains Mono', weight = 'Medium' }, ]]
        --     --[[ {family="Iosevka Term SS05", weight = "Regular" }, ]]
        --     -- { family = "Hack Nerd Font", scale = 0.85 }, -- nerd fonts extracted from there
        --     -- { family = 'Fira Code Nerd Font',    scale = 0.55 }, -- nerd fonts extracted from there
        --     -- { family="Symbols Nerd Font Mono", scale=0.5}, -- nerd fonts extracted from there
        -- 'Victor Mono',
        -- { family = 'Symbols Nerd Font Mono', scale = 0.75 },
        --     -- "SF Pro",
        --     -- "DejaVu Sans Mono",
        --     -- "ComicMono NF",
        --     -- "Liga SFMono Nerd Font",
    }),
=======
    --     'Cartograph CF',
    -- font = wezterm.font_with_fallback({
    --     -- 'Monaspace Argon',
    --     --     -- 'Monolisa',
    --     --     --[[ "FiraCode NF", ]]
    --     'FiraCode Nerd Font',
    --     -- 'Hack Nerd Font', -- nerd fonts extracted from there
    --     --     -- 'Iosevka',
    --     --     --[[ { family = 'JetBrains Mono', weight = 'Medium' }, ]]
    --     --     --[[ {family="Iosevka Term SS05", weight = "Regular" }, ]]
    --     --     -- { family = "Hack Nerd Font", scale = 0.85 }, -- nerd fonts extracted from there
    --     --     -- { family = 'Fira Code Nerd Font',    scale = 0.55 }, -- nerd fonts extracted from there
    --     --     -- { family="Symbols Nerd Font Mono", scale=0.5}, -- nerd fonts extracted from there
    --     -- 'Victor Mono',
    --     -- { family = 'Symbols Nerd Font Mono', scale = 0.75 },
    --     --     -- "SF Pro",
    --     --     -- "DejaVu Sans Mono",
    --     --     -- "ComicMono NF",
    --     --     -- "Liga SFMono Nerd Font",
    -- }),
    -- harfbuzz_features = {
    --     'ss01',
    --     'ss02',
    --     'ss03',
    --     'ss04',
    --     'ss05',
    --     'ss06',
    --     'ss07',
    --     'ss08',
    --     'calt',
    --     'dlig',
    -- },
    -- font_rules = {
    --     {
    --         intensity = 'Bold',
    --         italic = true,
    --         font = wezterm.font({
    --             family = 'Monaspace Radon',
    --             weight = 'Bold',
    --             style = 'Italic',
    --         }),
    --     },
    --     {
    --         italic = true,
    --         intensity = 'Half',
    --         font = wezterm.font({
    --             family = 'Monaspace Radon',
    --             weight = 'DemiBold',
    --             style = 'Italic',
    --         }),
    --     },
    --     {
    --         italic = true,
    --         intensity = 'Normal',
    --         font = wezterm.font({
    --             family = 'Monaspace Radon',
    --             style = 'Italic',
    --         }),
    --     },
    -- },
>>>>>>> Stashed changes
    font_size = 17,
    -- line_height = 1.05,
    cell_width = 1.0,
    --[[ max_fps = 60, ]]
    --[[ enable_wayland = false, ]]
    pane_focus_follows_mouse = false,
    warn_about_missing_glyphs = false,
    enable_kitty_graphics = true,
    show_update_window = false,
    check_for_updates = false,
    -- window_decorations = "RESIZE",
    window_decorations = 'INTEGRATED_BUTTONS|RESIZE',
    -- integrated_title_button_style = 'MacOsNative',
    integrated_title_button_style = 'Windows',
    -- integrated_title_button_style = 'Gnome',
    integrated_title_button_alignment = 'Left',
    integrated_title_buttons = { 'Close', 'Maximize', 'Hide' },
    integrated_title_button_color = 'red',
    window_close_confirmation = 'NeverPrompt',
    audible_bell = 'Disabled',
    window_padding = { left = 0, right = 0, top = 0, bottom = 0 },
    initial_cols = 80,
    initial_rows = 40,
    -- inactive_pane_hsb = { saturation = 1.0, brightness = 0.85 },
    enable_scroll_bar = false,
    --[[ tab_bar_at_bottom = false, ]]
    use_fancy_tab_bar = false,
    show_new_tab_button_in_tab_bar = false,
    tab_max_width = 50,
    hide_tab_bar_if_only_one_tab = true,
    disable_default_key_bindings = true,
    --front_end = "WebGpu",

    -- Set color scheme {{{
    color_schemes = {
        ['CustomDay'] = CUSTOM_DAY,
        ['CustomNight'] = CUSTOM_NIGHT,
    },
<<<<<<< Updated upstream
    -- window_background_opacity = 0.8,
    window_background_opacity = 1,
||||||| Stash base
    window_background_opacity = 0.8,
=======
    window_background_opacity = 0.9,
>>>>>>> Stashed changes
    text_background_opacity = 0.8,
    macos_window_background_blur = 10,
    tab_bar_style = {
        window_hide = '  ',
        window_maximize = ' ',
        window_close = '  ',

        window_close_hover = '  ',
        window_hide_hover = '  ',
        window_maximize_hover = ' ',
    },
    window_frame = {
        inactive_titlebar_bg = '#ff3535',
        active_titlebar_bg = '#2b2042',
        inactive_titlebar_fg = '#cccccc',
        active_titlebar_fg = '#ffffff',
        inactive_titlebar_border_bottom = '#2b2042',
        active_titlebar_border_bottom = '#2b2042',
        button_fg = '#cccccc',
        button_bg = '#2b2042',
        button_hover_fg = '#ff0000',
        button_hover_bg = '#3b3052',
    },
    integrated_title_button_color = 'red',

    -- }}}
    --
    -- keys {{{
    keys = utils.merge_lists(my_keys, navigate),
    -- }}}
    --
    -- hyperlinks {{{
    hyperlink_rules = {
        {
            regex = '\\b\\w+://[\\w.-]+:[0-9]{2,15}\\S*\\b',
            format = '$0',
        },
        {
            regex = '\\b\\w+://[\\w.-]+\\.[a-z]{2,15}\\S*\\b',
            format = '$0',
        },
        {
            regex = [[\b\w+@[\w-]+(\.[\w-]+)+\b]],
            format = 'mailto:$0',
        },
        {
            regex = [[\bfile://\S*\b]],
            format = '$0',
        },
        {
            regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
            format = '$0',
        },
        {
            regex = [[\b[tT](\d+)\b]],
            format = 'https://example.com/tasks/?t=$1',
        },
    },
    -- }}}
    --
    -- Domains {{{
    unix_domains = {
        {
            name = 'wsl',
            serve_command = { 'wsl', 'wezterm-mux-server', '--daemonize' },
        },
    },
    -- default_gui_startup_args = { 'connect', 'wsl' },
    -- }}}
}

-- vim: fdm=marker ts=2 sw=2 sts=2 et

