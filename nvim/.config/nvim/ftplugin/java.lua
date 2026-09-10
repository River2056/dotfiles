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
    require("kevin.lsp_request_progress").setup({
        bufnr = bufnr,
        client_name = "jdtls",
        delay_ms = 300,
        title = "JDTLS",
        messages = {
            ["textDocument/definition"] = "Go to definition is still running...",
            ["textDocument/declaration"] = "Go to declaration is still running...",
            ["textDocument/implementation"] = "Go to implementation is still running...",
            ["textDocument/references"] = "Find references is still running...",
        },
    })

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

    -- Preserve automatic hot-code replacement. setup_dap() is idempotent;
    -- nvim-jdtls provides lazy main-class discovery through its DAP provider.
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
end

local workspace_path
local configuration
if vim.fn.has("mac") == 1 then
    workspace_path = home .. "/workspace"
    configuration = "mac"
elseif vim.fn.has("unix") == 1 then
    workspace_path = home .. "/workspace"
    configuration = "linux"
elseif vim.fn.has("win32") == 1 then
    workspace_path = home .. "/workspace"
    configuration = "win"
else
    print("Unsupported system")
    return
end

local function find_project_root(bufnr)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local git_root = vim.fs.root(filename, { ".git" })

    if git_root then
        for name, type in vim.fs.dir(git_root) do
            if type == "directory" and name:match("_workspace$") then
                local aggregate_root = vim.fs.joinpath(git_root, name)
                if vim.fn.filereadable(vim.fs.joinpath(aggregate_root, "settings.gradle")) == 1 then
                    -- The aggregate build includes sibling projects outside its own
                    -- directory. Use the repository as the Eclipse workspace root so
                    -- JDTLS does not delete those projects on the next startup.
                    return git_root, aggregate_root
                end
            end
        end
    end

    return vim.fs.root(filename, { "settings.gradle", "settings.gradle.kts", "gradlew", "mvnw", ".git" })
end

local rootdir, aggregate_root = find_project_root(0)
if not rootdir then
    vim.notify("Unable to determine the Java project root", vim.log.levels.ERROR)
    return
end

local import_exclusions
if aggregate_root then
    import_exclusions = {
        rootdir .. "/**",
        "!" .. aggregate_root,
    }
end

local project_name = vim.fn.fnamemodify(rootdir, ":t")
local workspace_id = project_name .. "-" .. vim.fn.sha256(rootdir):sub(1, 12)
local workspace_dir = vim.fs.joinpath(workspace_path, workspace_id)

JAVA_DAP_ACTIVE = true

local bundles = {}

local function append_jars(pattern, excluded_filenames)
    for _, bundle in ipairs(vim.fn.glob(pattern, true, true)) do
        local filename = vim.fs.basename(bundle)
        if not excluded_filenames or not excluded_filenames[filename] then
            table.insert(bundles, bundle)
        end
    end
end

if JAVA_DAP_ACTIVE then
    append_jars(vscode_java_test_path .. "server/*.jar", {
        ["com.microsoft.java.test.runner-jar-with-dependencies.jar"] = true,
        ["jacocoagent.jar"] = true,
    })
    append_jars(java_debug_path .. "com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")

    --[[ for k, v in ipairs(bundles) do
        print(v)
    end ]]
end

