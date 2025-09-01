require("conform").setup({
	formatters = {
		prettier_vue = {
			command = "prettierd",
			args = { "--plugin-search-dir=.", "--write", "--parser", "vue" },
		},
	},
	formatters_by_ft = {
		-- vue = { "prettier" }, -- Or other formatters you prefer
		-- Add other file types and their respective formatters
		lua = { "stylua" },
		python = { "black" },
		-- typescript = { "prettier" },
	},
	format_on_save = {
		timeout_ms = 500,
		async = false,
		lsp_format = "fallback", -- Use LSP formatting as a fallback
	},
})
