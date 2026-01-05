local M = {}

local navic = require('nvim-navic')

--- Get navic location breadcrumb
--- Note: navic.get_location() uses current buffer context, so bufnr is just for checking availability
--- @param bufnr number?
--- @return string?
function M.get_location(bufnr)
  bufnr = bufnr or 0
  if not navic.is_available(bufnr) then
    return nil
  end

  -- navic.get_location() doesn't take parameters, it uses current buffer context
  -- In statusline render, we're already in the correct buffer context
  local location = navic.get_location()

  if not location or location == '' then
    return nil
  end

  return location
end

--- Check if navic is available
--- @param bufnr number?
--- @return boolean
function M.is_available(bufnr)
  bufnr = bufnr or 0
  return navic.is_available(bufnr)
end

return M
