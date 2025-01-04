return { -- Autoformat
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
        python = { "ruff" },
      },
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      callback = function(args)
        if vim.bo[args.buf].filetype == "go" then
          local params = vim.lsp.util.make_range_params()
          params.context = {
            diagonstics = { vim.diagnostic.get(args.buf) },
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
                    vim.lsp.util.apply_workspace_edit(action.edit, vim.lsp.util._get_offset_encoding(args.buf))
                  end
                end
              end
            end
          end
        end
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
