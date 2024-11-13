local status, packer = pcall(require, "packer")
if not status then
	print("Packer is not installed")
	return
end

vim.cmd([[packadd packer.nvim]])

packer.startup(function(use)
	use("wbthomason/packer.nvim")
	use("nvim-lua/plenary.nvim") -- Common utilities
	use("kyazdani42/nvim-tree.lua")
	use("kyazdani42/nvim-web-devicons") -- File icons
	use("nvim-telescope/telescope.nvim")
	use("nvim-telescope/telescope-ui-select.nvim")
	use("nvim-telescope/telescope-file-browser.nvim")
	use("simrat39/symbols-outline.nvim")
	use("norcalli/nvim-colorizer.lua")
	use("kylechui/nvim-surround")
	use("b3nj5m1n/kommentary")
	use("ThePrimeagen/harpoon")

	-- neogit
	use({
		"TimUntersberger/neogit",
		requires = {
			"nvim-lua/plenary.nvim",
			"sindrets/diffview.nvim",
		},
	})
	use("f-person/git-blame.nvim")
	use("vim-scripts/auto-pairs-gentle") -- bracket autocompletion

	-- Fancier statusline
	use({
		"nvim-lualine/lualine.nvim",
		requires = {
			"kyazdani42/nvim-web-devicons",
			"arkav/lualine-lsp-progress",
		},
	})

	-- LSP Client
	use("neovim/nvim-lspconfig")
	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
	})
	-- Language Server installer
	use("williamboman/mason.nvim")
	use("williamboman/mason-lspconfig.nvim")
	use("WhoIsSethDaniel/mason-tool-installer.nvim")
	use("MunifTanjim/prettier.nvim")

	-- Customizations over LSP
	-- Show VSCode-esque pictograms
	use("onsails/lspkind-nvim")
	-- show various elements of LSP as UI
	use({ "tami5/lspsaga.nvim", requires = { "neovim/nvim-lspconfig" } })

	-- Autocompletion plugin
	use({
		"hrsh7th/nvim-cmp",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
	})

	-- snippets
	use({
		"hrsh7th/cmp-vsnip",
		requires = {
			"hrsh7th/vim-vsnip",
			"rafamadriz/friendly-snippets",
		},
	})

	use("mfussenegger/nvim-jdtls")
	use("jose-elias-alvarez/null-ls.nvim") -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua
	-- Debugging
	use("mfussenegger/nvim-dap")
	use("rcarriga/nvim-dap-ui")
	use({ "nvim-treesitter/nvim-treesitter", run = "TSUpdate" })
	use({ "NTBBloodbath/rest.nvim", requires = { "nvim-lua/plenary.nvim" } })
	use("andreshazard/vim-freemarker")

	-- colorschemes
	use("folke/tokyonight.nvim")
	-- use("morhetz/gruvbox")
	use({ "ellisonleao/gruvbox.nvim" })
	use("luisiacc/gruvbox-baby")
	use("windwp/nvim-ts-autotag")
	-- install without yarn or npm
	use({
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})
	use({
		"scalameta/nvim-metals",
		requires = {
			"nvim-lua/plenary.nvim",
			"mfussenegger/nvim-dap",
		},
	})
	use({ "romgrk/barbar.nvim", wants = "nvim-web-devicons" })
	use("mbbill/undotree")
	use("https://gitlab.com/schrieveslaach/sonarlint.nvim")
end)
