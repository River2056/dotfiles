local dap_status_ok, dap = pcall(require, "dap")
if not dap_status_ok then
    return
end

local dap_ui_status_ok, dapui = pcall(require, "dapui")
if not dap_ui_status_ok then
    return
end

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "DiagnosticSignError", linehl = "", numhl = "" })

dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({})
end

vim.keymap.set("n", "<F9>", ':lua require"dap".toggle_breakpoint()<cr>')
vim.keymap.set("n", "<F5>", ':lua require"dap".continue()<cr>')
vim.keymap.set("n", "<F10>", ':lua require"dap".step_over()<cr>')
vim.keymap.set("n", "<F11>", ':lua require"dap".step_into()<cr>')
vim.keymap.set("n", "<F12>", ':lua require"dap".repl_open()<cr>')
vim.keymap.set("n", "<Leader>cb", ':lua require"dap".clear_breakpoints()<cr>')
vim.keymap.set("n", "<Leader>lb", ':lua require"dap".list_breakpoints()<cr>')
vim.keymap.set("n", "<Leader>tt", ':lua require"dapui".toggle()<cr>')
