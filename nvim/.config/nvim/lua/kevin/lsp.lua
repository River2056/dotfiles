local M = {}
local capabilities = vim.lsp.protocol.make_client_capabilities()
M.capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

function M.on_attach(client, bufnr)
    -- Create some shortcut functions.
    -- NOTE: The `vim` variable is supplied by Neovim.
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end

    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

    local opts = { noremap = true, silent = true }

    -- ======================= The Keymaps =========================
    -- jump to definition
    buf_set_keymap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)

    -- Format buffer
    buf_set_keymap("n", "<F3>", "<cmd>lua vim.lsp.buf.format()<CR>", opts)

    -- Jump LSP diagnostics
    -- NOTE: Currently, there is a bug in lspsaga.diagnostic module. Thus we use
    --       Vim commands to move through diagnostics.
    buf_set_keymap("n", "[g", ":Lspsaga diagnostic_jump_prev<CR>", opts)
    buf_set_keymap("n", "]g", ":Lspsaga diagnostic_jump_next<CR>", opts)

    -- Rename symbol
    buf_set_keymap("n", "<leader>rn", "<cmd>lua require('lspsaga.rename').rename()<CR>", opts)

    -- Find references
    buf_set_keymap("n", "gr", '<cmd>lua require("lspsaga.provider").lsp_finder()<CR>', opts)

    -- Doc popup scrolling
    buf_set_keymap("n", "K", "<cmd>lua require('lspsaga.hover').render_hover_doc()<CR>", opts)
    buf_set_keymap("n", "L", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
    buf_set_keymap("n", "H", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)

    -- codeaction
    buf_set_keymap("n", "<leader>ac", "<cmd>lua require('lspsaga.codeaction').code_action()<CR>", opts)
    buf_set_keymap("v", "<leader>a", ":<C-U>lua require('lspsaga.codeaction').range_code_action()<CR>", opts)

    -- Floating terminal
    -- NOTE: Use `vim.cmd` since `buf_set_keymap` is not working with `tnoremap...`
    vim.cmd([[
        nnoremap <silent> <A-d> <cmd>lua require('lspsaga.floaterm').open_float_terminal()<CR>
        tnoremap <silent> <A-d> <C-\><C-n>:lua require('lspsaga.floaterm').close_float_terminal()<CR>
    ]])

    -- formatting
    if client.server_capabilities.documentFormattingProvider then
        print("format " .. vim.bo.filetype)
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("Format", { clear = true }),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format()
            end,
        })
    end
end

M.servers = {
    "bashls",
    "pyright",
    "lua_ls",
    "html",
    "ts_ls",
    "jsonls",
    "vuels",
    "gopls",
    "golangci_lint_ls",
    "emmet_ls",
    "kotlin_language_server",
    "powershell_es",
    "sqlls",
    "cmake",
    "yamlls",
    "cssls",
    "rust_analyzer",
    "marksman",
    "omnisharp",
    "zls"
}

return M
