-- return {
-- 	"catppuccin/nvim",
-- 	name = "catppuccin",
-- 	priority = 1000,
-- 	init = function()
-- 		if vim.fn.getenv("TERM") == "alacritty" then
-- 			vim.cmd.hi("Normal gui=bold cterm=bold guifg=NONE guibg=NONE")
-- 			vim.cmd.hi("BoldText gui=bold cterm=bold guifg=NONE guibg=NONE")
-- 		end
-- 		vim.cmd.colorscheme("catppuccin")
-- 	end,
-- 	config = function()
-- 		require("catppuccin").setup({
-- 			transparent_background = false,
-- 			term_colors = true,
-- 			no_bold = false,
-- 			no_italic = true,
-- 			flavour = "mocha",
-- 			default_integrations = false,
-- 			integrations = {
-- 				mason = true,
-- 				harpoon = true,
-- 				noice = true,
-- 				markdown = true,
-- 				render_markdown = true,
-- 				cmp = true,
-- 				dap = true,
-- 				dap_ui = true,
-- 				telescope = { enabled = true },
-- 				native_lsp = {
-- 					enabled = true,
-- 					virtual_text = {
-- 						errors = { "italic" },
-- 						hints = { "italic" },
-- 						warnings = { "italic" },
-- 						information = { "italic" },
-- 						ok = { "italic" },
-- 					},
-- 					underlines = {
-- 						errors = { "underline" },
-- 						hints = { "underline" },
-- 						warnings = { "underline" },
-- 						information = { "underline" },
-- 						ok = { "underline" },
-- 					},
-- 					inlay_hints = {
-- 						background = true,
-- 					},
-- 				},
-- 				gitsigns = true,
-- 				nvimtree = true,
-- 				treesitter = true,
-- 				semantic_tokens = true,
-- 				nvim_surround = true,
-- 				notify = true,
-- 				mini = {
-- 					enable = true,
-- 					indentscope_color = "",
-- 				},
-- 				barbecue = {
-- 					bold_basename = true,
-- 					dim_context = false,
-- 					alt_background = false,
-- 				},
-- 			},
-- 		})
-- 	end,
-- }

return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	init = function()
		if vim.fn.getenv("TERM") == "alacritty" then
			vim.cmd.hi("Normal gui=bold cterm=bold guifg=NONE guibg=NONE")
			vim.cmd.hi("BoldText gui=bold cterm=bold guifg=NONE guibg=NONE")
		end
		vim.cmd.colorscheme("tokyonight")
	end,
	config = function()
		---@diagnostic disable-next-line: missing-fields
		require("tokyonight").setup({
			style = "night",
			light_style = "day",
			transparent = false,
			terminal_colors = true,
			styles = {
				comments = { italic = false },
				keywords = { italic = false },
				functions = { italic = false },
				variables = { italic = false },
				sidebars = "normal",
				floats = "normal",
			},
			day_brightness = 0.3,
			dim_inactive = false,
			lualine_bold = false,
			-- Telescope same border color for everything
			on_highlights = function(hl, c)
				hl.TelescopePromptBorder = {
					fg = c.blue2,
				}
			end,
			cache = true,
			plugins = {
				all = package.loaded.lazy == nil,
				auto = true,
			},
		})
	end,
}
