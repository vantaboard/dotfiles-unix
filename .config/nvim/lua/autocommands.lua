vim.api.nvim_create_augroup("reload queries on query save", { clear = true })
vim.api.nvim_create_autocmd("BufWrite", {
    pattern = "*.scm",
    callback = function()
        require("nvim-treesitter.query").invalidate_query_cache()
    end,
})

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.cmd("TransparentEnable")
    end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = "tsconfig.json",
    callback = function()
        vim.bo.filetype = "jsonc"
    end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = ".alias-secret",
    callback = function()
        print("alias secret")
        vim.bo.filetype = "csh"
    end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = ".alias-git",
    callback = function()
        vim.bo.filetype = "csh"
    end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
    pattern = ".bindings",
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
