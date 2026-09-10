local M = {}

function M.setup(opts)
	local bufnr = assert(opts.bufnr, "bufnr is required")
	local messages = opts.messages
	if not messages then
		messages = {
			[assert(opts.method, "method or messages is required")] = opts.message or "Request is still running...",
		}
	end
	local client_name = opts.client_name
	local delay_ms = opts.delay_ms or 300
	local title = opts.title or "LSP"
	local requests = {}
	local group = vim.api.nvim_create_augroup("LspRequestProgress" .. bufnr, { clear = true })

	vim.api.nvim_create_autocmd("LspRequest", {
		group = group,
		buffer = bufnr,
		callback = function(args)
			local request = args.data.request
			local message = request and messages[request.method]
			if not message then
				return
			end

			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client_name and (not client or client.name ~= client_name) then
				return
			end

			local key = args.data.client_id .. ":" .. args.data.request_id
			if request.type == "pending" then
				local tracked = {
					pending = true,
				}
				requests[key] = tracked

				vim.defer_fn(function()
					if tracked.pending then
						tracked.notification = vim.notify(message, vim.log.levels.INFO, {
							title = title,
							timeout = false,
						})
					end
				end, delay_ms)
				return
			end

			local tracked = requests[key]
			if not tracked then
				return
			end

			tracked.pending = false
			requests[key] = nil

			if tracked.notification then
				vim.cmd("NoiceDismiss")
			end
		end,
	})
end

return M
