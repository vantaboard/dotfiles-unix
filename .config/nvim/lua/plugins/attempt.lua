require('attempt').setup()

local attempt = require('attempt')

local function map(mode, l, r, opts)
    opts = opts or {}
    opts = vim.tbl_extend('force', { silent=true }, opts)
    vim.keymap.set(mode, l, r, opts)
end

map('n', '<leader>an', attempt.new_select)        -- new attempt, selecting extension
map('n', '<leader>ai', attempt.new_input_ext)     -- new attempt, inputing extension
map('n', '<leader>ar', attempt.run)               -- run attempt
map('n', '<leader>ad', attempt.delete_buf)        -- delete attempt from current buffer
map('n', '<leader>ac', attempt.rename_buf)        -- rename attempt from current buffer
map('n', '<leader>al', 'Telescope attempt')       -- search through attempts
--or: map('n', '<leader>al', attempt.open_select) -- use ui.select instead of telescope
