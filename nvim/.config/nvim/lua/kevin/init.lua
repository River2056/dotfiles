-- local install_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

local config_path = vim.fn.stdpath("config")
local java_debug_path = config_path .. "/java-debug/"
local vscode_java_test_path = config_path .. "/vscode-java-test/"
local google_java_format_path = config_path .. "/google-java-format/"
local file_seperator = package.config:sub(1, 1)

--[[ if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
	print("cloning packer...")
	vim.fn.execute("!git clone https://github.com/wbthomason/packer.nvim " .. install_path)
end ]]

if vim.fn.empty(vim.fn.glob(java_debug_path)) > 0 then
    print("cloning java-debug...")
    print("please cd into java-debug and mvnw clean install (mvnw.cmd clean install for windows)")
    vim.fn.execute("!git clone https://github.com/microsoft/java-debug.git " .. java_debug_path)
end

if vim.fn.empty(vim.fn.glob(vscode_java_test_path)) > 0 then
    print("cloning vscode-java-test...")
    print("please cd into vscode-java-test and npm install")
    vim.fn.execute("!git clone https://github.com/microsoft/vscode-java-test.git " .. vscode_java_test_path)
end

if vim.fn.empty(vim.fn.glob(google_java_format_path)) > 0 then
    print("cloning google-java-format...")
    print("please mvn install after clone")
    print("or npm install google-java-format -g to path")
    vim.fn.execute("!git clone https://github.com/google/google-java-format.git " .. google_java_format_path)
end

local home_var = os.getenv("KEVIN_NVIM_HOME")
if home_var == nil or home_var == "" then
    print("environment variable KEVIN_NVIM_HOME not set!")
    print("please set KEVIN_NVIM_HOME for nvim config to work!")
    print("e.g. on windows: C:/Users/H0268, on linux: /home/kali")
end

local path = os.getenv("path")
local mason_lsp_install_path = vim.fn.stdpath("data") .. file_seperator .. "mason" .. file_seperator .. "bin"
if path ~= nil and not path:find(mason_lsp_install_path, 1, true) then
    print("Mason LSP install path not added to PATH")
    print("please add: " .. mason_lsp_install_path .. " to PATH for lspconfig to work properly")
end
