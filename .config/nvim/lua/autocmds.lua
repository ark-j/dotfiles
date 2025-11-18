-- basic autocommands
-- highlight in yank autocommand
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- cursor setting command after exiting neovim to set cursor to bliking bar
vim.api.nvim_create_autocmd("ExitPre", {
	group = vim.api.nvim_create_augroup("exit-cursor-bar", { clear = true }),
	command = "set guicursor=a:blinkon250-ver100",
	desc = "Set cursor back to beam when leaving Neovim.",
})

-- sets all things on bold Boom!
vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter", "WinEnter" }, {
	group = vim.api.nvim_create_augroup("text-bold", { clear = true }),
	command = "syntax match BoldText /./",
	desc = "set all to bold",
})
