local tokyonight = {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	init = function()
		vim.cmd.colorscheme("tokyonight")
	end,
	config = function()
		require("tokyonight").setup({
			on_highlights = function(hl, c)
				hl.TelescopePromptBorder = {
					fg = c.blue1,
				}
			end,
			style = "night",
			styles = {
				comments = { italic = false },
				keywords = { italic = false },
				functions = { italic = false },
				variables = { italic = false },
			},
		})
	end,
}

local onedark = {
	"navarasu/onedark.nvim",
	priority = 1000, -- make sure to load this before all the other start plugins
	config = function()
		require("onedark").setup({
			style = "darker",
		})
		require("onedark").load()
	end,
}

local catppuccin = {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	init = function()
		vim.cmd.colorscheme("catppuccin")
	end,
	config = function()
		require("catppuccin").setup({
			transparent_background = false,
			term_colors = true,
			no_bold = true,
			no_italic = true,
			flavour = "mocha",
			default_integrations = true,
			color_overrides = {
				mocha = {
					base = "#1a1b26",
					mantle = "#15161e",
					curst = "#15161e",
				},
			},
		})
	end,
}

local gruvbox = {
	"sainnhe/gruvbox-material",
	lazy = false,
	priority = 1000,
	config = function()
		vim.g.gruvbox_material_enable_italic = false
		vim.g.gruvbox_material_background = "hard"
		vim.cmd.colorscheme("gruvbox-material")
	end,
}

local schemes = {
	tokyonight = tokyonight,
	gruvbox = gruvbox,
	catppuccin = catppuccin,
	onedark = onedark,
}

return schemes.tokyonight
