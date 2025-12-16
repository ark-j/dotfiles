local capabilities = require("blink.cmp").get_lsp_capabilities(vim.lsp.protocol.make_client_capabilities())

local ensure_installed = {
	-- linters
	"jsonlint", -- Used to lint json
	"golangci-lint", -- Used to lint go code
	"hadolint", -- used to lint Dockerfile

	-- formatters
	"stylua", -- Used to format Lua code
	"prettier", -- used to formatter html, css, javascript
	"ruff", -- used to format python code

	-- debuggers
	"delve",

	-- golang specific
	"gomodifytags",
	"impl",
	"gotests",
	"iferr",

	-- servers
	"gopls",
	"yaml-language-server",
	"json-lsp",
	"lua-language-server",
	"pyright",
	"templ",
	"taplo",
}
require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")
		local builtin = require("telescope.builtin")

		vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
		vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = args.buf })
		vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = args.buf }) -- alt: grr
		vim.keymap.set("n", "gi", builtin.lsp_implementations, { buffer = args.buf }) -- alt: gri
		vim.keymap.set("n", "<leader>D", builtin.lsp_type_definitions, { buffer = args.buf }) -- alt: grt
		vim.keymap.set("n", "ds", builtin.lsp_document_symbols, { buffer = args.buf }) -- alt: gO
		vim.keymap.set("n", "ws", builtin.lsp_dynamic_workspace_symbols, { buffer = args.buf })
		vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = args.buf }) -- alt: grn
		vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = args.buf }) -- alt: gra
		vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
		vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = args.buf })

		if client:supports_method("textDocument/semanticTokens") then
			client.server_capabilities.semanticTokensProvider = nil
		end

		-- enable toggle of inlay hints if server supports it
		if client then
			if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
				vim.keymap.set("n", "<leader>th", function()
					vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
				end)
			end
			if client:supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) and vim.lsp.codelens then
				vim.keymap.set("n", "tc", vim.lsp.codelens.refresh, { silent = true, buffer = args.buf })
				vim.keymap.set("n", "tcd", vim.lsp.codelens.clear, { silent = true, buffer = args.buf })
			end
		end
	end,
})

vim.lsp.config("zls", { capabilities = capabilities })
vim.lsp.config("templ", { capabilities = capabilities })
vim.lsp.config("taplo", { capabilities = capabilities })

vim.lsp.config("gopls", {
	capabilities = capabilities,
	settings = {
		gopls = {
			-- exclude uncessary dirs
			directoryFlags = { "-vendor", "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
			-- vendor mode has problem with GD in external deps so -mod=mod is required
			buildFlags = { "-tags=integration unit test pact release mock", "-mod=mod" },
			-- completeUnimported = true,
			hints = {
				compositeLiteralFields = true,
				assignVariableTypes = true,
				compositeLiteralTypes = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
			codelenses = {
				gc_details = true,
				run_govulncheck = true,
			},
			vulncheck = "Imports",
		},
	},
})

vim.lsp.config("pyright", {
	capabilities = capabilities,
	settings = {
		pyright = {
			-- Using Ruff's import organizer
			disableOrganizeImports = true,
		},
		python = {
			analysis = {
				-- Ignore all files for analysis to exclusively use Ruff for linting
				ignore = { "*" },
			},
		},
	},
})

vim.lsp.config("lua_ls", {
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagnostics = {
				globals = { "vim" },
			},
			completion = {
				callSnippet = "Replace",
			},
			semantic = {
				enable = true,
			},
			workspace = {
				checkThirdParty = false,
				library = {
					vim.env.VIMRUNTIME,
					vim.fn.stdpath("data") .. "/lazy",
					unpack(vim.api.nvim_get_runtime_file("", true)),
				},
			},
			telemetry = {
				enabled = false,
			},
			hint = {
				enable = true,
				setType = false,
				paramType = true,
				paramName = true,
				semicolon = false,
				arrayIndex = true,
			},
			codeLens = {
				enable = true,
			},
		},
	},
})

vim.lsp.config("jsonls", {
	capabilities = capabilities,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

vim.lsp.config("yamlls", {
	capabilities = capabilities,
	settings = {
		redhat = { telemetry = { enabled = false } },
		yaml = {
			yamlVersion = 1.2,
			validate = true,
			hover = true,
			format = { enable = true },
			schemaStore = {
				enable = true,
				url = "https://www.schemastore.org/api/json/catalog.json",
			},
			schemas = {},
		},
	},
})

vim.lsp.enable({ "lua_ls", "pyright", "gopls", "templ", "taplo", "jsonls", "yamlls", "zls" })
