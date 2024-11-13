vim.cmd([[au! BufWritePost *.py :lua vim.lsp.buf.format()]])
