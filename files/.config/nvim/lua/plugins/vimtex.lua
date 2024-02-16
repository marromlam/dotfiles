return {
    {
        "lervag/vimtex",
        disable = false,
        ft = "tex",
        config = function()
            vim.g.tex_flavor = "latex"
            vim.g.vimtex_compiler_latexmk = { progname = "nvr" }
            -- quickfix errors
            vim.g.vimtex_quickfix_open_on_warning = 0
            vim.g.vimtex_view_automatic = 0
            -- vim.g.vimtex_quickfix_mode = 2
            -- Config from castel.dev
            vim.cmd([[set conceallevel=1]])
            vim.g.tex_conceal = "abdmg"

            -- vim.cmd([[
            --       let g:vimtex_compiler_latexmk = {
            --           \ 'build_dir' : 'build',
            --           \ 'progname' : 'nvr',
            --           \ 'callback' : 1,
            --           \ 'continuous' : 1,
            --           \ 'executable' : 'latexmk',
            --           \ 'hooks' : [],
            --           \ 'options' : [
            --           \   '-verbose',
            --           \   '-file-line-error',
            --           \   '-synctex=1',
            --           \   '-interaction=nonstopmode',
            --           \ ],
            --           \}
            --
            -- vim.cmd([[
            --       " Disable custom warnings based on regexp
            --       let g:vimtex_quickfix_ignore_filters = [
            --             'Marginpar on page',
            --             'Package hyperref Warning',
            --             'Overfull \\hbox',
            --             'Underfull \\hbox',
            --             ]
            --       ]])
        end,
    },
    {
        "marromlam/tex-kitty",
        disable = false,
        ft = "tex",
        dir = "/Users/marcos/Projects/personal/tex-kitty",
        dev = true,
        dependencies = {
            "lervag/vimtex",
        },
        config = function()
            require("tex-kitty").setup({
                tex_kitty_preview = 1,
            })
        end,
    },
    {
        "xuhdev/vim-latex-live-preview",
        disable = false,
        ft = "tex",
        cmd = { "LLPStartPreview" },
        config = function()
            vim.g.livepreview_previewer = "open -a Preview"
        end,
    },
}
