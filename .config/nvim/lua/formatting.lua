-- lua/formatting.lua
vim.filetype.add({
    extension = {
        vert = "glsl",
        frag = "glsl",
    },
})

vim.g.copilot_filetypes = {
    glsl = false,
    vert = false,
    frag = false,
    tesc = false,
    tese = false,
    geom = false,
    comp = false,
    VimspectorPrompt = false,
    TelescopePrompt = false,
    TelescopeResults = false,
}

vim.g.fzf_colors = {
    fg = { "fg", "Normal" },
    bg = { "bg", "Normal" },
    ['preview-fg'] = { "bg", "Normal" },
    ['preview-bg'] = { "bg", "NormalFloat" },
    hl = { "fg", "Comment" },
    ['fg+'] = { "fg", "CursorLine", "CursorColumn", "Normal" },
    ['bg+'] = { "bg", "CursorLine", "CursorColumn" },
    ['hl+'] = { "fg", "Statement" },
    info = { "fg", "PreProc" },
    border = { "fg", "Ignore" },
    prompt = { "fg", "Conditional" },
    pointer = { "fg", "Exception" },
    marker = { "fg", "Keyword" },
    spinner = { "fg", "Label" },
    gutter = { "bg", "SignColumn" },
    query = { "fg", "Comment" },
    disabled = { "fg", "Ignore" },
    header = { "fg", "Comment" },
}

vim.keymap.set("n", ";", "<Nop>")
vim.g.mapleader = " "

vim.opt.hlsearch = false
vim.opt.signcolumn = "yes"

-- inverted cursor please!
vim.opt.guicursor = ""

-- wrap
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.showbreak = "↳  "

-- camelCaseMotion
vim.g.camelcasemotion_key = "<leader>"

local favorite_colorschemes = {
    "kanagawa",
    "nightfox",
    "cyberdream",
    "nightfly",
    "moonfly",
    "tokyonight-night",
    -- "wildcharm",
    -- "abscs",
    "radioactive_waste",
    "boo",
    -- "nvimgelion",
    "citruszest",
    -- "night-owl",
    "miasma",
    "eldritch",
    -- "miss-dracula",
    -- "aurora",
    -- "dracula",
    -- -- "vn-night",
    -- "oxocarbon",
    -- "omni",
    -- "tokyonight",
    -- "snazzy",
    -- "OceanicNext",
    -- "catppuccin-mocha",
    -- "terafox",
    -- "solarized-high",
    -- "rose-pine-main",
    -- "fluoromachine",
    -- "zenburned",
    -- "codeschool",
    -- "brighten",
}

-- random colorscheme
-- seed based on the current hour, so that it changes every 5 minutes
-- math.randomseed(tonumber(os.date("%H")) * 300)

math.randomseed(os.time())

vim.cmd(
    "colorscheme " .. favorite_colorschemes[math.random(#favorite_colorschemes)]
)

vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#002b80" })
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#FF2b80" })

-- unicode
vim.opt.encoding = "utf8"
vim.opt.fileencoding = "utf8"

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 8

-- Set clipboard
vim.opt.clipboard = "unnamedplus"

-- Set color column
vim.wo.colorcolumn = "120"

-- Tab stops
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Enable break indent
vim.o.breakindent = true

-- good indenting
vim.o.autoindent = true
vim.o.smartindent = true

-- Case insensitive search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Always global substitute
vim.o.gdefault = true

-- Set colorscheme
vim.o.termguicolors = true

local util = require "formatter.util"

local format_glsl = function()
    return {
        exe = "clang-format",
        args = { "-style=chromium" },
        stdin = true,
    }
end

-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
require("formatter").setup {
    -- Enable or disable logging
    logging = true,
    -- Set the log level
    log_level = vim.log.levels.WARN,
    -- All formatter configurations are opt-in
    filetype = {
        glsl = format_glsl,
        frag = format_glsl,
        vert = format_glsl,
        tesc = format_glsl,
        tese = format_glsl,
        geom = format_glsl,
        comp = format_glsl,
        css = {
            -- prettier
            function()
                return {
                    exe = "prettier",
                    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                    stdin = true,
                }
            end,
        },
        yml = {
            function()
                return {
                    exe = "prettier",
                    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                    stdin = true,
                }
            end,
        },
        yaml = {
            function()
                return {
                    exe = "prettier",
                    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                    stdin = true,
                }
            end,
        },
        toml = {
            function()
                return {
                    exe = "prettier",
                    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                    stdin = true,
                }
            end,
        },
        liquid = {
            function()
                return {
                    exe = "prettier",
                    args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
                    stdin = true,
                }
            end,
        },
        rst = {
            function()
                return {
                    exe = "rstfmt",
                    stdin = true,
                }
            end,
        },
        python = {
            function()
                return {
                    exe = "ruff",
                    args = { "--fix-only", "--stdin-filename", vim.api.nvim_buf_get_name(0) },
                    stdin = true,
                }
            end,
        },
    }
}
