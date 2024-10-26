-- LSP Configuration & Pluginslsp
return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "williamboman/mason.nvim", config = true },
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- required for yaml companion
		"someone-stole-my-name/yaml-companion.nvim",
		{ "https://git.sr.ht/~whynothugo/lsp_lines.nvim" },
		{
			"folke/lazydev.nvim",
			ft = "lua",
			dependencies = { "Bilal2453/luvit-meta" },
			opts = {
				library = {
					{ path = "luvit-meta/library", words = { "vim%.uv" } },
				},
			},
		},
		"b0o/SchemaStore.nvim",
	},
	config = function()
		require("custom.lsp").setup()
		require("lsp_lines").setup()
		vim.diagnostic.config({
			virtual_text = true,
			virtual_lines = false,
		})
		vim.keymap.set("n", "<leader>l", function()
			local config = vim.diagnostic.config() or {}
			if config.virtual_text then
				vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
			else
				vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
			end
		end, { desc = "Toggle lsp_lines" })
	end,
}
