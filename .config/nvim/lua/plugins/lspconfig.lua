require("neodev").setup({})
require("neoconf").setup({})

local util = require("lspconfig/util")

local lspconfig = require("lspconfig")

local cmp = require("cmp")
local lspkind = require("lspkind")

require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup({
    snippet = {
        expand = function(args)
            require("luasnip").lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<C-j>"] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = "luasnip" },
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lsp" },
    }, {
        { name = "buffer" },
    }),
    formatting = {
        format = lspkind.cmp_format({
            mode = "symbol",
            maxwidth = 50,
            with_text = true,
        }),
    },
})

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "git" },
    }, {
        { name = "buffer" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

vim.cmd('highlight! default link CmpItemKind CmpItemMenuDefault')
vim.opt.completeopt = { "menuone", "noinsert", "noselect" }

cmp.setup.filetype("gitcommit", {
    sources = cmp.config.sources({
        { name = "cmp_git" },
    }, {
        { name = "buffer" },
    }),
})

cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = "buffer" },
    },
})

cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = "path" },
    }, {
        { name = "cmdline" },
    }),
})

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local on_attach = function()
    vim.keymap.set("n", "<leader>d", vim.lsp.buf.definition)
    vim.keymap.set("n", "gr", vim.lsp.buf.rename)
    vim.keymap.set("n", "gy", vim.lsp.buf.type_definition)
    vim.keymap.set("n", "K", vim.lsp.buf.hover)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.references)
    vim.keymap.set("n", "<leader>q", function()
        vim.lsp.buf.format({ async = true })
    end)
    vim.keymap.set("v", "<leader>q", vim.lsp.buf.format)
    vim.keymap.set("n", "<leader>,", function()
        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
    end)
    vim.keymap.set("n", "<leader>.", function()
        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
    end)
    vim.keymap.set("n", "<leader><leader>,", function()
        vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })
    end)
    vim.keymap.set("n", "<leader><leader>.", function()
        vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })
    end)
    vim.keymap.set("n", "<leader><", vim.diagnostic.goto_prev)
    vim.keymap.set("n", "<leader>>", vim.diagnostic.goto_next)
    vim.keymap.set("n", "<leader>a", vim.lsp.buf.code_action)
    vim.keymap.set("n", "<Leader>va", vim.diagnostic.open_float)
    vim.keymap.set("i", "<C-x><C-x>", vim.lsp.buf.signature_help)

    -- if the file is .sql
    if vim.bo.filetype == "sql" then
        vim.keymap.set(
            "n",
            "<leader>q",
            ":!sqlfluff fix -fq --dialect=postgres %<cr>"
        )
    end
end

lspconfig.jsonls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

lspconfig.rust_analyzer.setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

local rt = require("rust-tools")

rt.setup({
    server = {
        on_attach = function()
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions)
            vim.keymap.set(
                "n",
                "<leader>a",
                rt.code_action_group.code_action_group
            )
            on_attach()
        end,
    },
})

lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
        Lua = {
            diagnostics = {
                globals = { "vim" },
            },
            completion = {
                callSnippet = "Replace",
            },
        },
    },
})

lspconfig.gopls.setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod" },
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
})

lspconfig.texlab.setup({
    capabilities = capabilities,
    settings = {
        texlab = {
            auxDirectory = ".",
            bibtexFormatter = "texlab",
            build = {
                args = {
                    "-pdf",
                    "-interaction=nonstopmode",
                    "-synctex=1",
                    "%f",
                },
                executable = "pdflatex",
                forwardSearchAfter = false,
                onSave = true,
            },
            chktex = {
                onEdit = false,
                onOpenAndSave = false,
            },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
            forwardSearch = {
                args = {},
            },
            latexFormatter = "latexindent",
            latexindent = {
                modifyLineBreaks = false,
            },
        },
    },
    on_attach = on_attach,
})

require("lspconfig").yamlls.setup({
    settings = {
        yaml = {
            schemaStore = {
                enable = false,
            },
            schemas = require("schemastore").yaml.schemas(),
        },
    },
})

require("typescript").setup({
    server = {
        root_dir = util.root_pattern(
            "package.json",
            "tsconfig.json",
            "jsconfig.json",
            ".git"
        ),
        on_attach = function()
            on_attach()
        end,
        settings = {
            javascript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                    importModuleSpecifierPreference = "non-relative",
                },
            },
            typescript = {
                inlayHints = {
                    includeInlayParameterNameHints = "all",
                    includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                    includeInlayFunctionParameterTypeHints = true,
                    includeInlayVariableTypeHints = true,
                    includeInlayPropertyDeclarationTypeHints = true,
                    includeInlayFunctionLikeReturnTypeHints = true,
                    includeInlayEnumMemberValueHints = true,
                    importModuleSpecifierPreference = "non-relative",
                },
            },
        },
    },
})

local null_ls = require("null-ls")

null_ls.setup({
    root_dir = require("null-ls.utils").root_pattern("tsconfig.json"),
    sources = {
        require("typescript.extensions.null-ls.code-actions"),
        null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect=postgres" },
        }),
        null_ls.builtins.completion.luasnip,
        null_ls.builtins.formatting.uncrustify,
        null_ls.builtins.formatting.clang_format,
        null_ls.builtins.diagnostics.cpplint,
        null_ls.builtins.diagnostics.cppcheck,
        null_ls.builtins.hover.printenv,
        null_ls.builtins.formatting.shellharden,
        null_ls.builtins.diagnostics.shellcheck,
        null_ls.builtins.code_actions.shellcheck,
        null_ls.builtins.formatting.beautysh,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.eslint_d,
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.formatting.eslint_d,
        null_ls.builtins.formatting.prettier,
    },
    on_attach = function()
        vim.keymap.set("v", "<leader>f", vim.lsp.buf.format)
        on_attach()
    end,
})

lspconfig.clangd.setup({
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
    },
    filetypes = { "c", "cc", "cpp", "objc", "objcpp", "cuda", "proto" },
    capabilities = capabilities,
    on_attach = on_attach,
})

lspconfig.pyright.setup({
    capabilities = capabilities,
    on_attach = on_attach,
})