append_jars(vim.fs.joinpath(config_path, "*.jar"))
-- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
local config = {
    -- name = "jdtls",
    -- The command that starts the language server
    -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
    cmd = {

        c.jdtls_java_path, -- or '/path/to/java17_or_newer/bin/java'
        -- depends on if `java` is in your $PATH env variable and if it points to the right version.

        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=false",
        "-Dlog.level=INFO",
        "-Xmx4g",
        -- JDTLS's launcher defaults to a 1 GiB initial heap. Large aggregate
        -- workspaces otherwise fill the small old generation and pause to grow it.
        "-Xms1g",
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

    root_dir = rootdir,

    settings = {
        java = {
            sources = {
                organizeImports = {
                    starThreshold = 99999,
                    staticStarThreshold = 99999,
                },
            },
            project = {
                referencedLibraries = {
                    --[[ "/Users/kevintung/code/aibank-ms/tfb-nano-message-schema/build/libs/tfb-nano-message-schema-1.0.0-SNAPSHOT.jar",
                    "/Users/kevintung/code/aibank-ms/shared-components/tfb-esb-component/lib/eai.jar", ]]
                },
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
                    {
                        name = "JavaSE-21",
                        path = c.jdtls_jdk21_path,
                        default = true,
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
                enabled = true,
            },
            -- Aggregate Gradle workspaces are large enough that background
            -- autobuilds can compete with navigation and indexing requests.
            autobuild = {
                enabled = aggregate_root == nil,
            },
            maxConcurrentBuilds = 1,
            import = {
                exclusions = import_exclusions,
                gradle = {
                    -- The aggregate build has unresolved root annotation-processor
                    -- dependencies. Skip JDTLS's APT model so project import can finish.
                    annotationProcessing = {
                        enabled = false,
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = false,
            },
            referencesCodeLens = {
                enabled = false,
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
                    profile = "Import",
                },
            },
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        extendedClientCapabilities = extendedClientCapabilities,
        settings = {
            --[[ ["java.format.settings.url"] =
            "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml", ]]
            -- ["java.format.settings.profile"] = "GoogleStyle",
            ["java.format.settings.url"] = "/Users/kevintung/code/aibank-ms/aibank_workspace/code-style/formatter.xml",
        },
        codeGeneration = {
            settings = {
                url = "/Users/kevintung/code/aibank-ms/aibank_workspace/code-style/codetemplates.xml",
            },
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
        -- Import-affecting settings must be sent with initialize. Sending them
        -- only through didChangeConfiguration is too late for the first import.
        settings = {
            java = {
                configuration = {
                    runtimes = {
                        {
                            name = "JavaSE-17",
                            path = c.jdtls_jdk17_path,
                        },
                        {
                            name = "JavaSE-21",
                            path = c.jdtls_jdk21_path,
                            default = true,
                        },
                    },
                },
                import = {
                    exclusions = import_exclusions,
                    gradle = {
                        annotationProcessing = {
                            enabled = false,
                        },
                    },
                },
            },
        },
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

-- jdtls wipe and restart
local function normalize_path(path)
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function get_jdtls_data_dir(client)
    local cmd = client.config.cmd

    if type(cmd) ~= "table" then
        return nil
    end

    for index, argument in ipairs(cmd) do
        if argument == "-data" or argument == "--data" then
            return cmd[index + 1]
        end
    end

    return nil
end

local function is_safe_workspace_dir(data_dir)
    local workspace_root = normalize_path(vim.fn.stdpath("data") .. "/mason/packages/workspace")
    local normalized_data_dir = normalize_path(data_dir)

    return normalized_data_dir:sub(1, #workspace_root + 1) == workspace_root .. "/"
end

local function same_root(left, right)
    if not left or not right then
        return false
    end

    return normalize_path(left) == normalize_path(right)
end

local function safe_wipe_data_and_restart()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({
        bufnr = bufnr,
        name = "jdtls",
    })

    if #clients == 0 then
        vim.notify("No JDTLS client is attached to this buffer", vim.log.levels.ERROR)
        return
    end

    if #clients > 1 then
        vim.notify("Multiple JDTLS clients are attached; restart aborted", vim.log.levels.ERROR)
        return
    end

    local client = clients[1]
    local data_dir = get_jdtls_data_dir(client)

    if not data_dir then
        vim.notify("Unable to determine the JDTLS data directory", vim.log.levels.ERROR)
        return
    end

    if not is_safe_workspace_dir(data_dir) then
        vim.notify("Refusing to delete unexpected JDTLS data directory: " .. data_dir, vim.log.levels.ERROR)
        return
    end

    local client_config = client.config
    local root_dir = client.config.root_dir
    local attached_buffers = vim.lsp.get_buffers_by_client_id(client.id)

    vim.ui.select({ "Yes", "No" }, {
        prompt = "Wipe and restart JDTLS workspace: " .. data_dir .. "? ",
    }, function(choice)
        if choice ~= "Yes" then
            return
        end

        vim.schedule(function()
            client:stop()

            local stopped = vim.wait(30000, function()
                return vim.lsp.get_client_by_id(client.id) == nil
            end, 100)

            if not stopped then
                vim.notify(
                    "JDTLS did not stop within 30 seconds; workspace was not deleted and restart was aborted",
                    vim.log.levels.ERROR
                )
                return
            end

            for _, other_client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
                if same_root(other_client.config.root_dir, root_dir) then
                    vim.notify(
                        "Another JDTLS client still owns this project; workspace was not deleted",
                        vim.log.levels.ERROR
                    )
                    return
                end
            end

            if vim.fn.delete(data_dir, "rf") ~= 0 then
                vim.notify("Failed to delete JDTLS workspace: " .. data_dir, vim.log.levels.ERROR)
                return
            end

            local new_client_id = vim.lsp.start(client_config, { bufnr = bufnr })

            if not new_client_id then
                vim.notify("JDTLS workspace was removed, but restart failed", vim.log.levels.ERROR)
                return
            end

            for _, buffer in ipairs(attached_buffers) do
                if vim.api.nvim_buf_is_valid(buffer) then
                    vim.lsp.buf_attach_client(buffer, new_client_id)
                end
            end
        end)
    end)
end

vim.api.nvim_buf_create_user_command(0, "JdtSafeWipeDataAndRestart", safe_wipe_data_and_restart, {
    desc = "Safely wipe the current JDTLS workspace and restart",
    force = true,
})

vim.keymap.set("n", "<Leader>jkl", "<Cmd>JdtSafeWipeDataAndRestart<CR>", {
    buffer = true,
    silent = true,
})

-- This starts a new client & server,
-- or attaches to an existing client & server depending on the `root_dir`.
-- require("jdtls").start_or_attach(config)
require("jdtls").start_or_attach(config)
