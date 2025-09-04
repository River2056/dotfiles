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

local function set_python_path(path)
    local clients = vim.lsp.get_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        name = "basedpyright",
    })
    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python = vim.tbl_deep_extend("force", client.settings.python or {}, { pythonPath = path })
        else
            client.config.settings =
                vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
        end
        client.notify("workspace/didChangeConfiguration", { settings = nil })
    end
end

--[[ nvim_lsp.basedpyright.setup({
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
    },
    settings = {
        basedpyright = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
                typeCheckingMode = "standard", -- ["off", "basic", "standard", "strict"]
            },
        },
    },
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightOrganizeImports", function()
            client:exec_cmd({
                command = "basedpyright.organizeimports",
                arguments = { vim.uri_from_bufnr(bufnr) },
            })
        end, {
            desc = "Organize Imports",
        })

        vim.api.nvim_buf_create_user_command(bufnr, "LspPyrightSetPythonPath", set_python_path, {
            desc = "Reconfigure basedpyright with the provided python path",
            nargs = 1,
            complete = "file",
        })
    end,
}) ]]

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

--[[ nvim_lsp.ts_ls.setup({
	-- on_attach = lsp.on_attach,
	init_options = { hostInfo = "neovim" },
	filetypes = {
		"javascript",
		"javascriptreact",
		"javascript.jsx",
		"typescript",
		"typescriptreact",
		"typescript.tsx",
	},
	cmd = { "typescript-language-server", "--stdio" },
	root_dir = function(bufnr, on_dir)
		-- The project root is where the LSP can be started from
		-- As stated in the documentation above, this LSP supports monorepos and simple projects.
		-- We select then from the project root, which is identified by the presence of a package
		-- manager lock file.
		local root_markers =
			{ "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock", "package.json" }
		-- Give the root markers equal priority by wrapping them in a table
		root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers } or root_markers
		local project_root = vim.fs.root(bufnr, root_markers)
		if not project_root then
			return
		end

		-- on_dir(project_root)
		return project_root
	end,
	handlers = {
		-- handle rename request for certain code actions like extracting functions / types
		["_typescript.rename"] = function(_, result, ctx)
			local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
			vim.lsp.util.show_document({
				uri = result.textDocument.uri,
				range = {
					start = result.position,
					["end"] = result.position,
				},
			}, client.offset_encoding)
			vim.lsp.buf.rename()
			return vim.NIL
		end,
	},
	commands = {
		["editor.action.showReferences"] = function(command, ctx)
			local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
			local file_uri, position, references = unpack(command.arguments)

			local quickfix_items = vim.lsp.util.locations_to_items(references, client.offset_encoding)
			vim.fn.setqflist({}, " ", {
				title = command.title,
				items = quickfix_items,
				context = {
					command = command,
					bufnr = ctx.bufnr,
				},
			})

			vim.lsp.util.show_document({
				uri = file_uri,
				range = {
					start = position,
					["end"] = position,
				},
			}, client.offset_encoding)

			vim.cmd("botright copen")
		end,
	},
	on_attach = function(client, bufnr)
		-- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
		-- `vim.lsp.buf.code_action()` if specified in `context.only`.
		vim.api.nvim_buf_create_user_command(bufnr, "LspTypescriptSourceAction", function()
			local source_actions = vim.tbl_filter(function(action)
				return vim.startswith(action, "source.")
			end, client.server_capabilities.codeActionProvider.codeActionKinds)

			vim.lsp.buf.code_action({
				context = {
					only = source_actions,
				},
			})
		end, {})
	end,
}) ]]

-- If you are using mason.nvim, you can get the ts_plugin_path like this
-- For Mason v1,
-- local mason_registry = require('mason-registry')
-- local vue_language_server_path = mason_registry.get_package('vue-language-server'):get_install_path() .. '/node_modules/@vue/language-server'
-- For Mason v2,
-- local vue_language_server_path = vim.fn.expand '$MASON/packages' .. '/vue-language-server' .. '/node_modules/@vue/language-server'
-- or even
-- local vue_language_server_path = vim.fn.stdpath('data') .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

-- IMPORTANT: nvchad users cannot use `$MASON` directly as the option is set to `skip`, see: https://github.com/NvChad/NvChad/blob/29ebe31ea6a4edf351968c76a93285e6e108ea08/lua/nvchad/configs/mason.lua#L4

