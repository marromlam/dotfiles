local server_path = vim.api.nvim_get_runtime_file('copilot/js/language-server.js', false)[1]

return {
  cmd        = { 'node', server_path, '--stdio' },
  filetypes  = { '*' },
  root_dir   = vim.fn.getcwd,
  settings   = {},
}
