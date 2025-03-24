--- Copilot are you working?  I'm working, I'm working.
---
---
local fn, api, v, env, cmd, fmt =
  vim.fn, vim.api, vim.v, vim.env, vim.cmd, string.format

-- colors {{{

function mrl.get_hi(name, id)
  id = id or 0
  local hi = vim.api.nvim_get_hl(0, { name = name })
  -- hi is a table with bg and fg keys. for those we want to return the hex
  -- value with ('#%06x'):format(num)
  for k, v in pairs(hi) do
    if type(v) == 'number' then hi[k] = ('#%06x'):format(v) end
  end
  return hi
end

-- }}}

--------------------------------------------------------------------------------
-- checkers {{{
--------------------------------------------------------------------------------

-- }}}
--------------------------------------------------------------------------------

-- commands {{{
function mrl.command(name, rhs, opts)
  opts = opts or {}
  api.nvim_create_user_command(name, rhs, opts)
end

--- Call the given function and use `vim.notify` to notify of any errors
--- this function is a wrapper around `xpcall` which allows having a single
--- error handler for all errors
---@param msg string
---@param func function
---@param ... any
---@return boolean, any
---@overload fun(func: function, ...): boolean, any
function mrl.pcall(msg, func, ...)
  local args = { ... }
  if type(msg) == 'function' then
    local arg = func --[[@as any]]
    args, func, msg = { arg, unpack(args) }, msg, nil
  end
  return xpcall(func, function(err)
    msg = debug.traceback(
      msg and fmt('%s:\n%s\n%s', msg, vim.inspect(args), err) or err
    )
    vim.schedule(
      function() vim.notify(msg, vim.log.levels.ERROR, { title = 'ERROR' }) end
    )
  end, unpack(args))
end

local LATEST_NIGHTLY_MINOR = 10
function mrl.nightly() return vim.version().minor >= LATEST_NIGHTLY_MINOR end

-- }}}

