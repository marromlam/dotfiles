if
  not mrl
  or not mrl.ui
  or not mrl.ui.statuscolumn
  or not mrl.ui.statuscolumn.enable
then
  return
end

-- Custom statuscolumn inspired by akinsho:
-- - separates git signs from other signs
-- - shows fold marker
-- - can be disabled per buffer via your "decorations" presets

mrl.ui.statuscolumn = mrl.ui.statuscolumn or {}

local api, fn = vim.api, vim.fn
local v = vim.v
local space = ' '
local icons = (mrl.ui and mrl.ui.icons and mrl.ui.icons.separators) or {}
local diag_icons = (mrl.ui and mrl.ui.icons and mrl.ui.icons.lsp) or {}
local diag_warn_icon = diag_icons.warn or 'W'
local diag_err_icon = diag_icons.error or 'E'

local function hl(hl_group, text)
  if not hl_group or hl_group == '' then return text end
  return ('%%#%s#%s%%*'):format(hl_group, text)
end

local function strip_ws(s)
  if type(s) ~= 'string' then return '' end
  return (s:gsub('%s+', ''))
end

local function is_git_sign(hl_group)
  if type(hl_group) ~= 'string' then return false end
  return hl_group:match('^Git') ~= nil or hl_group:match('^GitSigns') ~= nil
end

local function is_diag_sign(hl_group)
  if type(hl_group) ~= 'string' then return false end
  return hl_group:match('^DiagnosticSign') ~= nil
end

-- Only show error/warn (keep the column narrow).
local function diag_sign_text(hl_group)
  if type(hl_group) ~= 'string' then return nil end
  if hl_group:match('Error') then return diag_err_icon end
  if hl_group:match('Warn') then return diag_warn_icon end
  return nil
end

-- Map gitsigns hl groups to our "colored cell" highlight groups.
local function git_status_hl(hl_group)
  if type(hl_group) ~= 'string' then return nil end
  if hl_group:match('Untracked') then return 'StatusColGitUntracked' end
  if hl_group:match('Add') then return 'StatusColGitAdd' end
  if hl_group:match('Changedelete') or hl_group:match('Change') then
    return 'StatusColGitChange'
  end
  if hl_group:match('Topdelete') or hl_group:match('Delete') then
    return 'StatusColGitDelete'
  end
  return 'StatusColGitChange'
end

local function fold_mark(lnum)
  local fcs = vim.opt.fillchars:get()
  if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return '' end
  return fn.foldclosed(lnum) == -1 and (fcs.foldopen or '▾')
    or (fcs.foldclose or '▸')
end

local function format_number(win, lnum, relnum, virtnum, line_count)
  local col_width = api.nvim_strwidth(tostring(line_count))
  if virtnum and virtnum ~= 0 then
    -- virtual line: show a subtle placeholder
    return space:rep(math.max(col_width - 1, 0)) .. '░'
  end

  local num = (vim.wo[win].relativenumber and relnum ~= 0) and relnum or lnum
  local ln = tostring(num)
  local pad = col_width - api.nvim_strwidth(ln)
  return space:rep(math.max(pad, 0)) .. ln
end

local function best_sign(buf, lnum0, want_git)
  local marks = api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum0, 0 },
    { lnum0, -1 },
    { details = true, type = 'sign' }
  )

  local best_text, best_hl, best_prio = '', nil, -math.huge
  for _, item in ipairs(marks) do
    local d = item[4] or {}
    local hlg = d.sign_hl_group
    local text = strip_ws(d.sign_text or '')
    local prio = tonumber(d.priority) or 0

    if want_git then
      -- Render git as a colored statuscolumn cell (no glyph).
      if is_git_sign(hlg) then
        local forced_hl = git_status_hl(hlg)
        if forced_hl and prio > best_prio then
          best_text, best_hl, best_prio = ' ', forced_hl, prio
        end
      end
    else
      if text ~= '' and (is_git_sign(hlg) == false) then
        if prio > best_prio then
          best_text, best_hl, best_prio = text, hlg, prio
        end
      end
    end
  end

  if want_git then
    -- Always render a git cell; if there are no changes, show a neutral grey cell.
    if best_text == '' then return hl('StatusColGitNone', '│ ') end
    return hl(best_hl, '│ ')
  end

  if best_text == '' then return '' end
  return hl(best_hl, best_text)
