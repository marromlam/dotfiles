-- packs/whichkey.lua

vim.defer_fn(function()
  local wk = require('which-key')
  wk.setup({
    win = {
      border = false,
      wo = {
        winhl = 'Normal:StatusLine,NormalFloat:StatusLine,FloatBorder:StatusLine',
      },
    },
    layout = { align = 'center' },
    -- preset = 'modern',
  })

  -- Sync all WhichKey highlight bg to StatusLine
  local function sync_hls()
    local bg =
      vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false }).bg
    if not bg then return end
    bg = ('#%06x'):format(bg)
    for _, name in ipairs({
      'WhichKeyNormal',
      'WhichKey',
      'WhichKeyDesc',
      'WhichKeyGroup',
      'WhichKeySeparator',
      'WhichKeyValue',
      'WhichKeyBorder',
      'WhichKeyTitle',
    }) do
      local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
      hl.bg = bg
      hl.ctermbg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end

  sync_hls()
  vim.api.nvim_create_autocmd('ColorScheme', { callback = sync_hls })
end, 100)