--------------------------------------------------------------------------------
-- finders and matchers {{{
--------------------------------------------------------------------------------
---Determine if a value of any type is empty
---@param item any
---@return boolean?
function mrl.falsy(item)
  if not item then return true end
  local item_type = type(item)
  if item_type == 'boolean' then return not item end
  if item_type == 'string' then return item == '' end
  if item_type == 'number' then return item <= 0 end
  if item_type == 'table' then return vim.tbl_isempty(item) end
  return item ~= nil
end

---@generic T:table
---@param callback fun(item: T, key: any)
---@param list table<any, T>
function mrl.foreach(callback, list)
  for k, v in pairs(list) do
    callback(v, k)
  end
end

--- Check if the target matches  any item in the list.
---@param target string
---@param list string[]
---@return boolean
function mrl.any(target, list)
  for _, item in ipairs(list) do
    if target:match(item) then return true end
  end
  return false
end

---Find an item in a list
---@generic T
---@param matcher fun(arg: T):boolean
---@param haystack T[]
---@return T?
function mrl.find(matcher, haystack)
  for _, needle in ipairs(haystack) do
    if matcher(needle) then return needle end
  end
end

---@generic T
---Given a table return a new table which if the key is not found will search
---all the table's keys for a match using `string.match`
---@param map T
---@return T
function mrl.p_table(map)
  return setmetatable(map, {
    __index = function(tbl, key)
      if not key then return end
      for k, v in pairs(tbl) do
        if key:match(k) then return v end
      end
    end,
  })
end

---check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function mrl.has(feature) return fn.has(feature) > 0 end

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- resize {{{
--------------------------------------------------------------------------------

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param min_height number
---@param max_height number
function mrl.adjust_split_height(min_height, max_height)
  vim.api.nvim_win_set_height(
    0,
    math.max(math.min(vim.fn.line('$'), max_height), min_height)
  )
end

-- }}}
--------------------------------------------------------------------------------
---
---
---
---
---

function mrl.fold(callback, list, accum)
  accum = accum or {}
  for k, v in pairs(list) do
    accum = callback(accum, v, k)
    assert(accum ~= nil, 'The accumulator must be returned on each iteration')
  end
  return accum
end

---@generic T
---@param callback fun(item: T, key: string | number, list: T[]): T
---@param list T[]
---@return T[]
function mrl.map(callback, list)
  return mrl.fold(function(accum, v, k)
    accum[#accum + 1] = callback(v, k, accum)
    return accum
  end, list, {})
end

--------------------------------------------------------------------------------
-- Autcommand group {{{
--------------------------------------------------------------------------------

local autocmd_keys =
  { 'event', 'buffer', 'pattern', 'desc', 'command', 'group', 'once', 'nested' }
--- Validate the keys passed to mrl.augroup are valid
---@param name string
---@param command Autocommand
local function validate_autocmd(name, command)
  local incorrect = mrl.fold(function(accum, _, key)
    if not vim.tbl_contains(autocmd_keys, key) then table.insert(accum, key) end
    return accum
  end, command, {})

  if #incorrect > 0 then
    vim.schedule(function()
      local msg = 'Incorrect keys: ' .. table.concat(incorrect, ', ')
      vim.notify(msg, 'error', { title = fmt('Autocmd: %s', name) })
    end)
  end
end

---Create an autocommand
---returns the group ID so that it can be cleared or manipulated.
---@param name string The name of the autocommand group
---@param ... Autocommand A list of autocommands to create
---@return number
function mrl.augroup(name, ...)
  local commands = { ... }
  assert(name ~= 'User', 'The name of an augroup CANNOT be User')
  assert(
    #commands > 0,
    fmt('You must specify at least one autocommand for %s', name)
  )
  local id = api.nvim_create_augroup(name, { clear = true })
  for _, autocmd in ipairs(commands) do
    validate_autocmd(name, autocmd)
    local is_callback = type(autocmd.command) == 'function'

    api.nvim_create_autocmd(autocmd.event, {
      group = name,
      pattern = autocmd.pattern,
      desc = autocmd.desc,
      callback = is_callback and autocmd.command or nil,
      command = not is_callback and autocmd.command or nil,
      once = autocmd.once,
      nested = autocmd.nested,
      buffer = autocmd.buffer,
    })
  end
  return id
end

-- }}}
--------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--  Lazy Requires {{{
-------------------------------------------------------------------------------
-- This code comes from TJ the Great:
--- source: https://github.com/tjdevries/lazy-require.nvim

--- Require on index.
---
--- Will only require the module after the first index of a module.
--- Only works for modules that export a table.
function mrl.require_for_later_index(require_path)
  return setmetatable({}, {
    __index = function(_, key) return require(require_path)[key] end,
    __newindex = function(_, key, value) require(require_path)[key] = value end,
  })
end

--- Require when an exported method is called.
---
--- Creates a new function. Cannot be used to compare functions,
--- set new values, etc. Only useful for waiting to do the require until you
--- actually call the code.
---
--- ```lua
--- -- This is not loaded yet
--- local lazy_mod = lazy.require_on_exported_call('my_module')
--- local lazy_func = lazy_mod.exported_func
---
--- -- ... some time later
--- lazy_func(42)  -- <- Only loads the module now
---
--- ```
---@param require_path string
---@return table<string, fun(...): any>
function mrl.require_for_later_call(require_path)
  return setmetatable({}, {
    __index = function(_, k)
      return function(...) return require(require_path)[k](...) end
    end,
  })
end

-- }}}
-------------------------------------------------------------------------------
---
---
---

--- Autosize horizontal split to match its minimum content
--- https://vim.fandom.com/wiki/Automatically_fitting_a_quickfix_window_height
---@param min_height number
---@param max_height number
function mrl.adjust_split_height(min_height, max_height)
  api.nvim_win_set_height(
    0,
    math.max(math.min(fn.line('$'), max_height), min_height)
  )
end

-- strings {{{

---Truncate a string to a maximum length
---@param str string
---@param max_len integer
---@return string
function mrl.truncate(str, max_len)
  assert(str and max_len, 'string and max_len must be provided')
  return api.nvim_strwidth(str) > max_len
      and str:sub(1, max_len) .. mrl.ui.icons.misc.ellipsis
    or str
end
-- }}}

-- vim: fdm=marker
