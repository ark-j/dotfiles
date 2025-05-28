-- most important plugin and fuzzy finder as well as everything finder in workspace
return {
  "nvim-telescope/telescope.nvim",
  event = "VimEnter",
  -- branch = "0.1.x",
  branch = "master",

  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },

  config = function()
    require("telescope").setup({
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        wrap_results = true,
        ["ui-select"] = { require("telescope.themes").get_dropdown() },
      },
      defaults = {
        selection_caret = " ",
        prompt_prefix = "  ",
        layout_strategy = "horizontal_fused",
        layout_config = { width = 0.87, height = 0.8, horizontal = { preview_width = 0.55 } },
        file_ignore_patterns = {
          "/%s.git/",
          "vendor",
          "venv",
          "env",
          "node_modules",
        },
      },
    })

    require("telescope").load_extension("fzf")
    require("telescope").load_extension("ui-select")

    local layout_strategies = require("telescope.pickers.layout_strategies")
    layout_strategies.horizontal_fused = function(picker, max_columns, max_lines, layout_config)
      local layout = layout_strategies.horizontal(picker, max_columns, max_lines, layout_config)
      layout.results.height = layout.results.height + 1
      layout.results.borderchars = { "─", "│", "─", "│", "╭", "┬", "┤", "├" }
      layout.preview = layout.preview or {}
      layout.preview.borderchars = { "─", "│", "─", " ", "─", "╮", "╯", "─" }
      layout.prompt.borderchars = { "─", "│", "─", "│", "╭", "╮", "┴", "╰" }
      return layout
    end

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    vim.keymap.set("n", "<leader>fk", builtin.keymaps)
    vim.keymap.set("n", "<leader>ff", builtin.find_files)
    vim.keymap.set("n", "<leader>ft", builtin.git_files)
    vim.keymap.set("n", "<leader>fw", builtin.grep_string)
    vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    vim.keymap.set("n", "<leader>fd", builtin.diagnostics)
    vim.keymap.set("n", "<leader><leader>", builtin.buffers)
    vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find)

    -- Live grep for open files
    vim.keymap.set("n", "<leader>f/", function()
      builtin.live_grep({ grep_open_files = true, prompt_title = "Live Grep in Open Files" })
    end, { desc = "[F]ind [/] in Open Files" })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set("n", "<leader>fn", function()
      builtin.find_files({ cwd = vim.fn.stdpath("config") })
    end, { desc = "[F]ind [N]eovim files" })

    -- find files in ignored if required
    vim.keymap.set("n", "<leader>f.", function()
      builtin.find_files({ hidden = true, no_ignore = true, file_ignore_patterns = {} })
    end, { desc = "[F]ind in [.] ignored file patterns" })
  end,
}
