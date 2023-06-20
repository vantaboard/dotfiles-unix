-- lua/mappings.lua

function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)
  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return table.concat(lines, '\n')
end

local optsrsw = { noremap = true, silent = true, nowait = true }
local optsrs = { noremap = true, silent = true }

-- x removes
vim.api.nvim_set_keymap('n', '<leader>x', '"_d', optsrs)
vim.api.nvim_set_keymap('n', '<leader>xx', '"_dd', optsrsw)
vim.api.nvim_set_keymap('n', 'X', '"_d$', optsrsw)

-- yank / replace-paste until end
vim.api.nvim_set_keymap('n', '<leader><leader>y', 'v$hy', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>r', 'v$h"_dp`[', optsrsw)

-- vim color scheme switcher
vim.api.nvim_set_keymap('n', '<leader>cp', ':PrevColorScheme<CR>', optsrs)
vim.api.nvim_set_keymap('n', '<leader>cn', ':NextColorScheme<CR>', optsrs)

-- camelcasemotion
vim.cmd[[
    map <nowait><silent> <leader>w <Plug>CamelCaseMotion_w
    map <nowait><silent> <leader>b <Plug>CamelCaseMotion_b
    map <nowait><silent> <leader>e <Plug>CamelCaseMotion_e
    map <nowait><silent> <leader>ge <Plug>CamelCaseMotion_ge

    map <leader>j <C-E><C-E><C-E><C-E><C-E><C-E>
    map <leader>k <C-Y><C-Y><C-Y><C-Y><C-Y><C-Y>
]]

-- replace without yanking
vim.api.nvim_set_keymap('n', '<leader><leader>p', '"_dp', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>P', '"_dP', optsrsw)

-- replace until with current yank
vim.api.nvim_set_keymap('n', '<leader>f', ':execute("normal vt" . nr2char(getchar()) . "\\"_dP")<cr>', optsrsw)
vim.api.nvim_set_keymap('n', '<leader>F', ':execute("normal vf" . nr2char(getchar()) . "\\"_dP")<cr>', optsrsw)

-- easy save
vim.api.nvim_set_keymap('n', '<leader>w', ':w<CR>', optsrsw)

-- easy quit vim
vim.api.nvim_set_keymap('n', 'Q', ':q!<CR>', optsrsw)

-- harpoon
vim.api.nvim_set_keymap('n', '<leader>H', "<cmd>lua require'harpoon.mark'.add_file()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>ch', "<cmd>lua require'harpoon.mark'.clear_all()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>h', "<cmd>Telescope harpoon marks<cr>", optsrs)

-- dap
vim.api.nvim_set_keymap('n', '<leader>B', "<cmd>lua require'dap'.toggle_breakpoint()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>c', "<cmd>lua require'dap'.continue()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader><leader>d', "<cmd>lua require'dapui'.toggle()<cr>", optsrs)

-- telescope
vim.api.nvim_set_keymap('n', '<leader>ff', "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>fg', "<cmd>lua require('telescope.builtin').live_grep()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>fb', "<cmd>lua require('telescope.builtin').buffers()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>fh', "<cmd>lua require('telescope.builtin').help_tags()<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<leader>/', "<cmd>lua require('telescope.builtin').current_buffer_fuzzy_find({ fuzzy = false, case_mode = 'ignore_case' })<cr>", optsrs)
vim.api.nvim_set_keymap('n', '<C-q>', "<cmd>lua require('telescope.builtin').quickfix()<cr>", optsrs)

-- lua snippets
vim.cmd[[
" press <Tab> to expand or jump in a snippet. These can also be mapped separately
" via <Plug>luasnip-expand-snippet and <Plug>luasnip-jump-next.
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
" -1 for jumping backwards.
inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr>

snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>

" For changing choices in choiceNodes (not strictly necessary for a basic setup).
imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
]]

-- copilot
vim.cmd[[
    imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
]]

-- hide background
-- function to run highlight Normal guibg=none
-- and highlight NonText guibg=none
vim.cmd[[
    function! HideBackground()
        highlight Normal guibg=none
        highlight NonText guibg=none
    endfunction
]]

-- leetcode
vim.g.leetcode_browser = 'chrome'

vim.cmd [[
  nnoremap <leader>ll :LeetCodeList<cr>
  nnoremap <leader>lt :LeetCodeTest<cr>
  nnoremap <leader>ls :LeetCodeSubmit<cr>
  nnoremap <leader>li :LeetCodeSignIn<cr>
]]

-- vim.api.nvim_set_keymap('v', '<leader>g', '!pg_format<CR>', optsrs)
-- vim.api.nvim_set_keymap('n', '<leader>N', ':call HideBackground()<CR>', optsrs)
