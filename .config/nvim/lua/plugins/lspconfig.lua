require("neodev").setup({})
local util = require("lspconfig/util")

local lspconfig = require("lspconfig")
local buf_map = function(bufnr, mode, lhs, rhs, opts)
    vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts or {
        silent = true,
    })
end

local cmp = require 'cmp'
local lspkind = require('lspkind')

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<C-J>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp_signature_help' },
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
    }, {
        { name = 'buffer' },
    }),
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol', -- show only symbol annotations
            maxwidth = 50,   -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            with_text = true,
            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, vim_item)
                return vim_item
            end
        })
    }
})

vim.cmd [[
    set completeopt=menuone,noinsert,noselect
    highlight! default link CmpItemKind CmpItemMenuDefault
]]

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
    }, {
        { name = 'buffer' },
    })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})



-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local on_attach = function(client, bufnr)
    vim.cmd("command! LspImplementation lua vim.lsp.buf.implementation()")
    buf_map(bufnr, "n", "<leader>d", "<cmd>lua vim.lsp.buf.definition()<cr>")
    buf_map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.rename()<cr>")
    buf_map(bufnr, "n", "gy", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
    buf_map(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
    buf_map(bufnr, "n", "<leader>r", "<cmd>lua vim.lsp.buf.references()<cr>")
    buf_map(bufnr, "n", "<leader>q",
        '<cmd>lua vim.lsp.buf.format({ async = true })<cr>')
    buf_map(bufnr, "v", "<leader>q",
        '<cmd>lua vim.lsp.buf.format()<cr>')
    buf_map(bufnr, "n", "<leader>,",
        "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<cr>")
    buf_map(bufnr, "n", "<leader>.",
        "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<cr>")
    buf_map(bufnr, "n", "<leader><leader>,",
        "<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.WARN })<cr>")
    buf_map(bufnr, "n", "<leader><leader>.",
        "<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.WARN })<cr>")
    buf_map(bufnr, "n", "<leader><", "<cmd>lua vim.diagnostic.goto_prev()<cr>")
    buf_map(bufnr, "n", "<leader>>", "<cmd>lua vim.diagnostic.goto_next()<cr>")
    buf_map(bufnr, "n", "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>")
    buf_map(bufnr, "n", "<Leader>va", "<cmd>lua vim.diagnostic.open_float()<cr>")
    buf_map(bufnr, "i", "<C-x><C-x>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

    -- if the file is .sql
    if (vim.bo.filetype == "sql") then
        buf_map(bufnr, "n", "<leader>q", ":!sqlfluff fix -fq --dialect=postgres %<cr>")
    end

    -- if client.server_capabilities.inlayHintProvider then
    --     vim.lsp.buf.inlay_hint(bufnr, true)
    -- end

    -- if client.server_capabilities.document_formatting then
    --     vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    -- end
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
        on_attach = function(_, bufnr)
            -- Hover actions
            vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
            -- Code action groups
            vim.keymap.set("n", "<leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
            on_attach(_, bufnr)
        end,
    },
})

lspconfig.gopls.setup {
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
}

lspconfig.lua_ls.setup({
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
        on_attach(client, bufnr)
    end,
    settings = {
        Lua = {
            format = {
                enable = true,
            },
            diagnostics = {
                neededFileStatus = {
                    ["codestyle-check"] = "Any",
                },
                groupSeverity = { ["codestyle-check"] = "Warning", },
            },
            workspace = {
                checkThirdParty = false,
            },
            completion = {
                callSnippet = "Replace",
            },
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
                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                executable = "pdflatex",
                forwardSearchAfter = false,
                onSave = true
            },
            chktex = {
                onEdit = false,
                onOpenAndSave = false
            },
            diagnosticsDelay = 300,
            formatterLineLength = 80,
            forwardSearch = {
                args = {}
            },
            latexFormatter = "latexindent",
            latexindent = {
                modifyLineBreaks = false
            }
        }
    },
    on_attach = on_attach
})

require('lspconfig').yamlls.setup {
    settings = {
        yaml = {
            schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "docker-compose.yml"
            },
        },
    }
}

lspconfig.tsserver.setup({
    root_dir = util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
    init_options = {
        preferences = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = true,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
            importModuleSpecifierPreference = 'non-relative'
        },
    },
    on_attach = function(client, bufnr)
        client.server_capabilities.document_formatting = false
        client.server_capabilities.document_range_formatting = false
        on_attach(client, bufnr)
    end,
})

local null_ls = require("null-ls");

null_ls.setup({
    root_dir = require("null-ls.utils").root_pattern("tsconfig.json"),
    sources = {
        require("typescript.extensions.null-ls.code-actions"),
        null_ls.builtins.diagnostics.sqlfluff.with({
            extra_args = { "--dialect=postgres" },
        }),
        null_ls.builtins.diagnostics.eslint_d.with({}),
        null_ls.builtins.code_actions.eslint_d.with({}),
        null_ls.builtins.formatting.eslint_d.with({}),
        null_ls.builtins.formatting.prettier.with({}),
    },
    on_attach = function(client, bufnr)
        -- https://www.reddit.com/r/neovim/comments/zv91wz/range_formatting/
        local range_formatting = function()
            local start_row, _ = unpack(vim.api.nvim_buf_get_mark(0, "<"))
            local end_row, _ = unpack(vim.api.nvim_buf_get_mark(0, ">"))
            vim.lsp.buf.format({
                range = {
                    ["start"] = { start_row, 0 },
                    ["end"] = { end_row, 0 },
                },
                async = true,
            })
        end

        vim.keymap.set("v", "<leader>f", vim.lsp.buf.format)
        on_attach(client, bufnr)
    end
})

lspconfig.clangd.setup {
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
    },
    filetypes = { "c", "cc", "cpp", "objc", "objcpp", "cuda", "proto" },
    capabilities = capabilities,
    on_attach = on_attach,
}

lspconfig.pyright.setup {
    capabilities = capabilities,
    on_attach = on_attach
}