local vue_language_server_path = "/Users/kevintung/.nvm/versions/node/v23.8.0/bin/vue-language-server"
local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
    name = "@vue/typescript-plugin",
    location = vue_language_server_path,
    languages = { "vue" },
    configNamespace = "typescript",
}
local vtsls_config = {
    settings = {
        vtsls = {
            tsserver = {
                globalPlugins = {
                    vue_plugin,
                },
            },
        },
        vue = {
            format = {
                enable = true,
                options = {
                    printWidth = 120,
                    singleQuote = true,
                    trailingComma = "none",
                    tabWidth = 2,
                    useTabs = false,
                    bracketSpacing = true,
                    arrowParens = "always",
                    htmlWhitespaceSensitivity = "strict",
                    endOfLine = "lf",
                    semi = true,
                    quoteProps = "as-needed",
                    plugins = { "prettier-plugin-organize-imports" },
                    overrides = {
                        {
                            files = "*.vue",
                            options = {
                                parser = "vue",
                                printWidth = 200,
                                vueIndentScriptAndStyle = true,
                            },
                        },
                        {
                            files = "*.[m]js",
                            options = {
                                parser = "babel",
                            },
                        },
                        {
                            files = ".prettierrc.ts",
                            options = {
                                parser = "typescript",
                            },
                        },
                        {
                            files = "*.messages.ts",
                            options = {
                                parser = "typescript",
                                printWidth = 800,
                                semi = true,
                            },
                        },
                        {
                            files = "*.ts",
                            options = {
                                parser = "typescript",
                                semi = true,
                            },
                        },
                        {
                            files = "*.html",
                            options = {
                                parser = "html",
                                printWidth = 1000,
                                bracketSameLine = true,
                                singleAttributePerLine = false,
                            },
                        },
                        {
                            files = "*.cjs",
                            options = {
                                parser = "babel",
                            },
                        },
                        {
                            files = "*.json",
                            options = {
                                parser = "json",
                            },
                        },
                        {
                            files = "*.md",
                            options = {
                                parser = "markdown",
                            },
                        },
                    },
                },
            },
        },
    },
    filetypes = tsserver_filetypes,
}

local function get_diagnostic_at_cursor()
    local cur_buf = api.nvim_get_current_buf()
    local line, col = unpack(api.nvim_win_get_cursor(0))
    local entrys = diagnostic.get(cur_buf, { lnum = line - 1 })
    local res = {}
    for _, v in pairs(entrys) do
        if v.col <= col and v.end_col >= col then
            table.insert(res, {
                code = v.code,
                message = v.message,
                range = {
                    ["start"] = {
                        character = v.col,
                        line = v.lnum,
                    },
                    ["end"] = {
                        character = v.end_col,
                        line = v.end_lnum,
                    },
                },
                severity = v.severity,
                source = v.source or nil,
            })
        end
    end
    return res
end

local ts_ls_config = {
    init_options = {
        hostInfo = "neovim",
        plugins = {
            vue_plugin,
        },
    },
    filetypes = tsserver_filetypes,
    cmd = { "typescript-language-server", "--stdio" },
    on_attach = lsp.on_attach,
}

-- If you are on most recent `nvim-lspconfig`
local vue_ls_config = {
    on_init = function(client)
        client.handlers["tsserver/request"] = function(_, result, context)
            local ts_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "ts_ls" })
            local vtsls_clients = vim.lsp.get_clients({ bufnr = context.bufnr, name = "vtsls" })
            local clients = {}

            vim.list_extend(clients, ts_clients)
            vim.list_extend(clients, vtsls_clients)

            if #clients == 0 then
                vim.notify(
                    "Could not find `vtsls` or `ts_ls` lsp client, `vue_ls` would not work without it.",
                    vim.log.levels.ERROR
                )
                return
            end
            local ts_client = clients[1]

            local param = unpack(result)
            local id, command, payload = unpack(param)
            ts_client:exec_cmd({
                title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
                command = "typescript.tsserverRequest",
                arguments = {
                    command,
                    payload,
                },
            }, { bufnr = context.bufnr }, function(_, r)
                local response = r and r.body
                -- TODO: handle error or response nil here, e.g. logging
                -- NOTE: Do NOT return if there's an error or no response, just return nil back to the vue_ls to prevent memory leak
                local response_data = { { id, response } }

                ---@diagnostic disable-next-line: param-type-mismatch
                client:notify("tsserver/response", response_data)
            end)
        end
    end,
}
-- nvim 0.11 or above
vim.lsp.config("vtsls", vtsls_config)
vim.lsp.config("vue_ls", vue_ls_config)
vim.lsp.config("ts_ls", ts_ls_config)
vim.lsp.enable({ "ts_ls", "vue_ls" }) -- If using `ts_ls` replace `vtsls` to `ts_ls`

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
                wrapAttributes = "aligned-multiple",
            },
        },
    },
    filetypes = { "html", "templ" },
    init_options = {
        configurationSection = { "html", "css" },
        embeddedLanguages = {
            html = true,
            css = true,
            javascript = false,
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
