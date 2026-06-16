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
    "hipster-green",
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

vim.cmd(
    "colorscheme hipster-green"
)

vim.api.nvim_set_hl(0, "LspInlayHint", { fg = "#246db2", italic = true })

-- unicode
vim.opt.encoding = "utf8"
vim.opt.fileencoding = "utf8"

-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 8

-- Sync yanks with the system clipboard when a provider is available.
-- wl-paste prints "target STRING not available" when the clipboard is empty.
-- Paste commands must run via sh -c: Neovim splits string providers into argv,
-- so "wl-paste 2>/dev/null" would pass 2>/dev/null as a literal argument.
local function setup_clipboard()
    if vim.fn.has("clipboard") ~= 1 then
        return
    end

    if vim.fn.executable("termux-clipboard-set") == 1 and vim.fn.executable("termux-clipboard-get") == 1 then
        vim.g.clipboard = {
            name = "termux-clipboard",
            copy = {
                ["+"] = "termux-clipboard-set",
                ["*"] = "termux-clipboard-set",
            },
            paste = {
                ["+"] = "termux-clipboard-get",
                ["*"] = "termux-clipboard-get",
            },
            cache_enabled = 1,
        }
    elseif vim.fn.executable("wl-copy") == 1 and os.getenv("WAYLAND_DISPLAY") then
        vim.g.clipboard = {
            name = "wl-clipboard",
            copy = {
                ["+"] = "wl-copy",
                ["*"] = "wl-copy --primary",
            },
            paste = {
                ["+"] = { "sh", "-c", "wl-paste 2>/dev/null || true" },
                ["*"] = { "sh", "-c", "wl-paste --primary 2>/dev/null || true" },
            },
            -- Do not cache: with cache on, an empty read at startup sticks until Neovim
            -- yanks to + itself, so Chrome/other-app copies never appear on paste.
            cache_enabled = 0,
        }
    else
        return
    end

    vim.opt.clipboard = "unnamedplus"
end
setup_clipboard()

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
-- require("formatter").setup {
--     -- Enable or disable logging
--     logging = true,
--     -- Set the log level
--     log_level = vim.log.levels.WARN,
--     -- All formatter configurations are opt-in
--     filetype = {
--         glsl = format_glsl,
--         frag = format_glsl,
--         vert = format_glsl,
--         tesc = format_glsl,
--         tese = format_glsl,
--         geom = format_glsl,
--         comp = format_glsl,
--         css = {
--             -- prettier
--             function()
--                 return {
--                     exe = "prettier",
--                     args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
--                     stdin = true,
--                 }
--             end,
--         },
--         yml = {
--             function()
--                 return {
--                     exe = "prettier",
--                     args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
--                     stdin = true,
--                 }
--             end,
--         },
--         yaml = {
--             function()
--                 return {
--                     exe = "prettier",
--                     args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
--                     stdin = true,
--                 }
--             end,
--         },
--         toml = {
--             function()
--                 return {
--                     exe = "prettier",
--                     args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
--                     stdin = true,
--                 }
--             end,
--         },
--         liquid = {
--             function()
--                 return {
--                     exe = "prettier",
--                     args = { "--stdin-filepath", vim.api.nvim_buf_get_name(0) },
--                     stdin = true,
--                 }
--             end,
--         },
--         rst = {
--             function()
--                 return {
--                     exe = "rstfmt",
--                     stdin = true,
--                 }
--             end,
--         },
--     }
-- }
