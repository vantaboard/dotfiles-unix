require("nvim-tree").setup({
    trash = {
        cmd = "gio trash",
        require_confirm = false,
    },
    on_attach = function(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
            return {
                desc = "nvim-tree: " .. desc,
                buffer = bufnr,
                noremap = true,
                silent = true,
                nowait = true,
            }
        end
        api.config.mappings.default_on_attach(bufnr)

        vim.keymap.set("n", "d", api.fs.trash, opts("Trash"))
    end,
})

vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<cr>")
vim.keymap.set("n", "<leader>r", ":NvimTreeRefresh<cr>")
vim.keymap.set("n", "<leader>n", ":NvimTreeFindFile<cr>")
