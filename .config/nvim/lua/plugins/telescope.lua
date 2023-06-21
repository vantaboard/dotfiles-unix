local open_in_nvim_tree = function(prompt_bufnr)
    local action_state = require "telescope.actions.state"
    local Path = require "plenary.path"
    local actions = require "telescope.actions"

    local entry = action_state.get_selected_entry()[1]
    local entry_path = Path:new(entry):parent():absolute()
    actions._close(prompt_bufnr, true)
    entry_path = Path:new(entry):parent():absolute()
    entry_path = entry_path:gsub("\\", "\\\\")

    vim.cmd("NvimTreeClose")
    vim.cmd("NvimTreeOpen " .. entry_path)

    file_name = nil
    for s in string.gmatch(entry, "[^/]+") do
        file_name = s
    end

    vim.cmd("/" .. file_name)
end

actions = require("telescope.actions")
require("telescope").load_extension("ui-select")
require('telescope').load_extension('fzf')
require("telescope").load_extension("harpoon")
require('telescope').load_extension('dap')
require("telescope").load_extension("undo")

require('textcase').setup {}
require('telescope').load_extension('textcase')
vim.api.nvim_set_keymap('n', 'ga.', '<cmd>TextCaseOpenTelescope<CR>', { desc = "Telescope" })
vim.api.nvim_set_keymap('v', 'ga.', "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })

require("telescope").setup {
    defaults = {
        mappings = {
            i = {
                ["<c-s>"] = open_in_nvim_tree,
                ["<C-w>"] = actions.send_selected_to_qflist + actions.open_qflist,
            },
            n = {
                ["<c-s>"] = open_in_nvim_tree,
            },
        },
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {}
        },
        fzf = {
            fuzzy = true,             -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        }
    }
}

-- disable backups
vim.cmd([[
    set noswapfile
    set nobackup
    set undofile
    set undodir=~/.vim/undo
]])

local optsrws = { noremap = true, silent = true, nowait = true }
vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
