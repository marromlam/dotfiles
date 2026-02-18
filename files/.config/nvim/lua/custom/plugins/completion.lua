local highlight, ui = mrl.highlight, mrl.ui

return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    cond = not vim.g.use_cmp,
    disable = vim.g.use_cmp,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'onsails/lspkind.nvim', -- vs-code like pictograms
      'Kaiser-Yang/blink-cmp-avante',
    },
    version = '*',
    init = function()
      highlight.plugin('blink', {
        -- Keep completion popups consistent with float styling
        { BlinkCmpMenuBorder = { link = 'FloatBorder' } },
        { BlinkCmpDocBorder = { link = 'FloatBorder' } },
        { BlinkCmpMenu = { link = 'NormalFloat' } },
        { BlinkCmpDoc = { link = 'NormalFloat' } },
      })
    end,
    opts = {
      keymap = { preset = 'enter' },
      appearance = {
        nerd_font_variant = 'mono',
        use_nvim_cmp_as_default = true,
      },
      sources = {
        default = { 'avante', 'lsp', 'path', 'snippets', 'buffer' },

        per_filetype = {
          codecompanion = { 'codecompanion' },
          sql = { 'snippets', 'dadbod', 'buffer' },
        },

        providers = {
          avante = {
            module = 'blink-cmp-avante',
            name = 'Avante',
            opts = {
              -- options for blink-cmp-avante
            },
          },
          markdown = {
            name = 'RenderMarkdown',
            module = 'render-markdown.integ.blink',
            fallbacks = { 'lsp' },
          },
          dadbod = { name = 'Dadbod', module = 'vim_dadbod_completion.blink' },
        },
      },
      signature = { window = { border = 'rounded' } },
      completion = {
        menu = { border = 'rounded' },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 500,
          window = { border = 'rounded' },
        },
        list = {
          selection = {
            auto_insert = function(ctx)
              return ctx.mode == 'cmdline' and false or true
            end,
          },
        },
      },
    },
    opts_extend = { 'sources.default' },
  },
}
