return { -- Linting
	"mfussenegger/nvim-lint",
	config = function()
		local lint = require("lint")
		lint.linters_by_ft = {
			go = { "golangcilint" },
			dockerfile = { "hadolint" },
			json = { "jsonlint" },
			python = { "ruff" },
		}
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("linter", { clear = true }),
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
