local M = {}

M.lspkind = {
	Namespace = "󰌗",
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰆧",
	Constructor = "",
	Field = "󰜢",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈚",
	Reference = "󰈇",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "󰙅",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰊄",
	Table = "",
	Object = "󰅩",
	Tag = "",
	Array = "[]",
	Boolean = "",
	Number = "",
	Null = "󰟢",
	Supermaven = "",
	String = "󰉿",
	Calendar = "",
	Watch = "󰥔",
	Package = "",
	Copilot = "",
	Codeium = "",
	TabNine = "",
}

-- lspkind.menu = {
-- 	nvim_lsp = "[LSP]",
-- 	luasnip = "[SNIP]",
-- }

---@diagnostic disable-next-line: unused-local
M.lspkind.format = function(entry, item)
	local symbol = M.lspkind[item.kind] or ""
	item.kind = string.format("%s %s", symbol, item.kind)
	-- 	item.menu = lspkind.menu[entry.source.name] or ""
	return item
end

M.setup = function()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	luasnip.config.setup({})

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered({
				border = "rounded",
				col_offset = 1,
				side_padding = 1,
				scrollbar = false,
			}),
			documentation = cmp.config.window.bordered({
				border = "rounded",
				col_offset = 1,
				side_padding = 1,
				scrollbar = false,
			}),
		},
		completion = { completeopt = "menu,menuone,noselect" },
		mapping = cmp.mapping.preset.insert({
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<C-Space>"] = cmp.mapping.complete({}),

			["<C-l>"] = cmp.mapping(function()
				if luasnip.expand_or_locally_jumpable() then
					luasnip.expand_or_jump()
				end
			end, { "i", "s" }),
			["<C-h>"] = cmp.mapping(function()
				if luasnip.locally_jumpable(-1) then
					luasnip.jump(-1)
				end
			end, { "i", "s" }),
		}),

		formatting = {
			fields = { "abbr", "kind", "menu" },
			expandable_indicator = true,
			format = M.lspkind.format,
		},
		sources = {
			{ name = "lazydev", group_index = 0 },
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			{ name = "path" },
			{ name = "buffer" },
			{ name = "nerdfont" },
			{ name = "emoji" },
		},
	})
end

return M
