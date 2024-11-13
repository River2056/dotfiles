-- vim.opt.t_Co = 256
vim.opt.clipboard:append({ "unnamedplus" })

local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

-- Move to previous/next
map("n", "≤", "<Cmd>BufferPrevious<CR>", opts)
map("n", "≥", "<Cmd>BufferNext<CR>", opts)
-- Re-order to previous/next
map("n", "¯", "<Cmd>BufferMovePrevious<CR>", opts)
map("n", "˘", "<Cmd>BufferMoveNext<CR>", opts)
-- Goto buffer in position...
map("n", "¡", "<Cmd>BufferGoto 1<CR>", opts)
map("n", "™", "<Cmd>BufferGoto 2<CR>", opts)
map("n", "£", "<Cmd>BufferGoto 3<CR>", opts)
map("n", "¢", "<Cmd>BufferGoto 4<CR>", opts)
map("n", "∞", "<Cmd>BufferGoto 5<CR>", opts)
map("n", "§", "<Cmd>BufferGoto 6<CR>", opts)
map("n", "¶", "<Cmd>BufferGoto 7<CR>", opts)
map("n", "•", "<Cmd>BufferGoto 8<CR>", opts)
map("n", "ª", "<Cmd>BufferGoto 9<CR>", opts)
map("n", "º", "<Cmd>BufferLast<CR>", opts)
-- Pin/unpin buffer
map("n", "π", "<Cmd>BufferPin<CR>", opts)
-- Close buffer
map("n", "ç", "<Cmd>BufferClose<CR>", opts)
