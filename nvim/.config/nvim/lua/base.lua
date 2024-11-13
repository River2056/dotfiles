local u = require("utils")

vim.opt.compatible = false
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.scriptencoding = "utf-8"

vim.opt.title = true
vim.opt.showmode = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.smartcase = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.backup = false
vim.opt.wrap = false -- no warp lines
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.scrolloff = 10
vim.opt.termguicolors = true
vim.opt.errorbells = false -- no error bells when reach bottom
vim.opt.hidden = true
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.cmd([[colorscheme gruvbox-baby]])
-- vim.cmd([[colorscheme gruvbox]])
-- vim.cmd([[colorscheme tokyonight]])
--[[ vim.g.tokyonight_transparent_sidebar = true
vim.g.tokyonight_transparent = true ]]
vim.opt.background = "dark"

vim.opt.path:append({ "**" }) -- Finding files - Search down into subdirectories
vim.opt.iskeyword:append({ "-" })

vim.cmd("au! BufWritePost $MYVIMRC source $MYVIMRC")
-- vim.cmd("au! BufReadPost *.kt setlocal filetype=kotlin")

vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
