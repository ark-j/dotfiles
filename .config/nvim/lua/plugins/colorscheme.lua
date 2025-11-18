return {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	init = function()
		vim.cmd.colorscheme("catppuccin")
		-- if vim.fn.getenv("TERM") == "alacritty" then
		--   vim.cmd.hi("Normal gui=bold cterm=bold guifg=NONE guibg=NONE")
		--   vim.cmd.hi("BoldText gui=bold cterm=bold guifg=NONE guibg=NONE")
		-- end
	end,
	config = function()
		require("catppuccin").setup({
			transparent_background = false,
			term_colors = true,
			no_bold = false,
			no_italic = true,
			flavour = "mocha",
			default_integrations = true,
		})
	end,
}
