-- Integration tests for LSP / Mason setup.
--
-- Tier 1 — Mason registry.
--   Loads mason.nvim directly in this test process (using the real lazy data
--   dir so the registry index is available) and asserts that each expected
--   package name is known to mason-registry.
--
-- Tier 2 — On-disk binaries.
--   Checks ~/.local/share/nvim/mason/ to confirm every tool was actually
--   installed. Skipped gracefully when the directory doesn't exist.

local T = MiniTest.new_set()
local eq = MiniTest.expect.equality

-- ─── Tool / server lists (keep in sync with lua/custom/plugins/lsp.lua) ──────

local LSP_SERVERS = {
  'basedpyright',
  'ruff',
  'lua_ls',
}

local EXTRA_TOOLS = {
  'stylua',
  'black',
  'isort',
  'flake8',
  'mypy',
  'shfmt',
  'prettier',
  'prettierd',
  'eslint_d',
  'hadolint',
  'jsonlint',
  'vale',
  'tflint',
  'sonarlint-language-server',
}

-- mason-lspconfig package names (differ from server names for some servers)
local SERVER_TO_PACKAGE = {
  lua_ls = 'lua-language-server',
  basedpyright = 'basedpyright',
  ruff = 'ruff',
}

-- ─── Tier 1: mason-registry knows every package ───────────────────────────────
-- We load mason.nvim into this process using the real lazy install path.
-- We must temporarily override XDG_DATA_HOME so mason reads its cached registry
-- from the real data dir, not the isolated tmp dir set by minimal_init.lua.

local real_data = vim.fn.expand('~/.local/share/nvim')
local mason_plugin_path = real_data .. '/lazy/mason.nvim'
local mason_exists = vim.loop.fs_stat(mason_plugin_path) ~= nil

-- Load mason once, restoring the real data dir for its setup
local mason_registry
if mason_exists then
  -- Temporarily point XDG_DATA_HOME at the real nvim data parent so mason
  -- can find its cached registry index (under ~/.local/share/nvim/mason/)
  local old_xdg = vim.env.XDG_DATA_HOME
  vim.env.XDG_DATA_HOME = vim.fn.expand('~/.local/share')

  vim.opt.rtp:prepend(mason_plugin_path)
  local ok, reg = pcall(function()
    require('mason').setup()
    return require('mason-registry')
  end)

  vim.env.XDG_DATA_HOME = old_xdg

  if ok then mason_registry = reg end
end

T['mason registry'] = MiniTest.new_set()

local function registry_has(pkg_name)
  if not mason_registry then
    MiniTest.skip('mason.nvim not available — skipping registry checks')
  end
  local ok = pcall(function() return mason_registry.get_package(pkg_name) end)
  return ok
end

for _, tool in ipairs(EXTRA_TOOLS) do
  local name = tool
  T['mason registry']['tool: ' .. name] = function()
    eq(registry_has(name), true)
  end
end

for _, server in ipairs(LSP_SERVERS) do
  local pkg = SERVER_TO_PACKAGE[server] or server
  local sname = server
  T['mason registry']['lsp: ' .. sname] = function() eq(registry_has(pkg), true) end
end

-- ─── Tier 2: on-disk presence ─────────────────────────────────────────────────

local mason_root = real_data .. '/mason'
local mason_bin = mason_root .. '/bin'
local mason_pkgs = mason_root .. '/packages'
local mason_bin_exists = vim.loop.fs_stat(mason_bin) ~= nil

T['mason installed tools'] = MiniTest.new_set()

local function bin_exists(name)
  return vim.loop.fs_stat(mason_bin .. '/' .. name) ~= nil
end
local function pkg_exists(name)
  return vim.loop.fs_stat(mason_pkgs .. '/' .. name) ~= nil
end

for _, tool in ipairs(EXTRA_TOOLS) do
  local name = tool
  T['mason installed tools']['bin: ' .. name] = function()
    if not mason_bin_exists then
      MiniTest.skip('Mason not installed on this machine')
    end
    eq(bin_exists(name), true)
  end
end

for _, server in ipairs(LSP_SERVERS) do
  local pkg = SERVER_TO_PACKAGE[server] or server
  local sname = server
  T['mason installed tools']['lsp: ' .. sname] = function()
    if not mason_bin_exists then
      MiniTest.skip('Mason not installed on this machine')
    end
    eq(pkg_exists(pkg), true)
  end
end

return T
