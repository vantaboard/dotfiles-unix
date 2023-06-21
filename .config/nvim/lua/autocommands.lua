-- lua/autocommands.lua

vim.api.nvim_create_augroup('reload queries on query save', { clear = true })
vim.api.nvim_create_autocmd('BufWrite', {
    pattern = '*.scm',
    callback = function()
        require 'nvim-treesitter.query'.invalidate_query_cache()
    end
})

vim.cmd [[
autocmd BufRead,BufNewFile tsconfig.json set filetype=jsonc
]]
