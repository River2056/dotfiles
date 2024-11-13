require("kevin")
require("maps")
require("plugins")
-- require("kevin.tokyonight")
-- require("kevin.gruvbox-baby")
require("kevin.gruvbox")
require("kevin.lualine")
require("base")
require("abbreviations")
require("augroups")
require("functions")
require("kevin.git-blame")

local has = function(x)
	return vim.fn.has(x) == 1
end

local is_mac = has("macunix")
local is_win = has("win32")
local is_linux = has("unix")
local is_wsl = has("wsl")

if is_mac then
	require("macos")
end

if is_win then
	require("windows")
end

if is_linux then
	require("linux")
end

--[[ if is_wsl then
	require("wsl")
end ]]

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
