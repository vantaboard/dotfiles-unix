-- lua/autocommands.lua
local Job = require("plenary.job")

vim.api.nvim_create_augroup("reload queries on query save", { clear = true })
vim.api.nvim_create_autocmd("BufWrite", {
    pattern = "*.scm",
    callback = function()
        require("nvim-treesitter.query").invalidate_query_cache()
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        Job:new({
        command = "termux-clipboard-set",
        writer = vim.fn.getreg("@"),
    }):start()
    end,
})

vim.cmd[[
function Paste(p)
    let sysclip=system('termux-clipboard-get')
    if sysclip != @"
        let @"=sysclip
    endif
    return a:p
endfunction
noremap <expr> p Paste('p')
noremap <expr> P Paste('P')
]]

vim.api.nvim_create_autocmd("BufNewFile,BufRead", {
    pattern = "tsconfig.json",
    callback = function()
        vim.bo.filetype = "jsonc"
    end,
})

vim.api.nvim_create_autocmd("BufNewFile,BufRead", {
    pattern = "~/.alias-git",
    callback = function()
        vim.bo.filetype = "csh"
    end,
})

vim.api.nvim_create_autocmd("BufNewFile,BufRead", {
    pattern = "~/.bindings",
    callback = function()
        vim.bo.filetype = "csh"
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
        if
            vim.fn.line("'\"") >= 1
            and vim.fn.line("'\"") <= vim.fn.line("$")
            and vim.bo.filetype ~= "commit"
        then
            vim.cmd('normal! g`"')
        end
    end,
})
