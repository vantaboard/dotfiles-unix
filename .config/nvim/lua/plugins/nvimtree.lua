require 'nvim-tree'.setup({
    trash = {
        cmd = "gio trash",
        require_confirm = false,
    },
    on_attach = function(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set('n', 'd', api.fs.trash, opts('Trash'))
    end,
})

local optsrsw = { noremap = true, silent = true, nowait = true }

-- x removes
vim.api.nvim_set_keymap('n', '<C-n>', ':NvimTreeToggle<CR>', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>r', ':NvimTreeRefresh<CR>', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFindFile<CR>', optsrsw)
