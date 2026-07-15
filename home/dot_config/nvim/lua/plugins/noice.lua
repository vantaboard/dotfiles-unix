require("notify").setup({
    top_down = false, -- bottom-right instead of top-right
})

require("noice").setup({
    lsp = {
        -- override markdown rendering so that cmp and other plugins use Treesitter
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    presets = {
        bottom_search = true, -- use a classic bottom cmdline for search
        command_palette = true, -- position the cmdline and popupmenu together
        long_message_to_split = true, -- long messages will be sent to a split
        inc_rename = false, -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false, -- add a border to hover docs and signature help
    },
})

-- message history in telescope (:Telescope noice)
require("telescope").load_extension("noice")

vim.keymap.set("n", "<leader>nh", ":Noice history<cr>")
vim.keymap.set("n", "<leader>nl", ":Noice last<cr>")
vim.keymap.set("n", "<leader>nd", ":Noice dismiss<cr>")

-- scroll lsp hover docs
vim.keymap.set({ "n", "i", "s" }, "<c-f>", function()
    if not require("noice.lsp").scroll(4) then
        return "<c-f>"
    end
end, { silent = true, expr = true })

vim.keymap.set({ "n", "i", "s" }, "<c-b>", function()
    if not require("noice.lsp").scroll(-4) then
        return "<c-b>"
    end
end, { silent = true, expr = true })
