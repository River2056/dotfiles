local ft = require("guard.filetype")

-- ft("python"):fmt("black")
-- ft("lua"):fmt("lsp"):append("stylua")
ft("typescript,javascript,typescriptreact,vue,json,jsonc"):fmt("prettier")
-- ft("typescript,typescriptreact"):fmt("eslint_d")
-- ft("typescript,typescriptreact"):lint("eslint_d")
-- ft('html'):fmt('html-lsp')
-- ft('html'):fmt("lsp"):append("prettier")
ft("cs"):fmt("lsp"):append("csharpier")
ft("c"):fmt("lsp"):append("clang-format")
ft("cpp"):fmt("lsp"):append("clang-format")
ft("go"):fmt("gofumpt")
ft("zig"):fmt("zigfmt")
-- ft("rs"):fmt("rustfmt")

vim.g.guard_config = {
    -- the only options for the setup function
    fmt_on_save = true,
    -- Use lsp if no formatter was defined for this filetype
    lsp_as_default_formatter = false,
}
