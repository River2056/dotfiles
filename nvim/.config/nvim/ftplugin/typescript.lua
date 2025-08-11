-- Define a function to organize imports
local function organize_imports()
	local params = {
		command = "_typescript.organizeImports",
		arguments = { vim.api.nvim_buf_get_name(0) },
		title = "",
	}

	local clients = vim.lsp.get_clients({ name = "ts_ls" })
	if #clients == 0 then
		vim.notify("No ts_ls client found", vim.log.levels.ERROR)
		return
	end
	local client = clients[1]
	client:exec_cmd(params)
	vim.notify("Imports sorted", vim.log.levels.INFO)
end

-- Add a custom command (e.g., :OrganizeImports)
vim.api.nvim_create_user_command("OrganizeImports", organize_imports, { desc = "Organize Imports" })
