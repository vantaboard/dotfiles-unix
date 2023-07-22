require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "javascript",
        "typescript",
        "graphql",
        "glimmer",
        "json",
        "c",
        "lua",
        "rust",
        "cpp",
    },
    sync_install = false,
    auto_install = true,

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true,
        use_languagetree = true,
    },

    context_commentstring = {
        enable = true,
    },

    indent = { enable = false },

    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = 1000,
    },

    autotag = {
        enable = 'disable',
    },
    playground = {
        enable = true,
        disable = {},
        updatetime = 25,
        persist_queries = false,
        keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
        },
    },
    textsubjects = {
        enable = true,
        prev_selection = ",",
        keymaps = {
            ["."] = "textsubjects-smart",
            [";"] = "textsubjects-container-outer",
            ["i;"] = "textsubjects-container-inner",
        },
    },
    refactor = {
        smart_rename = {
            enable = true,
            keymaps = {
                smart_rename = "grr",
            },
        },
        navigation = {
            enable = true,
            keymaps = {
                goto_definition = "gnd",
                list_definitions = "gnD",
                list_definitions_toc = "gO",
                goto_next_usage = "<a-*>",
                goto_previous_usage = "<a-#>",
            },
        },
    },
})
