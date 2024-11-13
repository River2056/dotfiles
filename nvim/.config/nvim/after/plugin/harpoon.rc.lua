require("harpoon").setup({})

-- harpoon
vim.keymap.set("n", "<Leader>hh", ':lua require("harpoon.ui").toggle_quick_menu()<Return>')
vim.keymap.set("n", "<Leader>ha", ':lua require("harpoon.mark").add_file()<Return>')
vim.keymap.set("n", "<Leader>hn", ':lua require("harpoon.ui").nav_next()<Return>')
vim.keymap.set("n", "<Leader>hp", ':lua require("harpoon.ui").nav_prev()<Return>')
vim.keymap.set("n", "<Leader>hq", ':lua require("harpoon.ui").nav_file(1)<Return>')
vim.keymap.set("n", "<Leader>hw", ':lua require("harpoon.ui").nav_file(2)<Return>')
vim.keymap.set("n", "<Leader>he", ':lua require("harpoon.ui").nav_file(3)<Return>')
vim.keymap.set("n", "<Leader>hr", ':lua require("harpoon.ui").nav_file(4)<Return>')
