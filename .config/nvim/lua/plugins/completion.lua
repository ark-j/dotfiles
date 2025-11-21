return {
	"saghen/blink.cmp",
	dependencies = {
		"rafamadriz/friendly-snippets",
		"xzbdmw/colorful-menu.nvim",
	},
	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = { preset = "default" },
		appearance = {
			nerd_font_variant = "normal",
		},
		completion = {
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "source_name", gap = 1 },
						{ "kind_icon", gap = 1 },
						{ "label", gap = 1 },
					},
					components = {
						label = {
							text = function(ctx)
								return require("colorful-menu").blink_components_text(ctx)
							end,
							highlight = function(ctx)
								return require("colorful-menu").blink_components_highlight(ctx)
							end,
						},
					},
				},
			},
			documentation = { auto_show = true, auto_show_delay_ms = 500, window = { border = "rounded" } },
		},
		sources = {
			default = { "lsp", "path", "snippets", "buffer" },
		},
		signature = { enabled = true, window = { border = "rounded" } },
		fuzzy = { implementation = "rust" },
	},
	opts_extend = { "sources.default" },
}
