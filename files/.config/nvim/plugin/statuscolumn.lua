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

local function fold_mark(lnum)
  local fcs = vim.opt.fillchars:get()
  if fn.foldlevel(lnum) <= fn.foldlevel(lnum - 1) then return space end
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
    local text = strip_ws(d.sign_text or '')
    local hlg = d.sign_hl_group
    local prio = tonumber(d.priority) or 0
    if text ~= '' and (is_git_sign(hlg) == want_git) then
      if prio > best_prio then
        best_text, best_hl, best_prio = text, hlg, prio
      end
    end
  end

  if best_text == '' then return space end
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

  local other = best_sign(buf, lnum - 1, false)
  local git = best_sign(buf, lnum - 1, true)
  local num = format_number(win, lnum, relnum, virtnum, line_count)
  local fold = fold_mark(lnum)

  -- Keep a stable layout:
  -- [other] [num] [git] │ [fold]
  return table.concat({
    other,
    space,
    hl('LineNr', num),
    space,
    git,
    space,
    hl('StatusColSep', '│'),
    space,
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
    if should_disable(buf, ft) then
      vim.opt_local.statuscolumn = ''
    else
      vim.opt_local.statuscolumn = vim.o.statuscolumn
    end
  end,
})
