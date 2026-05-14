-- packs/remote.lua

-- nvim-dev-container: lazy, setup with empty opts when needed
vim.defer_fn(function()
  local ok, devcontainer = pcall(require, 'devcontainer')
  if ok then
    devcontainer.setup({})
  end
end, 100)

-- vim:foldmethod=marker
