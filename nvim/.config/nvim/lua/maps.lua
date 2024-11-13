local keymap = vim.keymap

-- leader key
vim.g.mapleader = " "

-- quick escape from insert mode
keymap.set("i", "jk", "<Escape>")
keymap.set("i", "kj", "<Escape>")
-- terminal
keymap.set("t", "jk", "<C-\\><C-n>")
keymap.set("t", "kj", "<C-\\><C-n>")

keymap.set("n", "<Leader>aa", ":%y+<Return>")
keymap.set("n", "<Leader>ss", ":w<Return>")
-- keymap.set("n", "<Space>", "za")
keymap.set("n", "<Leader>ev", ":Hex! C:/Users/H0268/AppData/Local/nvim/<Return>")
keymap.set("n", "<Leader>sv", ":source $MYVIMRC<Return>")
keymap.set("n", "<Leader>o", ":Ex<Return>")
keymap.set("n", "<Leader><Space>", ":noh<Return>")
keymap.set("n", "<Leader>q", ":q<Return>")
keymap.set("n", "<Leader>zq", ":bd!<Return>")
-- paste stuff from previously copied
keymap.set("v", "<Leader>p", '"_dP')
keymap.set("n", "<Leader>mk", ":mksession! temp.vim<Return>")

-- delete char don't go into clipboard
keymap.set("n", "x", '"_x')

-- increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Delete a word backwards
keymap.set("n", "dw", 'vb"_d')

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- New tab
keymap.set("n", "te", ":tabedit<Return>")
keymap.set("n", "tc", ":tabc<Return>")
-- Switch between tabs
keymap.set("n", "<Leader><Tab>", ":tabn<Return>")
keymap.set("n", "<Leader><S-Tab>", ":tabp<Return>")
-- diff
keymap.set("n", "<Leader>dtt", ":diffthis<Return>")
keymap.set("n", "<Leader>dff", ":diffoff<Return>")
keymap.set("n", "<Leader>vba", ":vert ba<Return>") -- vertical all tabs

-- Buffers
keymap.set("n", "<Leader>nb", ":enew<Return>")
keymap.set("n", "<Leader>bn", ":bnext<Return>")
keymap.set("n", "<Leader>bp", ":bprevious<Return>")
keymap.set("n", "<Leader>bd", ":bdelete<Return>")
keymap.set("n", "<Leader>bda", ":%bd<Bar>e#<Return>") -- delete all buffers except current
keymap.set("n", "<Leader>ls", ":ls<Return>")          -- list all buffers

-- Split window
keymap.set("n", "ss", ":split<Return><C-w>w")
keymap.set("n", "sv", ":vsplit<Return><C-w>h")
-- Move window
keymap.set("", "<C-h>", "<C-w>h")
keymap.set("", "<C-j>", "<C-w>j")
keymap.set("", "<C-k>", "<C-w>k")
keymap.set("", "<C-l>", "<C-w>l")

-- Resize window
keymap.set("n", "<M-h>", "<C-w><")
keymap.set("n", "<M-l>", "<C-w>>")
keymap.set("n", "<M-k>", "<C-w>+")
keymap.set("n", "<M-j>", "<C-w>-")

-- Visual indent
keymap.set("v", ">", ">gv")
keymap.set("v", "<", "<gv")

-- Visual move line
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Neogit
keymap.set("n", "<Leader>gs", ":Neogit<Return>")
keymap.set("n", "<Leader>dg", ":diffget<Return>")

-- autopairs
vim.g.AutoPairs = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ["'"] = "'",
    ['"'] = '"',
    ["`"] = "`",
    -- ["<"] = ">",
}

-- Markdown preview
keymap.set("n", "<Leader>mp", "<Plug>MarkdownPreviewToggle")

-- Presenting keymaps
keymap.set("n", "<Leader>pp", ":PresentingStart<Return>")

keymap.set("n", "<Leader>ll", "!love .")

-- Oil
keymap.set("n", "-", "<CMD>Oil<Return>", { desc = "Open parent directory" })

-- Noice
keymap.set("n", "<Leader>n", "<cmd>Noice<Return>")
keymap.set("n", "<Leader>nd", "<cmd>NoiceDismiss<Return>")
keymap.set("n", "<Leader>\\", "<cmd>ToggleTerm<Return>")
