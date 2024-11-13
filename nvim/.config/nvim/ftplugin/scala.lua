local map = vim.keymap.set

map("n", "gd", function()
	vim.lsp.buf.definition()
end)

map("n", "K", function()
	vim.lsp.buf.hover()
end)

map("n", "gI", function()
	vim.lsp.buf.implementation()
end)

map("n", "gr", function()
	vim.lsp.buf.references()
end)

map("n", "gds", function()
	vim.lsp.buf.document_symbol()
end)

map("n", "gws", function()
	vim.lsp.buf.workspace_symbol()
end)

map("n", "<leader>cl", function()
	vim.lsp.codelens.run()
end)

map("n", "<leader>sh", function()
	vim.lsp.buf.signature_help()
end)

map("n", "<leader>rn", function()
	vim.lsp.buf.rename()
end)

map("n", "<leader>f", function()
	vim.lsp.buf.formatting()
end)

map("n", "<leader>ac", function()
	vim.lsp.buf.code_action()
end)

map("n", "<leader>ws", function()
	require("metals").hover_worksheet()
end)

-- all workspace diagnostics
map("n", "<leader>aa", function()
	vim.diagnostic.setqflist()
end)

-- all workspace errors
map("n", "<leader>ae", function()
	vim.diagnostic.setqflist({ severity = "E" })
end)

-- all workspace warnings
map("n", "<leader>aw", function()
	vim.diagnostic.setqflist({ severity = "W" })
end)

-- buffer diagnostics only
map("n", "<leader>d", function()
	vim.diagnostic.setloclist()
end)

map("n", "[g", function()
	vim.diagnostic.goto_prev({ wrap = false })
end)

map("n", "]g", function()
	vim.diagnostic.goto_next({ wrap = false })
end)

map("n", "<F1>", function()
  require("dap").continue()
end)

map("n", "<leader>dr", function()
  require("dap").repl.toggle()
end)

map("n", "<leader>dK", function()
  require("dap.ui.widgets").hover()
end)

map("n", "<F9>", function()
  require("dap").toggle_breakpoint()
end)

map("n", "F10", function()
  require("dap").step_over()
end)

map("n", "F11", function()
  require("dap").step_into()
end)

map("n", "<leader>dl", function()
  require("dap").run_last()
end)

map("n", "<leader>de", function()
    require("dap").terminate()
end)

-- completion related settings
-- This is similiar to what I use
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
    { name = "vsnip" },
  },
  snippet = {
    expand = function(args)
      -- Comes from vsnip
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    -- None of this made sense to me when first looking into this since there
    -- is no vim docs, but you can't have select = true here _unless_ you are
    -- also using the snippet stuff. So keep in mind that if you remove
    -- snippets you need to remove this select
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    -- I use tabs... some say you should stick to ins-completion but this is just here as an example
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  }),
})

local metals_config = require("metals").bare_config()

-- Example of settings
metals_config.settings = {
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
}

-- *READ THIS*
-- I *highly* recommend setting statusBarProvider to true, however if you do,
-- you *have* to have a setting to display this in your statusline or else
-- you'll not see any messages from metals. There is more info in the help
-- docs about this
-- metals_config.init_options.statusBarProvider = "on"

-- Example if you are using cmp how to make sure the correct capabilities for snippets are set
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Debug settings if you're using nvim-dap
local dap = require("dap")

dap.configurations.scala = {
  {
    type = "scala",
    request = "launch",
    name = "RunOrTest",
    metals = {
      runType = "runOrTestFile",
      --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
    },
  },
  {
    type = "scala",
    request = "launch",
    name = "Test Target",
    metals = {
      runType = "testTarget",
    },
  },
}

metals_config.on_attach = function(client, bufnr)
  require("metals").setup_dap()
end

require("metals").initialize_or_attach(metals_config)