end

local function best_diag(buf, lnum0)
  local marks = api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum0, 0 },
    { lnum0, -1 },
    { details = true, type = 'sign' }
  )

  -- Prefer Error over Warn regardless of priority (narrow "warn/error status").
  local best_text, best_hl, best_sev, best_prio = '', nil, 99, -math.huge
  for _, item in ipairs(marks) do
    local d = item[4] or {}
    local hlg = d.sign_hl_group
    if is_diag_sign(hlg) then
      local forced = diag_sign_text(hlg)
      if forced then
        local prio = tonumber(d.priority) or 0
        local sev = hlg:match('Error') and 1 or 2 -- 1=Error, 2=Warn
        if (sev < best_sev) or (sev == best_sev and prio > best_prio) then
          best_text, best_hl, best_sev, best_prio = forced, hlg, sev, prio
        end
      end
    end
  end

  -- Keep the column aligned: always reserve 1 cell for diagnostics.
  if best_text == '' then return ' ' end
  return hl(best_hl, best_text)
end

local function should_disable(buf, ft)
  if vim.bo[buf].buftype ~= '' then return true end
  if not mrl.ui.decorations or not mrl.ui.decorations.get then return false end
  local decor = mrl.ui.decorations.get({
    ft = ft,
    bt = vim.bo[buf].buftype,
    setting = 'statuscolumn',
  })
  return decor
    and (decor.ft == false or decor.bt == false or decor.fname == false)
end

function mrl.ui.statuscolumn.render()
  local win = tonumber(vim.g.statusline_winid) or api.nvim_get_current_win()
  local buf = api.nvim_win_get_buf(win)
  local ft = vim.bo[buf].filetype
  if should_disable(buf, ft) then return '' end

  local lnum, relnum, virtnum = v.lnum, v.relnum, v.virtnum
  local line_count = api.nvim_buf_line_count(buf)

  local diag = best_diag(buf, lnum - 1)
  local git = best_sign(buf, lnum - 1, true)
  local num = format_number(win, lnum, relnum, virtnum, line_count)
  local fold = fold_mark(lnum)

  -- Keep a stable, narrow layout:
  -- (diag)?(num)(git)(fold)?
  -- git symbol is │
  return table.concat({
    diag,
    hl('LineNr', num),
    git,
    fold,
  })
end

vim.o.statuscolumn = '%{%v:lua.mrl.ui.statuscolumn.render()%}'

-- Disable statuscolumn for buffers where your decorations preset says so.
api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
  group = api.nvim_create_augroup('MrlStatusColumn', { clear = true }),
  callback = function(args)
    local buf = args.buf
    local ft = vim.bo[buf].filetype
    local win = api.nvim_get_current_win()
    local winhl = vim.wo[win].winhl or ''
    -- fzf-lua uses window-local winhl mappings like `Normal:FzfLuaNormal`
    -- for both the picker and its preview. Disable our statuscolumn there to
    -- avoid a "left stripe"/gutter inside the picker UI.
    if winhl:match('FzfLua') then
      vim.opt_local.statuscolumn = ''
      vim.opt_local.signcolumn = 'no'
      return
    end
    if should_disable(buf, ft) then
      vim.opt_local.statuscolumn = ''
      -- When our statuscolumn is disabled, show signs normally.
      vim.opt_local.signcolumn = 'yes'
    else
      vim.opt_local.statuscolumn = vim.o.statuscolumn
      -- Prevent duplicated signs (git/diagnostics) in the gutter:
      -- our statuscolumn already renders them.
      vim.opt_local.signcolumn = 'no'
    end
  end,
})
