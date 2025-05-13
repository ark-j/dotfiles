-- LSP Configuration & Pluginslsp
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "williamboman/mason.nvim", config = true },
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- required for yaml companion
    "someone-stole-my-name/yaml-companion.nvim",
    "b0o/SchemaStore.nvim",
  },
  config = function()
    require("mason").setup({
      PATH = "skip",
      ui = {
        border = "rounded",
        icons = {
          package_pending = " ",
          package_installed = " ",
          package_uninstalled = " ",
        },
      },
      max_concurrent_installers = 5,
    })

    require("custom.lsp")

    vim.diagnostic.config({
      severity_sort = true,
      float = { border = "rounded", source = "if_many" },
      virtual_lines = true,
      virtual_text = false,
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = "󰀪 ",
          [vim.diagnostic.severity.INFO] = " ",
          [vim.diagnostic.severity.HINT] = " ",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.HINT] = "",
          [vim.diagnostic.severity.INFO] = "",
        },
      },
    })

    vim.keymap.set("n", "<leader>l", function()
      local config = vim.diagnostic.config() or {}
      if config.virtual_text then
        vim.diagnostic.config({ virtual_text = false, virtual_lines = true })
      else
        vim.diagnostic.config({ virtual_text = true, virtual_lines = false })
      end
    end, { desc = "Toggle lsp_lines" })
  end,
}
