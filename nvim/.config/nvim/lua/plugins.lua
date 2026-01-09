local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local codeCompanionAdapters = {
    http = {
        ollama = function()
            return require("codecompanion.adapters").extend("ollama", {
                schema = {
                    model = {
                        default = "qwen2.5-coder:7b",
                    },
                    think = {
                        default = false,
                    },
                },
            })
        end,
        openai_compatible = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
                -- url = "https://servicesessentials.ibm.com/apis/v3",
                env = {
                    api_key =
                    "7:xxx:96ca8495-9263-4979-8c45-959b782f687e:41d9a690-4d7a-41ec-9b3d-d2cdb48fe59c:56018549-6321-4e2e-b574-28c3287571ff",
                    url = "https://servicesessentials.ibm.com/apis/v3",
                },
                schema = {
                    model = {
                        default = "global/anthropic.claude-sonnet-4-5-20250929-v1:0",
                    },
                },
            })
        end,
    },
}

local plugins = {
    "nvim-lua/plenary.nvim",     -- Common utilities
    "kyazdani42/nvim-tree.lua",
    "kyazdani42/nvim-web-devicons", -- File icons
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-ui-select.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
    "simrat39/symbols-outline.nvim",
    "norcalli/nvim-colorizer.lua",
    "kylechui/nvim-surround",
    "b3nj5m1n/kommentary",
    "ThePrimeagen/harpoon",

    -- neogit
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "sindrets/diffview.nvim",
        },
    },
    "f-person/git-blame.nvim",
    "vim-scripts/auto-pairs-gentle", -- bracket autocompletion

    -- Fancier statusline
    {
        "nvim-lualine/lualine.nvim",
        dependencies = {
            "kyazdani42/nvim-web-devicons",
            "arkav/lualine-lsp-progress",
        },
    },

    -- LSP Client
    "neovim/nvim-lspconfig",
    {
        "folke/trouble.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        opts = {}, -- for default options, refer to the configuration section for custom setup.
        cmd = "Trouble",
        keys = {
            {
                "<leader>xx",
                "<cmd>Trouble diagnostics toggle<cr>",
                desc = "Diagnostics (Trouble)",
            },
            {
                "<leader>xX",
                "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
                desc = "Buffer Diagnostics (Trouble)",
            },
            {
                "<leader>cs",
                "<cmd>Trouble symbols toggle focus=false<cr>",
                desc = "Symbols (Trouble)",
            },
            {
                "<leader>cl",
                "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
                desc = "LSP Definitions / references / ... (Trouble)",
            },
            {
                "<leader>xL",
                "<cmd>Trouble loclist toggle<cr>",
                desc = "Location List (Trouble)",
            },
            {
                "<leader>xQ",
                "<cmd>Trouble qflist toggle<cr>",
                desc = "Quickfix List (Trouble)",
            },
        },
    },
    -- Language Server installer
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "MunifTanjim/prettier.nvim",

    -- Customizations over LSP
    -- Show VSCode-esque pictograms
    "onsails/lspkind-nvim",
    -- show various elements of LSP as UI
    -- { "tami5/lspsaga.nvim",              dependencies = { "neovim/nvim-lspconfig" } },
    {
        "nvimdev/lspsaga.nvim",
        config = function()
            require("lspsaga").setup({})
        end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons", -- optional
        },
    },

    -- Autocompletion plugin
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
        },
    },

    -- snippets
    {
        "hrsh7th/cmp-vsnip",
        dependencies = {
            "hrsh7th/vim-vsnip",
            "rafamadriz/friendly-snippets",
        },
    },

    "mfussenegger/nvim-jdtls",
    -- "jose-elias-alvarez/null-ls.nvim", -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
    -- Debugging
    "leoluz/nvim-dap-go",
    "mfussenegger/nvim-dap",
    { "rcarriga/nvim-dap-ui",            dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" } },
    { "nvim-treesitter/nvim-treesitter", build = "TSUpdate" },
    --[[ {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = true,
        opts = {
            rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" }
        }
    },
    {
        "rest-nvim/rest.nvim",
        ft = "http",
        dependencies = { "luarocks.nvim" },
        config = function()
            require("rest-nvim").setup()
        end,
    }, ]]
    "andreshazard/vim-freemarker",

    -- colorschemes
    "folke/tokyonight.nvim",
    -- use("morhetz/gruvbox")
    { "ellisonleao/gruvbox.nvim" },
    "luisiacc/gruvbox-baby",
    "windwp/nvim-ts-autotag",
    -- install without yarn or npm
    {
        "iamcco/markdown-preview.nvim",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "scalameta/nvim-metals",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "mfussenegger/nvim-dap",
        },
    },
    { "akinsho/bufferline.nvim", version = "*", dependencies = "nvim-tree/nvim-web-devicons" },
    "famiu/bufdelete.nvim",
    "mbbill/undotree",
    "https://gitlab.com/schrieveslaach/sonarlint.nvim",
    "https://github.com/sotte/presenting.vim",
    { "akinsho/toggleterm.nvim",          version = "*", config = true },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        opts = {
            -- add any options here
        },
        dependencies = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback

            "rcarriga/nvim-notify",
        },
    },
    {
        "nvimdev/guard.nvim",
        -- Builtin configuration, optional
        dependencies = {
            "nvimdev/guard-collection",
        },
    },
    { "Hoffs/omnisharp-extended-lsp.nvim" },
    {
        "stevearc/oil.nvim",
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            vim.env.ESLINT_D_PPID = vim.fn.getpid()
            local lint = require("lint")
            lint.linters_by_ft = {
                typescript = { "eslint_d" },
                -- typescript = { "eslint" },
                html = { "eslint_d" },
                javascript = { "eslint_d" },
                typescriptreact = { "eslint_d" },
                javascriptreact = { "eslint_d" },
            }

            local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

            vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave", "TextChanged" }, {
                group = lint_augroup,
                callback = function()
                    lint.try_lint()
                end,
            })

            vim.keymap.set("n", "<leader>l", function()
                lint.try_lint()
            end, { desc = "Trigger linting for current file" })
        end,
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        ---@type Flash.Config
        opts = {},
        -- stylua: ignore
        keys = {
            { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
            -- { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
            { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
            { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
            { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        },
    },
    {
        "christoomey/vim-tmux-navigator",
        cmd = {
            "TmuxNavigateLeft",
            "TmuxNavigateDown",
            "TmuxNavigateUp",
            "TmuxNavigateRight",
            "TmuxNavigatePrevious",
        },
        keys = {
            { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
            { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
            { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
            { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
            { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
        },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            notifier = { enabled = true },
            quickfile = { enabled = true },
            scratch = {
                enabled = true,
            },
            statuscolumn = {
                enabled = true,
                left = { "sign", "mark" },
            },
            git = { enabled = true },
            words = { enabled = true },
        },
        keys = {
            {
                "<leader>.",
                function()
                    Snacks.scratch()
                end,
                desc = "Toggle Scratch Buffer",
            },
            {
                "<leader>S",
                function()
                    Snacks.scratch.select()
                end,
                desc = "Select Scratch Buffer",
            },
            {
                "<leader>b",
                function()
                    Snacks.git.blame_line({
                        width = 0.6,
                        height = 0.6,
                        border = "rounded",
                        title = " Git Blame ",
                        title_pos = "center",
                        ft = "git",
                    })
                end,
                desc = "Git Blame current line",
            },
        },
    },
    {
        "javiorfo/nvim-soil",

        -- Optional for puml syntax highlighting:
        dependencies = { "javiorfo/nvim-nyctophilia" },

        lazy = true,
        ft = "plantuml",
        opts = {
            -- If you want to change default configurations

            -- This option closes the image viewer and reopen the image generated
            -- When true this offers some kind of online updating (like plantuml web server)
            actions = {
                redraw = false,
            },

            -- If you want to use Plant UML jar version instead of the installed version
            -- puml_jar = "/path/to/plantuml.jar",

            -- If you want to customize the image showed when running this plugin
            image = {
                darkmode = false, -- Enable or disable darkmode
                format = "png", -- Choose between png or svg

                -- This is a default implementation of using nsxiv to open the resultant image
                -- Edit the string to use your preferred app to open the image (as if it were a command line)
                -- Some examples:
                -- return "feh " .. img
                -- return "xdg-open " .. img
                execute_to_open = function(img)
                    return "open " .. img
                end,
            },
        },
    },
    "stevearc/conform.nvim",

    -- AI
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        opts = {
            strategies = {
                chat = {
                    adapters = codeCompanionAdapters,
                    adapter = "openai_compatible",
                },
                inline = {
                    adapters = codeCompanionAdapters,
                    adapter = "openai_compatible",
                },
            },
            -- NOTE: The log_level is in `opts.opts`
            opts = {
                log_level = "DEBUG", -- or "TRACE"
            },
        },
    },
    {
        "NickvanDyke/opencode.nvim",
        dependencies = {
            -- Recommended for `ask()` and `select()`.
            -- Required for `snacks` provider.
            ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
            -- { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
        },
        config = function()
            ---@type opencode.Opts
            vim.g.opencode_opts = {
                -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
            }

            -- Required for `opts.events.reload`.
            vim.o.autoread = true

            -- Recommended/example keymaps.
            vim.keymap.set({ "n", "x" }, "<leader>oca", function()
                require("opencode").ask("@this: ", { submit = true })
            end, { desc = "Ask opencode" })
            vim.keymap.set({ "n", "x" }, "<leader>ocs", function()
                require("opencode").select()
            end, { desc = "Execute opencode action…" })
            vim.keymap.set({ "n", "t" }, "<leader>oc", function()
                require("opencode").toggle()
            end, { desc = "Toggle opencode" })

            --[[ vim.keymap.set({ "n", "x" }, "go", function()
                return require("opencode").operator("@this ")
            end, { expr = true, desc = "Add range to opencode" })
            vim.keymap.set("n", "goo", function()
                return require("opencode").operator("@this ") .. "_"
            end, { expr = true, desc = "Add line to opencode" }) ]]

            --[[ vim.keymap.set("n", "<S-C-u>", function()
                require("opencode").command("session.half.page.up")
            end, { desc = "opencode half page up" })
            vim.keymap.set("n", "<S-C-d>", function()
                require("opencode").command("session.half.page.down")
            end, { desc = "opencode half page down" }) ]]

            -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
            --[[ vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
            vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true }) ]]
        end,
    },
}

local opts = {}

require("lazy").setup(plugins, opts)
