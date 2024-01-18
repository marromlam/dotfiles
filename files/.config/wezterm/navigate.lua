local wezterm = require('wezterm')

local function isViProcess(pane)
    local tty = pane:get_tty_name()
    if tty == nil then return false end
    wezterm.log_info('tty: ' .. tty)
    -- get_foreground_process_name On Linux, macOS and Windows,
    -- the process can be queried to determine this path. Other operating systems
    -- (notably, FreeBSD and other unix systems) are not currently supported
    -- return pane:get_foreground_process_name():find('(n?vim|tmux)') ~= nil
    -- return pane:get_title():find("(n?vim|tmux)") ~= nil
    local success, stdout, stderr = wezterm.run_child_process({
        'sh',
        '-c',
        'ps -o state= -o comm= -t'
            .. wezterm.shell_quote_arg(tty)
            .. ' | '
            .. "grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|tmux|l?n?vim?x?)(diff)?$'",
    })
    wezterm.log_info('sdfasdfsdf')

    return not success
end

local function conditionalActivatePane(
    window,
    pane,
    pane_direction,
    vim_direction
)
    if isViProcess(pane) then
        window:perform_action(
            -- This should match the keybinds you set in Neovim.
            wezterm.action.SendKey({
                key = vim_direction,
                mods = 'CTRL',
            }),
            pane
        )
    else
        window:perform_action(
            wezterm.action.ActivatePaneDirection(pane_direction),
            pane
        )
    end
end

wezterm.on(
    'ActivatePaneDirection-right',
    function(window, pane) conditionalActivatePane(window, pane, 'Right', 'l') end
)
wezterm.on(
    'ActivatePaneDirection-left',
    function(window, pane) conditionalActivatePane(window, pane, 'Left', 'h') end
)
wezterm.on(
    'ActivatePaneDirection-up',
    function(window, pane) conditionalActivatePane(window, pane, 'Up', 'k') end
)
wezterm.on(
    'ActivatePaneDirection-down',
    function(window, pane) conditionalActivatePane(window, pane, 'Down', 'j') end
)

return {
    {
        key = 'h',
        mods = 'CTRL',
        action = wezterm.action.EmitEvent('ActivatePaneDirection-left'),
    },
    {
        key = 'j',
        mods = 'CTRL',
        action = wezterm.action.EmitEvent('ActivatePaneDirection-down'),
    },
    {
        key = 'k',
        mods = 'CTRL',
        action = wezterm.action.EmitEvent('ActivatePaneDirection-up'),
    },
    {
        key = 'l',
        mods = 'CTRL',
        action = wezterm.action.EmitEvent('ActivatePaneDirection-right'),
    },
}

-- vim: fdm=marker et ts=4 sw=4
