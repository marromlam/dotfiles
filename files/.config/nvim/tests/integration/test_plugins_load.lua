-- Smoke tests: verify core Lua modules can be require()'d without errors.
-- Catches import-time syntax errors or broken module structure independently
-- of whether plugins are installed.

local T = MiniTest.new_set()

local config_root = vim.fn.fnamemodify(
  debug.getinfo(1, 'S').source:sub(2),
  ':h:h:h'
)

vim.opt.rtp:prepend(config_root)

local function loads(mod_name)
  T[mod_name .. ' loads without error'] = function()
    local ok, result = pcall(require, mod_name)
    MiniTest.expect.equality(ok, true)
    MiniTest.expect.no_equality(result, nil)
  end
end

loads('tools')      -- core utilities + ui + strings + colors
loads('highlight')  -- highlight helpers (depends on tools)

-- options.lua has side effects but returns nothing; just check it doesn't error
T['options.lua executes without error'] = function()
  local ok, err = pcall(require, 'options')
  if not ok then
    if type(err) == 'string' and err:match('already') then return end
    error(err)
  end
  MiniTest.expect.equality(ok, true)
end

return T
