return {
  "michaelrommel/nvim-silicon",
  lazy = true,
  cmd = "Silicon",
  opts = {
    disable_defaults = true,
    debug = false,
    font = "JetBrainsMono Nerd Font=30; Noto Color Emoji=30",
    theme = "OneHalfDark",
    no_round_corner = false,
    no_window_control = false,
    no_line_number = false,
    window_title = function()
      return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()), ":t")
    end,
    language = function()
      return vim.bo.filetype
    end,
    to_clipboard = true,
    output = "./code.png",
  },
}
