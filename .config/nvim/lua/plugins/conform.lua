local M = {}

M.get_offset_encoding = function(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.offset_encoding then
      return client.offset_encoding
    end
  end
  return "utf-16"
end

-- Fornat the imports and as well import the libs if not there
M.format_go_imports = function(args)
  if vim.bo[args.buf].filetype == "go" then
    ---@type lsp.CodeActionParams
    local params = vim.lsp.util.make_range_params(0, M.get_offset_encoding(args.buf))
    params.context = {
      diagnostics = vim.diagnostic.get(args.buf),
      only = { "source.organizeImports" },
    }

    -- Request code actions for organize imports
    local results, err = vim.lsp.buf_request_sync(args.buf, "textDocument/codeAction", params, 500)
    if err then
      return
    end

    -- Apply the text edits if any are returned
    if results then
      for _, response in pairs(results) do
        if response.result and #response.result > 0 then
          for _, action in ipairs(response.result) do
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, M.get_offset_encoding(args.buf))
            end
          end
        end
      end
    end
  end
end

M.config = {
  "stevearc/conform.nvim",
  lazy = false,
  config = function()
    local conform = require("conform")
    conform.setup({
      loglevel = vim.log.levels.DEBUG,
      notify_on_error = false,
      formatters_by_ft = {
        lua = { "stylua" },
        html = { "prettier" },
        css = { "prettier" },
        python = { "ruff" },
      },
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(args)
        M.format_go_imports(args)
        conform.format({
          bufnr = args.buf,
          lsp_format = "fallback",
          quiet = true,
          timeout_ms = 500,
        })
      end,
    })
  end,
}

return M.config
