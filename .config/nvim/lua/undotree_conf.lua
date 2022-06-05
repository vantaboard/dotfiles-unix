-- lua/local_undotree.lua

-- disable backups
vim.cmd([[
    set noswapfile
    set nobackup
    set undofile
    set undodir=~/.vim/undo
]])

local optsrws = { noremap = true, silent = true, nowait = true }
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle<CR>', optsrws)
