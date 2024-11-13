local function t(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function compileRun()
	vim.cmd('exec "w"')

	local filetype = vim.bo.filetype
	local path = vim.fn.expand("%")
	local directoryprefix = vim.fn.getcwd()
	if filetype == "java" then
		print(path)
		vim.cmd("!javac -cp src -d bin " .. path)
		print("compile success: " .. path)

		path = path:gsub(directoryprefix, ""):gsub("\\", "."):gsub("/", "."):gsub(".java", ""):gsub("src.", "")
		print(path)
		vim.cmd("!java -cp ./bin " .. path)
	elseif filetype == "javascript" then
		vim.cmd(":!node " .. path)
	elseif filetype == "sh" then
		vim.cmd(":!bash " .. path .. "<cr>")
	elseif filetype == "go" then
		vim.cmd("!go run " .. path .. "<cr>")
	elseif filetype == "c" then
		local filename = path:sub(1, #path - 2)
		vim.cmd("!gcc " .. path .. " -o " .. filename .. " && " .. filename .. ".exe")
	elseif filetype == "cpp" then
		local filename = path:sub(1, #path - 4)
		vim.cmd("!g++ " .. path .. " -o " .. filename .. " && " .. filename .. ".exe")
	elseif filetype == "rust" then
		local filename = path:sub(1, #path - 4)
		vim.cmd("!rustc " .. path .. " && " .. filename .. ".exe")
	else
		vim.cmd("!" .. filetype .. " " .. path)
	end
end

vim.keymap.set("n", "<Leader>r", ":lua compileRun()<Return>")

-- run lua filter
vim.keymap.set("v", "<Leader>r", ":'<,'>!lua<Return>")

function changeCase()
	word = vim.fn.expand("<cword>")
	if word:find("[_\\w0-9]") ~= nil then
		-- has underscore, change to camelCase
		word = word:gsub("_[a-zA-Z0-9]", function(c)
			return c:upper():gsub("_", "")
		end)
		vim.cmd("norm! ciw" .. word)
	else
		-- has no underscore, change to snake_case
		word = word:gsub("[A-Z]", function(c)
			return "_" .. c:lower()
		end)
		vim.cmd("norm! ciw" .. word)
	end
end

vim.keymap.set("n", "<Leader>cc", ":lua changeCase()<Return>")

function openTerminal()
	if vim.fn.has("win32") == 1 then
		vim.cmd("split term://powershell")
	elseif vim.fn.has("mac") == 1 then
		vim.cmd("split term://zsh")
	else
		vim.cmd("split term://bash")
	end
	vim.cmd("resize 20")
end

vim.keymap.set("n", "<Leader>`", ":lua openTerminal()<Return>")

local function exists(file)
	local ok, _, code = os.rename(file, file)
	if not ok then
		if code == 13 then
			return true
		end
	end
	return ok
end

local function isdir(path)
	return exists(path .. "/")
end

-- local directory = vim.fn.getcwd()
--[[ function exportGitBlame()
	local path = vim.fn.expand("%")
	local export_filename = path:gsub("\\", "_"):gsub("/", "_"):gsub(":", "_") .. os.time() .. ".txt"

	local cmd = "git blame "
		.. path:gsub("\\", "/")
		.. " > "
		.. directory:gsub("\\", "/")
		.. "/"
		-- .. "/.gitblame/"
		.. export_filename

	-- check .gitblame/
	local is_exists = isdir(directory .. "/.gitblame")
	if is_exists == nil then
		cmd = "!mkdir -p " .. directory:gsub("\\", "/") .. "/.gitblame/ && " .. cmd
	else
		cmd = "!" .. cmd
	end
	cmd = "!" .. cmd

	vim.cmd(cmd)
end ]]

function exportGitBlame()
	local cmd = "!git blame % > %<" .. os.time() .. ".txt"
	vim.cmd(cmd)
end

vim.keymap.set("n", "<Leader>go", ":lua exportGitBlame()<Return>")

function formatJson()
	vim.bo.filetype = "json"
	vim.cmd(t("normal gg<S-v>G:!jq<cr>"))
end

vim.keymap.set("n", "<Leader>jq", ":lua formatJson()<Return>")

function open_nvim_tree(data)
	-- buffer is a directory
	local directory = vim.fn.isdirectory(data.file) == 1

	if not directory then
		return
	end

	-- create a new, empty buffer
	-- vim.cmd.enew()

	-- wipe the directory buffer
	-- vim.cmd.bw(data.buf)

	-- change to the directory
	-- vim.cmd.cd(data.file)

	-- open the tree
	require("nvim-tree.api").tree.open()
end

function split(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

function sort()
	local startline = vim.fn.getpos("'<")
	local endline = vim.fn.getpos("'>")
	local lines = vim.fn.getline(startline[2], endline[2])

	local t = {}
	for _, v in ipairs(lines) do
		inner_t = split(v, ",")
		for _, inner_v in ipairs(inner_t) do
			table.insert(t, tonumber(inner_v))
		end
	end
	table.sort(t)

	for k, sorted in ipairs(t) do
		t[k] = tostring(sorted)
	end
	vim.api.nvim_buf_set_lines(vim.api.nvim_get_current_buf(), startline[2], endline[2], true, t)
end

vim.keymap.set("v", "<Leader>st", ":lua sort()<Return>")
