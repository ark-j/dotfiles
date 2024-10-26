return { -- Highlight, edit, and navigate code
	"nvim-treesitter/nvim-treesitter",

	build = ":TSUpdate",

	opts = {
		ensure_installed = {
			"python",
			"rust",
			"javascript",
			"bash",
			"c",
			"html",
			"lua",
			"luadoc",
			"markdown",
			"markdown_inline",
			"vim",
			"vimdoc",
			"go",
			"toml",
			"dockerfile",
			"json",
			"sql",
			"yaml",
			"make",
			"csv",
		},
		-- Autoinstall languages that are not installed
		auto_install = true,
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = { "ruby" },
		},
		indent = { enable = true, disable = { "ruby" } },
	},

	config = function(_, opts)
		---@diagnostic disable-next-line: missing-fields
		require("nvim-treesitter.configs").setup(opts)
		vim.treesitter.language.register("bash", "zsh")
	end,
}
