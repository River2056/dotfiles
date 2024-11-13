--[[
    in case if jdtls keeps crashing, remove the data directory from mason packages
    and rebuild again
]]
local c = require("kevin.constants")
local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_cmp_ok then
    return
end
capabilities.textDocument.completion.completionItem.snippetSupport = false
capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

-- Determine OS
local config_path = vim.fn.stdpath("config")
local home = vim.fn.stdpath("data") .. "/mason/packages"
local java_debug_path = c.java_debug_path
local vscode_java_test_path = c.vscode_java_test_path
local lombok_path = home .. "/jdtls/lombok.jar"

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>Telescope lsp_declarations<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
    vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "L",
        "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>",
        opts
    )
    vim.api.nvim_buf_set_keymap(
        bufnr,
        "n",
        "H",
        "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>",
        opts
    )
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gI", "<cmd>Telescope lsp_implementations<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    vim.cmd([[ command! Format execute 'lua vim.lsp.buf.format({ async = true })' ]])
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<F3>", "<cmd>lua vim.lsp.buf.format()<cr>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>ac", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<M-s>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ac", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "[g", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "]g", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
    -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
end

local function on_attach(client, bufnr)
    lsp_keymaps(bufnr)

    -- formatting
    if client.server_capabilities.documentFormattingProvider then
        print("format java...")
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("Format", { clear = true }),
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format()
            end,
        })
    end

    require("jdtls").setup_dap({ hotcodereplace = "auto" })
    require("jdtls.dap").setup_dap_main_class_configs()
    -- require("jdtls.setup").add_commands()
    vim.lsp.codelens.refresh()
end

if vim.fn.has("mac") == 1 then
    WORKSPACE_PATH = home .. "/workspace/"
    configuration = "mac"
elseif vim.fn.has("unix") == 1 then
    WORKSPACE_PATH = home .. "/workspace/"
    configuration = "linux"
elseif vim.fn.has("win32") == 1 then
    WORKSPACE_PATH = home .. "/workspace/"
    configuration = "win"
else
    print("Unsupported system")
end

local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local project_path_prefix = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h")
local rootdir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" })
local fix_path = rootdir:gsub(project_path_prefix, "")

--[[ print(project_path_prefix)
print(rootdir)
print(fix_path) ]]

-- local workspace_dir = WORKSPACE_PATH .. project_name
local workspace_dir = WORKSPACE_PATH .. fix_path
-- local workspace_dir = WORKSPACE_PATH .. project_path_prefix

JAVA_DAP_ACTIVE = true

local bundles = {}

if JAVA_DAP_ACTIVE then
    vim.list_extend(bundles, vim.split(vim.fn.glob(vscode_java_test_path .. "server/*.jar", 1), "\n"))
    vim.list_extend(
        bundles,
        vim.split(
            vim.fn.glob(
                java_debug_path .. "com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar", 1
            ),
            "\n"
        )
    )

    --[[ for k, v in ipairs(bundles) do
        print(v)
    end ]]
end

vim.list_extend(bundles, vim.split(vim.fn.glob(config_path .. "*.jar", 1), "\n"))
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {

        c.jdtls_java_path, -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx4g",
        "-XX:AdaptiveSizePolicyWeight=90",
        "-XX:GCTimeRatio=4",
        "-XX:+UseParallelGC",
        "-Dsun.zip.disableMemoryMapping=true",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. lombok_path,

        "-jar",
        vim.fn.glob(home .. "/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),

        "-configuration",
        home .. "/jdtls/config_" .. configuration,

        "-data",
        workspace_dir,
    },

    on_attach = on_attach,
    capabilities = capabilities,

    root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),

    settings = {
        java = {
            sources = {
                organizeImports = {
                    starThreshold = 99999,
                    staticStarThreshold = 99999
                }
            },
            project = {
                referencedLibraries = {
                    "/Users/kevintung/code/aibank-ms/tfb-nano-message-schema/build/libs/tfb-nano-message-schema-1.0.0-SNAPSHOT.jar",
                    "/Users/kevintung/code/aibank-ms/shared-components/tfb-esb-component/lib/eai.jar"
                }
            },
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    --[[ {
                        name = "JavaSE-11",
                        path = c.jdtls_jdk11_path,
                    },
                    {
                        name = "JavaSE-15",
                        path = c.jdtls_jdk15_path,
                    }, ]]
                    {
                        name = "JavaSE-17",
                        path = c.jdtls_jdk17_path,
                    },
                    --[[ {
						name = "JavaSE-1.8",
						path = c.jdtls_jdk8_path,
					}, ]]
                },
            },

            completion = {
                importOrder = {
                    "java",
                    "javax",
                    "org",
                    "com",
                },
            },
            gradle = {
                enabled = true
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all", -- literals, all, none
                },
            },
            format = {
                settings = {
                    url = "/Users/kevintung/code/aibank-ms/aibank_workspace/code-style/formatter.xml",
                    profile = "Import"

                }
            },
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        extendedClientCapabilities = extendedClientCapabilities,
        settings = {
            -- ["java.format.settings.url"] = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
            -- ["java.format.settings.profile"] = "GoogleStyle",
            ["java.format.settings.url"] = "/Users/kevintung/code/aibank-ms/aibank_workspace/code-style/formatter.xml"
        },
        codeGeneration = {
            settings = {
                url = "/Users/kevintung/code/aibank-ms/aibank_workspace/code-style/codetemplates.xml",
            }
        },
    },

    -- Language server `initializationOptions`
    -- You need to extend the `bundles` with paths to jar files
    -- if you want to use additional eclipse.jdt.ls plugins.
    --
    -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
    init_options = {
        bundles = bundles,
    },
}

vim.keymap.set("n", "<A-o>", '<Cmd>lua require"jdtls".organize_imports()<CR>')
-- vim.keymap.set("n", "crv", '<Cmd>lua require("jdtls").extract_variable()<CR>')
vim.keymap.set("v", "crv", '<Esc><Cmd>lua require("jdtls").extract_variable(true)<CR>')
-- vim.keymap.set("n", "crc", '<Cmd>lua require("jdtls").extract_constant()<CR>')
vim.keymap.set("v", "crc", '<Esc><Cmd>lua require("jdtls").extract_constant(true)<CR>')
vim.keymap.set("v", "crm", '<Esc><Cmd>lua require("jdtls").extract_method(true)<CR>')

-- If using nvim-dap
-- This requires java-debug and vscode-java-test bundles, see install steps in this README further below.
vim.keymap.set("n", "<Leader>df", '<Cmd>lua require"jdtls".test_class()<CR>')
vim.keymap.set("n", "<Leader>dn", '<Cmd>lua require"jdtls".test_nearest_method()<CR>')
vim.keymap.set("n", "<F1>", ":DapContinue<CR>")
vim.keymap.set("n", "<Leader>de", ":DapTerminate<CR>")

vim.cmd(
    "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
)
vim.cmd(
    "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)"
)
vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")

local dap = require("dap")
dap.configurations.java = {
    {
        type = "java",
        request = "attach",
        name = "Debug (Attach) - Remote",
        hostName = "127.0.0.1",
        port = c.jdtls_debug_port,
        javaExec = c.jdtls_java_path,
    },
}

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
-- require("jdtls").start_or_attach(config)
require("jdtls").start_or_attach(config)
