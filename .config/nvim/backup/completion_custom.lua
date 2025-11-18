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

M.lspkind.menu = {
	nvim_lsp = "[LSP]",
	luasnip = "[SNIP]",
}

---@diagnostic disable-next-line: unused-local
M.lspkind.format = function(entry, item)
	local symbol = M.lspkind[item.kind] or ""
	item.kind = string.format("%s %s", symbol, item.kind)
	item.menu = M.lspkind.menu[entry.source.name] or ""
	return item
end

M.setup = function()
	local cmp = require("cmp")
	vim.snippet.expand = require("luasnip").lsp_expand
	---@diagnostic disable-next-line
	cmp.setup({
		snippet = {
			expand = function(args)
				vim.snippet.expand(args.body)
			end,
		},
		completion = { completeopt = "menu,menuone,noselect" },
		mapping = cmp.mapping.preset.insert({
			["<C-n>"] = cmp.mapping.select_next_item(),
			["<C-p>"] = cmp.mapping.select_prev_item(),
			["<C-y>"] = cmp.mapping.confirm({
				behavior = cmp.ConfirmBehavior.Insert,
				select = true,
				{ "i", "c" },
			}),
		}),

		formatting = {
			fields = { "abbr", "kind", "menu" },
			expandable_indicator = true,
			format = M.lspkind.format,
		},
		sources = {
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
