vim.cmd[[
nnoremap <leader>pd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
nnoremap <leader>pi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
nnoremap <leader>P <cmd>lua require('goto-preview').close_all_win()<CR>
" Only set if you have telescope installed
nnoremap <leader>pr <cmd>lua require('goto-preview').goto_preview_references()<CR>
]]
