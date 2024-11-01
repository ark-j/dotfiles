return { -- Autoformat
	"stevearc/conform.nvim",
	lazy = false,
	config = function()
		local conform = require("conform")
		conform.setup({
			loglevel = vim.log.levels.DEBUG,
			notify_on_error = false,
			formatters_by_ft = {
				lua = { "stylua" },
				html = { "prettier" },
				python = { "ruff" },
			},
		})
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(args)
				conform.format({
					bufnr = args.buf,
					lsp_format = "fallback",
					quiet = true,
					timeout_ms = 500,
				})
			end,
		})
	end,
}
