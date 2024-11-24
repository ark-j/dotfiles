local M = {}

M.capabilities = vim.tbl_deep_extend(
	"force",
	vim.lsp.protocol.make_client_capabilities(),
	require("cmp_nvim_lsp").default_capabilities()
)
M.lspconfig = require("lspconfig")

M.zig = function()
	M.lspconfig.zls.setup({
		capabilities = M.capabilities,
	})
end

M.go = function()
	M.lspconfig.gopls.setup({
		capabilities = M.capabilities,
		settings = {
			gopls = {
				buildFlags = { "-tags=integration unit test pact release mock" },
				completeUnimported = true,
				analyses = {
					shadow = true,
					unusedvariable = true,
					unusedwrite = true,
					useany = true,
				},
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
				gofumpt = true,
			},
		},
	})
	M.lspconfig.templ.setup({ capabilities = M.capabilities })
end

M.python = function()
	M.lspconfig.pyright.setup({
		capabilities = M.capabilities,
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
end

M.lua = function()
	M.lspconfig.lua_ls.setup({
		capabilities = M.capabilities,
		settings = {
			Lua = {
				completion = {
					callSnippet = "Replace",
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
end

M.json = function()
	M.lspconfig.jsonls.setup({
		capabilities = M.capabilities,
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	})
end

M.yaml = function()
	local cfg = require("yaml-companion").setup({
		builtin_matchers = {
			kubernetes = { enabled = true },
		},
		schemas = {
			{
				name = "Argo CD Application",
				uri = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/argoproj.io/application_v1alpha1.json",
			},
			{
				name = "SealedSecret",
				uri = "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/bitnami.com/sealedsecret_v1alpha1.json",
			},
			{
				name = "Kustomization",
				uri = "https://json.schemastore.org/kustomization.json",
			},
			{
				name = "GitHub Workflow",
				uri = "https://json.schemastore.org/github-workflow.json",
			},
		},

		lspconfig = {
			capabilities = M.capabilities,
			settings = {
				yaml = {
					validate = true,
					format = { enable = true },
					hover = true,
					schemaStore = {
						enable = true,
						url = "https://www.schemastore.org/api/json/catalog.json",
					},
					schemaDownload = { enable = true },
					schemas = {},
				},
			},
		},
	})
	M.lspconfig.yamlls.setup(cfg)
	require("telescope").load_extension("yaml_schema")
end

M.toml = function()
	M.lspconfig.taplo.setup({ capabilities = M.capabilities })
end

M.on_attach = function()
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
		callback = function(args)
			local client = assert(vim.lsp.get_client_by_id(args.data.client_id), "must have valid client")
			local builtin = require("telescope.builtin")

			vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
			vim.keymap.set("n", "gd", builtin.lsp_definitions, { buffer = args.buf })
			vim.keymap.set("n", "gr", builtin.lsp_references, { buffer = args.buf })
			vim.keymap.set("n", "gi", builtin.lsp_implementations, { buffer = args.buf })
			vim.keymap.set("n", "<leader>D", builtin.lsp_type_definitions, { buffer = args.buf })
			vim.keymap.set("n", "ds", builtin.lsp_document_symbols, { buffer = args.buf })
			vim.keymap.set("n", "ws", builtin.lsp_dynamic_workspace_symbols, { buffer = args.buf })
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = args.buf })
			vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = args.buf })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf })
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = args.buf })

			if client.supports_method("textDocument/semanticTokens") then
				client.server_capabilities.semanticTokensProvider = nil
			end

			-- enable toggle of inlay hints if server supports it
			if client then
				if client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
					vim.keymap.set("n", "<leader>th", function()
						vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }))
					end)
				end
				if client.supports_method(vim.lsp.protocol.Methods.textDocument_codeLens) and vim.lsp.codelens then
					vim.keymap.set("n", "tc", vim.lsp.codelens.refresh, { silent = true, buffer = args.buf })
					vim.keymap.set("n", "tcd", vim.lsp.codelens.clear, { silent = true, buffer = args.buf })
				end
			end
		end,
	})
end

M.install = function()
	require("mason").setup(require("custom.mason"))
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
end

M.setup = function()
	M.on_attach()
	M.install()
	M.zig()
	M.go()
	M.lua()
	M.python()
	M.json()
	M.yaml()
	M.toml()
end

return M
