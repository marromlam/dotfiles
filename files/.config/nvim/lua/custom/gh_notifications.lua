local M = {}

local function has_cmd(cmd) return vim.fn.executable(cmd) == 1 end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = 'GitHub Notifications' })
end

local function fetch_notifications()
  if not has_cmd('gh') then
    notify("`gh` not found; can't fetch notifications", vim.log.levels.ERROR)
    return {}
  end

  -- Use GitHub CLI (same approach the plugin prefers when available).
  local out = vim.fn.systemlist({ 'gh', 'api', '/notifications' })
  if vim.v.shell_error ~= 0 then
    notify(table.concat(out, '\n'), vim.log.levels.ERROR)
    return {}
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(out, '\n'))
  if not ok or type(decoded) ~= 'table' then return {} end
  return decoded
end

local function format_item(n)
  local repo = n.repository and n.repository.full_name or ''
  local title = n.subject and n.subject.title or ''
  local ntype = n.subject and n.subject.type or ''
  local unread = n.unread and '●' or ' '
  local id = tostring(n.id or '')
  return string.format('%s\t%s\t%s\t%s\t%s', id, unread, ntype, repo, title)
end

function M.open()
  local ok, fzf = pcall(require, 'fzf-lua')
  if not ok then
    notify('fzf-lua not available', vim.log.levels.ERROR)
    return
  end

  local notifs = fetch_notifications()
  local lines = vim.tbl_map(format_item, notifs)

  fzf.fzf_exec(lines, {
    prompt = (mrl and mrl.ui and mrl.ui.icons and mrl.ui.icons.misc.search or '󰍉')
      .. '  ',
    fzf_opts = {
      ['--delimiter'] = '\t',
      ['--with-nth'] = '2..',
      ['--header'] = 'enter: mark read  |  ctrl-o: open repo  |  ctrl-r: mark all read',
    },
    actions = {
      ['default'] = function(selected)
        local line = selected and selected[1] or ''
        local id = line:match('^(.-)\t')
        if not id or id == '' then return end
        vim.fn.system({ 'gh', 'api', '-X', 'PATCH', '/notifications/threads/' .. id })
      end,
      ['ctrl-r'] = function()
        vim.fn.system({ 'gh', 'api', '-X', 'PUT', '/notifications' })
      end,
      ['ctrl-o'] = function(selected)
        local line = selected and selected[1] or ''
        local id = line:match('^(.-)\t')
        if not id or id == '' then return end
        -- Best-effort: open the repo homepage for context.
        for _, n in ipairs(notifs) do
          if tostring(n.id) == id and n.repository and n.repository.html_url then
            vim.fn.jobstart({ vim.g.open_command or 'xdg-open', n.repository.html_url }, { detach = true })
            return
          end
        end
      end,
    },
  })
end

return M

