vim.g.mapleader = " " -- elect space as global leader key
vim.g.maplocalleader = " " -- elect space as local leader key
vim.g.loaded_netrw = 1 -- disable netrw for nvim tree
vim.g.loaded_netrwPlugin = 1 -- disable netrw plugin for nvim tree
vim.g.have_nerd_font = true -- enable nerd font for icons
vim.opt.number = true -- enable line numbers
vim.opt.relativenumber = true -- enable relativenumber
vim.opt.mouse = "a" -- enable mouse mode useful for resizing window in split mode
vim.opt.showmode = false -- dont show mode as it is already shown in status line
vim.opt.clipboard = "unnamedplus" -- sync clipboard of neovim and host os
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true -- save undo history to file
vim.opt.ignorecase = true -- ignore case sensitive
vim.opt.smartcase = true -- enable smartcase
vim.opt.signcolumn = "yes" -- enable signcolumn on by default
vim.opt.updatetime = 200 --decrease update time
vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = false

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

--Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
vim.opt.termguicolors = true

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

local signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
