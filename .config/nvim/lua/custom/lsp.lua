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

-- zls start
vim.lsp.config.zls = {
	cmd = { "zls" },
	filetypes = { "zig", "zir" },
	root_markers = { "zls.json", "build.zig", ".git" },
	workspace_required = false,
	capabilities = capabilities,
}
-- zls end

-- gopls start
local mod_cache = nil

---@param fname string
---@return string?
local function get_root(fname)
	if mod_cache and fname:sub(1, #mod_cache) == mod_cache then
		local clients = vim.lsp.get_clients({ name = "gopls" })
		if #clients > 0 then
			return clients[#clients].config.root_dir
		end
	end
	return vim.fs.root(fname, { "go.work", "go.mod", ".git" })
end

vim.lsp.config.gopls = {
	cmd = { "gopls" },
	filetypes = { "go", "gomod", "gowork", "gotmpl" },
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		-- see: https://github.com/neovim/nvim-lspconfig/issues/804
		if mod_cache then
			on_dir(get_root(fname))
			return
		end
		local cmd = { "go", "env", "GOMODCACHE" }
		vim.system(cmd, { text = true }, function(output)
			if output.code == 0 then
				if output.stdout then
					mod_cache = vim.trim(output.stdout)
				end
				on_dir(get_root(fname))
			else
				vim.notify(("[gopls] cmd failed with code %d: %s\n%s"):format(output.code, cmd, output.stderr))
			end
		end)
	end,
	capabilities = capabilities,
	settings = {
		gopls = {
			-- semanticTokens = true,
			buildFlags = { "-tags=integration unit test pact release mock" },
			completeUnimported = true,
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
}
-- gopls end

-- templ start
vim.lsp.config.templ = {
	cmd = { "templ", "lsp" },
	filetypes = { "templ" },
	root_markers = { "go.work", "go.mod", ".git" },
	capabilities = capabilities,
}
-- templ end

-- pyright start
vim.lsp.config.pyright = {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	root_markers = {
		"pyproject.toml",
		"setup.py",
		"setup.cfg",
		"requirements.txt",
		"Pipfile",
		"pyrightconfig.json",
		".git",
	},
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
}
-- pyright end

-- luals start
vim.lsp.config.luals = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json",
		".luarc.jsonc",
		".luacheckrc",
		".stylua.toml",
		"stylua.toml",
		"selene.toml",
		"selene.yml",
		".git",
	},
	capabilities = capabilities,
	settings = {
		Lua = {
			runtime = {
				version = "LuaJIT",
			},
			diagonostics = {
				globals = { "vim" },
			},
			completion = {
				callSnippet = "Replace",
			},
			workspace = {
				checkThirdParty = false,
				library = vim.api.nvim_get_runtime_file("", true),
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
}
-- luals end

-- jsonls start
vim.lsp.config.jsonls = {
	cmd = { "vscode-json-language-server", "--stdio" },
	filetypes = { "json", "jsonc" },
	init_options = {
		provideFormatter = true,
	},
	root_markers = { ".git" },
	capabilities = capabilities,
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
}
-- jsonls end

-- yamlls start
vim.lsp.config.yamlls = require("yaml-companion").setup({
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
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
		root_markers = { ".git" },
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
				schemaDownload = { enable = true },
				schemas = {},
			},
		},
	},
})
require("telescope").load_extension("yaml_schema")
-- yamlls end

-- taplo start
vim.lsp.config.taplo = {
	cmd = { "taplo", "lsp", "stdio" },
	filetypes = { "toml" },
	root_markers = { ".taplo.toml", "taplo.toml", ".git" },
	capabilities = capabilities,
}
-- taplo end

vim.lsp.enable({ "luals", "pyright", "gopls", "templ", "taplo", "jsonls", "yamlls", "zls" })
