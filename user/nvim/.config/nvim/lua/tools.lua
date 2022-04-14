local tools = {}

function tools.map(mode, key, cmd, opts)
	local options = {noremap = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, key, cmd, options)
end

return tools
