local c = require("kevin.constants")
local lsp = require("kevin.lsp")
local nvim_lsp = require("lspconfig")
local util = require("lspconfig.util")
local protocol = require("vim.lsp.protocol")

protocol.CompletionItemKind = {
    "", -- Text
    "", -- Method
    "", -- Function
    "", -- Constructor
    "", -- Field
    "", -- Variable
    "", -- Class
    "ﰮ", -- Interface
    "", -- Module
    "", -- Property
    "", -- Unit
    "", -- Value
    "", -- Enum
    "", -- Keyword
    "﬌", -- Snippet
    "", -- Color
    "", -- File
    "", -- Reference
    "", -- Folder
    "", -- EnumMember
    "", -- Constant
    "", -- Struct
    "", -- Event
    "ﬦ", -- Operator
    "", -- TypeParameter
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = false,
    virtual_text = { spacing = 4, prefix = "●" },
    severity_sort = true,
})

-- Diagnostic symbols in the sign column (gutter)
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
    virtual_text = {
        prefix = "●",
    },
    update_in_insert = true,
    float = {
        source = "always", -- Or "if_many"
    },
})

-- common lsp configs
for _, server in ipairs(lsp.servers) do
    local opts = {
        on_attach = lsp.on_attach,
        capabilities = lsp.capabilities,
    }

    -- non linux/mac system, will return \ or \\
    if package.config:sub(1, 1) ~= "/" then
        if server == "cmake" then
            opts["cmd"] = { "cmake-language-server" }
        end

        if server == "kotlin_language_server" then
            opts["cmd"] = { "kotlin-language-server" }
        end

        if server == "powershell_es" then
            opts = { bundle_path = c.powershell_es_path }
        end
    end

    nvim_lsp[server].setup(opts)
end

-- specific additional configs per language
local libs = vim.api.nvim_get_runtime_file("", true)
table.insert(libs, "${3rd}/love2d/library")
nvim_lsp.lua_ls.setup({
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
    settings = {
        Lua = {
            diagnostics = {
                -- Get the language server to recognize the `vim` global
                globals = { "vim" },
            },

            workspace = {
                -- Make the server aware of Neovim runtime files
                library = libs,
                checkThirdParty = false,
            },
        },
    },
})

nvim_lsp.ts_ls.setup({
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
    filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
    },
    cmd = { "typescript-language-server", "--stdio" },
    root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git") or vim.loop.cwd(),
})

--[[ nvim_lsp.eslint.setup({
    -- cmd = { "vscode-eslint-language-server", "--stdio" },
    cmd = { "eslint_d", "--stdio" },
    filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue", "svelte", "astro" },
    on_attach = function(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
}) ]]

-- local htmlFormatter = lsp.capabilities
--[[ htmlFormatter["html.format.wrapLineLength"] = 180
htmlFormatter["html.format.wrapAttributes"] = "aligned-multiple" ]]
nvim_lsp.html.setup({
    cmd = { "vscode-html-language-server", "--stdio" },
    settings = {
        html = {
            format = {
                wrapLineLength = 180,
                wrapAttributes = 'aligned-multiple'
            }
        }
    },
    filetypes = { "html", "templ" },
    init_options = {
        configurationSection = { "html", "css" },
        embeddedLanguages = {
            html = true,
            css = true,
            javascript = false
        },
        provideFormatter = true,
    },
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
})

-- servers that lspconfig supports but mason doesn't have
nvim_lsp.ccls.setup({
    on_attach = lsp.on_attach,
    capabilities = lsp.capabilities,
})

local pid = vim.fn.getpid()
local mason_path = vim.fn.stdpath("data") .. "/mason/bin"
nvim_lsp.omnisharp.setup({
    handlers = {
        ["textDocument/definition"] = require("omnisharp_extended").handler,
    },
    cmd = { mason_path .. "/omnisharp", "--languageserver", "--hostPID", tostring(pid) },
    -- Enables support for reading code style, naming convention and analyzer
    -- settings from .editorconfig.
    enable_editorconfig_support = true,

    -- If true, MSBuild project system will only load projects for files that
    -- were opened in the editor. This setting is useful for big C# codebases
    -- and allows for faster initialization of code navigation features only
    -- for projects that are relevant to code that is being edited. With this
    -- setting enabled OmniSharp may load fewer projects and may thus display
    -- incomplete reference lists for symbols.
    enable_ms_build_load_projects_on_demand = false,

    -- Enables support for roslyn analyzers, code fixes and rulesets.
    enable_roslyn_analyzers = false,

    -- Specifies whether 'using' directives should be grouped and sorted during
    -- document formatting.
    organize_imports_on_format = false,

    -- Enables support for showing unimported types and unimported extension
    -- methods in completion lists. When committed, the appropriate using
    -- directive will be added at the top of the current file. This option can
    -- have a negative impact on initial completion responsiveness,
    -- particularly for the first few completion sessions after opening a
    -- solution.
    enable_import_completion = false,

    -- Specifies whether to include preview versions of the .NET SDK when
    -- determining which version to use for project loading.
    sdk_include_prereleases = true,

    -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
    -- true
    analyze_open_documents_only = false,
})
