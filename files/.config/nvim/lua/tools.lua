--- Copilot are you working?  I'm working, I'm working.
---
---

--------------------------------------------------------------------------------
-- checkers {{{
--------------------------------------------------------------------------------

-- }}}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- finders and matchers {{{
--------------------------------------------------------------------------------
---Find an item in a list
---@generic T
---@param matcher fun(arg: T):boolean
---@param haystack T[]
---@return T?
function mrl.find(matcher, haystack)
  for _, needle in ipairs(haystack) do
    if matcher(needle) then
      return needle
    end
  end
end

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
    math.max(math.min(vim.fn.line '$', max_height), min_height)
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

-- vim: fdm=marker
