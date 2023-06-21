-- lua/mappings.lua

-- function that grabs the name of the current file, and then formats it based on the git origin
function gbu()
    local branch = string.gsub(vim.fn.system('git rev-parse --abbrev-ref HEAD'), '\n', '')
    local filename = string.gsub(string.gsub(vim.fn.expand('%'), vim.fn.system('git rev-parse --show-toplevel'), ''),
        '\n', '')
    local git_url = vim.fn.system('git remote get-url origin')
    local git_url = string.gsub(git_url, ':', '/')
    local git_url = string.gsub(git_url, 'git@', 'https://')
    local git_url = string.gsub(git_url, '%.git', '/blob/' .. branch .. '/' .. filename)
    vim.fn.system('firefox ' .. git_url)
end

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

-- function that starts a pull request
-- function pr(repo)
function pr()
    local branch = string.gsub(vim.fn.system('git rev-parse --abbrev-ref HEAD'), '\n', '')
    local git_url = vim.fn.system('git remote get-url origin')
    local git_url = string.gsub(git_url, ':', '/')
    local git_url = string.gsub(git_url, 'git@', 'https://')
    local git_url = string.gsub(git_url, '%.git', '/compare/' .. branch .. '?expand=1')
    print(git_url)
    vim.fn.system('firefox ' .. git_url)
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

-- paste above or below
vim.api.nvim_set_keymap('n', '<leader><leader>p', 'o<Esc>p', optsrsw)
vim.api.nvim_set_keymap('n', '<leader><leader>P', 'O<Esc>p', optsrsw)

-- vim color scheme switcher
-- vim.api.nvim_set_keymap('n', '<leader>cp', ':PrevColorScheme<CR>', optsrs)
-- vim.api.nvim_set_keymap('n', '<leader>cn', ':NextColorScheme<CR>', optsrs)

-- camelcasemotion
vim.cmd [[
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

-- create function that is a partial right of vim.keymap.set where the last arg is optsrs
local function set_keymap(...)
    local args = { ... }
    table.insert(args, optsrs)
    vim.keymap.set(unpack(args))
end

-- telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', function() builtin.find_files({ hidden = true }) end, optsrs)
vim.keymap.set('n', '<leader>fg', function() builtin.live_grep({ hidden = true }) end, optsrs)
vim.keymap.set('n', '<leader>fb', function() builtin.buffers() end, optsrs)
vim.keymap.set('n', '<leader>fh', function() builtin.help_tags() end, optsrs)
vim.keymap.set('n', '<leader>/',
    function() builtin.current_buffer_fuzzy_find({ fuzzy = false, case_mode = 'ignore_case' }) end, optsrs)
vim.keymap.set('n', '<leader>D', function() builtin.diagnostics({ bufnr = 0 }) end, optsrs)
vim.keymap.set('n', '<leader>da', function() builtin.diagnostics() end, optsrs)
vim.keymap.set('n', '<leader>dw', function()
    builtin.diagnostics({
        severity = vim.diagnostic.severity.WARN,
    })
end, optsrs)
vim.keymap.set('n', '<leader>de', function()
    builtin.diagnostics({
        severity = vim.diagnostic.severity.ERROR,
    })
end, optsrs)
vim.keymap.set('n', '<leader>gc', function() builtin.git_commits() end, optsrs)
vim.keymap.set('n', '<leader>gC', function() builtin.git_bcommits() end, optsrs)
vim.keymap.set('n', '<leader>gb', function() builtin.git_branches() end, optsrs)
vim.keymap.set('n', '<leader>gs', function() builtin.git_status() end, optsrs)

vim.cmd([[
function!   QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_val = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction
]])

vim.api.nvim_set_keymap('n', '<leader>ka', ':call QuickFixOpenAll()<CR>', { noremap = true, silent = false })

-- lua snippets
vim.cmd [[
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
vim.cmd [[
    imap <silent><script><expr> <C-J> copilot#Accept("\<CR>")
]]

-- hide background
-- function to run highlight Normal guibg=none
-- and highlight NonText guibg=none
vim.cmd [[
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
