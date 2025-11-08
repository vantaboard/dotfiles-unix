require("textcase").setup({})
local telescope = require("telescope")

local open_in_nvim_tree = function()
    local action_state = require("telescope.actions.state")
    local Path = require("plenary.path")

    local entry = action_state.get_selected_entry()[1]
    local entry_path = Path:new(entry):parent():absolute()
    entry_path = Path:new(entry):parent():absolute()
    entry_path = entry_path:gsub("\\", "\\\\")

    vim.cmd("NvimTreeClose")
    vim.cmd("NvimTreeOpen " .. entry_path)

    local file_name = nil
    for s in string.gmatch(entry, "[^/]+") do
        file_name = s
    end

    vim.cmd("/" .. file_name)
end

local utils = require("yanky.utils")
local mapping = require("yanky.telescope.mapping")
require("yanky").setup({
    preserve_cursor_position = {
        enabled = true,
    },
    highlight = {
        on_put = false,
        on_yank = false,
    },
    picker = {
        telescope = {
            mappings = {
                default = mapping.put("p"),
                i = {
                    -- make return key add to default register
                    ["<cr>"] = mapping.set_register(
                        utils.get_default_register()
                    ),
                    ["<c-s>"] = mapping.set_register,
                    ["<c-x>"] = mapping.delete(),
                },
                n = {
                    p = mapping.put("p"),
                    P = mapping.put("P"),
                    d = mapping.delete(),
                    r = mapping.set_register(utils.get_default_register()),
                },
            },
        },
    },
})

local actions = require("telescope.actions")
telescope.load_extension("fzf")
telescope.load_extension("harpoon")
telescope.load_extension("dap")
telescope.load_extension("yank_history")
telescope.load_extension("undo")
telescope.load_extension("textcase")

telescope.setup({
    defaults = {
        file_ignore_patterns = {
            ".git/.*",
            "pdm.lock",
        },
        vimgrep_arguments = {
            'rg',
            '--color=never',
            '--no-heading',
            '--with-filename',
            '--line-number',
            '--column',
            '--smart-case',
            "--no-ignore",
        },
        mappings = {
            i = {
                ["C-Q"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<C-u>"] = false,
                ["<C-j>"] = actions.cycle_history_next,
                ["<C-k>"] = actions.cycle_history_prev,
                ["<c-s>"] = open_in_nvim_tree,
                ["<C-w>"] = actions.send_selected_to_qflist
                    + actions.open_qflist,
            },
            n = {
                ["<c-s>"] = open_in_nvim_tree,
            },
        },
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
        },
        undo = {
            use_delta = true,
            use_custom_command = nil,
            side_by_side = false,
            diff_context_lines = vim.o.scrolloff,
            entry_format = "state #$ID, $STAT, $TIME",
            time_format = "",
            mappings = {
                i = {
                    ["<cr>"] = require("telescope-undo.actions").restore,
                },
            },
        },
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        },
    },
})

-- disable backups
vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true
vim.o.undodir = vim.fn.expand("~/.vim/undo")

---------- mappings ----------
-- built ins

if vim.g.vscode then
    -- VSCode extension
    local code = require('vscode')

    vim.keymap.set("n", "<leader>ff", function()
        code.action('periscope.searchFiles')
    end)

    vim.keymap.set("n", "<leader>fg", function()
        code.action('periscope.search')
    end)

    vim.keymap.set("n", "<leader>/", function()
        code.action('periscope.searchCurrentFile')
    end)
else
    -- ordinary Neovim
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", function()
        builtin.find_files({ hidden = true, no_ignore = true })
    end)
    vim.keymap.set("n", "<leader>fg", function()
        builtin.live_grep({ hidden = true, no_ignore = true })
    end)
    vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find({
            fuzzy = false,
            case_mode = "ignore_case",
        })
    end)
    vim.keymap.set("n", "<leader>D", function()
        builtin.diagnostics({ bufnr = 0 })
    end)
    vim.keymap.set("n", "<leader>da", builtin.diagnostics)
    vim.keymap.set("n", "<leader>dw", function()
        builtin.diagnostics({
            severity = vim.diagnostic.severity.WARN,
        })
    end)
    vim.keymap.set("n", "<leader>de", function()
        builtin.diagnostics({
            severity = vim.diagnostic.severity.ERROR,
        })
    end)

    -- resume picker
    vim.keymap.set("n", "<leader>R", ":Telescope resume<cr>")

    -- get all pickers
    vim.keymap.set("n", "<leader>p", ":Telescope<cr>")

    -- yank history
    vim.keymap.set("n", "<leader>y", ":Telescope yank_history<cr>")

    -- dap
    vim.keymap.set("n", "<leader>ds", ":Telescope dap frames<cr>")
    vim.keymap.set("n", "<leader>dc", ":Telescope dap commands<cr>")
    vim.keymap.set("n", "<leader>db", ":Telescope dap list_breakpoints<cr>")
    vim.keymap.set("n", "<leader>dv", ":Telescope dap variables<cr>")

    -- harpoon
    vim.keymap.set("n", "<leader>h", ":Telescope harpoon marks<cr>")

    -- color scheme
    vim.keymap.set("n", "<leader><leader>o", function()
        builtin.colorscheme({
            enable_preview = true,
        })
    end)

    -- command history
    vim.keymap.set("n", "<leader>:", ":Telescope command_history<cr>")
end
