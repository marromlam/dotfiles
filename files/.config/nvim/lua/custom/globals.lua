local fn, api, cmd, fmt = vim.fn, vim.api, vim.cmd, string.format
local l = vim.log.levels

---------------------------------------------------------------------------------
-- Quickfix and Location List {{{
---------------------------------------------------------------------------------

mrl.list = { qf = {}, loc = {} }

---@param list_type "loclist" | "quickfix"
---@return boolean
local function is_list_open(list_type)
  return mrl.find(
    function(win) return not mrl.falsy(win[list_type]) end,
    fn.getwininfo()
  ) ~= nil
end

local silence = { mods = { silent = true, emsg_silent = true } }

---@param callback fun(...)
local function preserve_window(callback, ...)
  local win = api.nvim_get_current_win()
  callback(...)
  if win ~= api.nvim_get_current_win() then cmd.wincmd('p') end
end

function mrl.list.qf.toggle()
  if is_list_open('quickfix') then
    cmd.cclose(silence)
  elseif #fn.getqflist() > 0 then
    preserve_window(cmd.copen, silence)
  end
end

function mrl.list.loc.toggle()
  if is_list_open('loclist') then
    cmd.lclose(silence)
  elseif #fn.getloclist(0) > 0 then
    preserve_window(cmd.lopen, silence)
  end
end

-- @see: https://vi.stackexchange.com/a/21255
-- using range-aware function
function mrl.list.qf.delete(buf)
  buf = buf or api.nvim_get_current_buf()
  local list = fn.getqflist()
  local line = api.nvim_win_get_cursor(0)[1]
  local mode = api.nvim_get_mode().mode
  if mode:match('[vV]') then
    local first_line = fn.getpos("'<")[2]
    local last_line = fn.getpos("'>")[2]
    list = mrl.fold(function(accum, item, i)
      if i < first_line or i > last_line then accum[#accum + 1] = item end
      return accum
    end, list)
  else
    table.remove(list, line)
  end
  -- replace items in the current list, do not make a new copy of it; this also preserves the list title
  fn.setqflist({}, 'r', { items = list })
  fn.setpos('.', { buf, line, 1, 0 }) -- restore current line
end

-- }}}
---------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--  FILETYPE HELPERS
--------------------------------------------------------------------------------

---@class FiletypeSettings
---@field g table<string, any>
---@field bo vim.bo
---@field wo vim.wo
---@field opt vim.opt
---@field plugins {[string]: fun(module: table)}

---@param args {[1]: string, [2]: string, [3]: string, [string]: boolean | integer}[]
---@param buf integer
local function apply_ft_mappings(args, buf)
  mrl.foreach(function(m)
    assert(
      m[1] and m[2] and m[3],
      'map args must be a table with at least 3 items'
    )
    local opts = mrl.fold(function(acc, item, key)
      if type(key) == 'string' then acc[key] = item end
      return acc
    end, m, { buffer = buf })
    map(m[1], m[2], m[3], opts)
  end, args)
end

--- A convenience wrapper that calls the ftplugin config for a plugin if it exists
--- and warns me if the plugin is not installed
---@param configs table<string, fun(module: table)>
function mrl.ftplugin_conf(configs)
  if type(configs) ~= 'table' then return end
  for name, callback in pairs(configs) do
    local ok, plugin = mrl.pcall(require, name)
    if ok then callback(plugin) end
  end
end

-- vim: fdm=marker
