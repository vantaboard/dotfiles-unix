require'nvim-tree'.setup {}

local optsrsw = { noremap = true, silent = true, nowait = true }
local optsrs = { noremap = true, silent = true }

-- x removes
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>r', ':NvimTreeRefresh<CR>', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFindFile<CR>', optsrsw)
