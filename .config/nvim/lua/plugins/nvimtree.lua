local api = require("nvim-tree.api")

require("nvim-tree").setup({
    trash = {
        cmd = "gio trash",
        require_confirm = false,
    },
    filters = {
        custom = {
            "^.null-ls*"
        },
        git_ignored = false
    },
    on_attach = function(bufnr)
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

vim.keymap.set("n", "<C-n>", function() api.tree.toggle() end)
vim.keymap.set("n", "<leader>r", function() api.tree.refresh() end)
vim.keymap.set("n", "<leader>n", function() api.tree.find_file({ open = true, focus = true }) end)
vim.keymap.set("n", "<leader><leader>n", function()
    api.tree.find_file({
        update_root = true,
        open = true,
        focus = true
    })
end)

