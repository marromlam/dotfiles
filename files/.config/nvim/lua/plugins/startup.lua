return {
    {
        "willothy/veil.nvim",
        lazy = true,
        dependencies = {
            -- All optional, only required for the default setup.
            -- If you customize your config, these aren't necessary.
            "nvim-telescope/telescope.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-file-browser.nvim",
        },
        config = function()
            local builtin = require("veil.builtin")
            local current_day = os.date("%A")
            require("veil").setup({
                sections = {
                    builtin.sections.animated(
                        builtin.headers.frames_days_of_week[current_day],
                        {
                            hl = { fg = "#5de4c7" },
                        }
                    ),
                    builtin.sections.buttons({
                        {
                            icon = "",
                            text = "Find Files",
                            shortcut = "f",
                            callback = function()
                                require("telescope.builtin").find_files()
                            end,
                        },
                        {
                            icon = "",
                            text = "Find Word",
                            shortcut = "w",
                            callback = function()
                                require("telescope.builtin").live_grep()
                            end,
                        },
                        {
                            icon = "",
                            text = "Buffers",
                            shortcut = "b",
                            callback = function()
                                require("telescope.builtin").buffers()
                            end,
                        },
                        {
                            icon = "",
                            text = "Config",
                            shortcut = "c",
                            callback = function()
                                require("telescope").extensions.file_browser.file_browser({
                                    path = vim.fn.stdpath("config"),
                                })
                            end,
                        },
                    }),
                    builtin.sections.oldfiles(),
                },
                mappings = {},
                startup = true,
                listed = false,
            })
        end,
    },
}
