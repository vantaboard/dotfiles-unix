local util = require("lspconfig/util")
local lspconfig = require("lspconfig")
local rt = require("rust-tools")
local configs = require 'lspconfig/configs'
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local schemastore = require("schemastore")
require("neoconf").setup({})

-- local neoconf = require("neoconf")

local keyset = vim.keymap.set
local lbuf = vim.lsp.buf
local diag = vim.diagnostic

local function set_severity(severity, next_or_prev)
    if next_or_prev == "next" then
        return function()
            diag.goto_next({ severity = severity })
        end
    elseif next_or_prev == "prev" then
        return function()
            diag.goto_prev({ severity = severity })
        end
    end
end

local null_ls = require("null-ls")

null_ls.setup({
    sources = {
        null_ls.builtins.diagnostics.sqlfluff,
        null_ls.builtins.formatting.sqlfluff,
    },
})

---@diagnostic disable-next-line: unused-local
local on_attach = function(client, bufnr)
    keyset("v", "<leader>f", lbuf.format)

    keyset("n", "<leader>d", lbuf.definition)

    if client.name == "pylsp" then
        client.server_capabilities.documentFormattingProvider = false
    end

    if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
    end

    if client.name == "volar" then
        keyset("n", "<leader>d", ":TypescriptGoToSourceDefinition<cr>", { silent = true, nowait = true })
    end

    keyset("n", "gr", lbuf.rename)
    keyset("n", "gy", lbuf.type_definition)
    keyset("n", "K", lbuf.hover)
    keyset("n", "<leader>r", lbuf.references)
    keyset("n", "<leader>q", function()
        lbuf.format({ async = true, filter = function(filter_client) return filter_client.name ~= "volar" end })
    end)

    if client.name == "cssls" or client.name == "glslls" or client.name == "yamlls" or client.name == "theme_check" or client.name == "esbonio" then
        keyset("n", "<leader>q", function()
            vim.cmd("Format")
        end)
    end

    if client.name == "ruff" then
        keyset("n", "<leader>q", function()
            lbuf.format()
            vim.cmd("Format")
        end)
    end

    keyset("v", "<leader>q", lbuf.format)
    keyset("n", "<leader>,", set_severity(diag.severity.ERROR, "prev"))
    keyset("n", "<leader>.", set_severity(diag.severity.ERROR, "next"))
    keyset("n", "<leader><", diag.goto_prev)
    keyset("n", "<leader>>", diag.goto_next)
    keyset("n", "<leader>a", lbuf.code_action)
    keyset("n", "<Leader>va", diag.open_float)
    keyset("i", "<C-x><C-x>", lbuf.signature_help)

    if vim.bo.filetype == "sql" then
        keyset("n", "<leader>q", ":!sqlfluff fix -fq --dialect=postgres %<cr>")
    end
end

require("mason").setup({})
require("mason-lspconfig").setup({
    ensure_installed = {
        "jdtls",
        "marksman",
        "denols",
        "taplo",
        "tflint",
        "terraformls",
        "cssls",
        -- "vtsls",
        "html",
        "eslint",
        "bashls",
        "powershell_es",
        -- "glslls",
        "jsonls",
        "rust_analyzer",
        "lua_ls",
        "yamlls",
        "clangd",
        "pylsp",
        "csharp_ls",
        "pyright",
        "ruff",
        "volar",
        "theme_check",
    }
});

require('mason-lspconfig').setup_handlers({
    function(lsp)
        local config = {
            capabilities = capabilities,
            on_attach = on_attach,
        }

        if lsp == "jdtls" then
            config.settings = {
                java = {
                    import = {
                        gradle = {
                            wrapper = {
                                enabled = true,
                                checksums = {
                                    { sha256 = "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", allowed = true },
                                }
                            }
                        }
                    },
                },
            }
        end

        if lsp == "pylsp" then
            config.settings = {
                pylsp = {
                    plugins = {
                        autopep8 = {
                            enabled = false,
                        },
                        jedi_completion = {
                            enabled = false,
                        },
                        jedi_definition = {
                            enabled = false,
                        },
                        jedi_hover = {
                            enabled = false,
                        },
                        jedi_references = {
                            enabled = false,
                        },
                        jedi_signature_help = {
                            enabled = false,
                        },
                        jedi_symbols = {
                            enabled = false,
                        },
                        mccabe = {
                            enabled = false,
                        },
                        preload = {
                            enabled = false,
                        },
                        pycodestyle = {
                            enabled = false,
                        },
                        pyflakes = {
                            enabled = false,
                        },
                        yapf = {
                            enabled = false,
                        },
                        pylsp_mypy = {
                            enabled = true,
                        },
                    },
                }
            }
        end

        -- if lsp == "vtsls" then
        --     config.root_dir = function()
        --         return not vim.fs.root(0, { 'deno.json', 'deno.jsonc' })
        --             and vim.fs.root(0, {
        --                 'tsconfig.json',
        --                 'jsconfig.json',
        --                 'package.json',
        --                 '.git',
        --             })
        --     end
        -- end

        if lsp == "pyright" then
            config.root_dir = util.root_pattern('.venv', 'venv', 'pyrightconfig.json')
            config.settings = {
                pyright = {
                    disableLanguageServices = false,
                    disableOrganizeImports = true,
                    disableTaggedHints = true,
                },
                python = {
                    analysis = {
                        autoImportCompletions = true,
                        typeCheckingMode = 'off',
                    },
                },
            }
        end

        if lsp == "glslls" then
            config.cmd = { 'glslls', '--target-env', 'opengl', '--stdin' }
        end

        if lsp == "terraformls" then
            config.filetypes = { "terraform", "tf" }
        end

        if lsp == "gopls" then
            config.settings = {
                settings = {
                    gopls = {
                        usePlaceholders = true,
                        codelenses = {
                            gc_details = false,
                            generate = true,
                            regenerate_cgo = true,
                            run_govulncheck = true,
                            test = true,
                            tidy = true,
                            upgrade_dependency = true,
                            vendor = true,
                        },
                        experimentalPostfixCompletions = true,
                        gofumpt = true,
                        completeUnimported = true,
                        staticcheck = true,
                        directoryFilters = { "-.git", "-node_modules" },
                        semanticTokens = true,
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                    },
                }
            }
        end

        if lsp == "eslint" then
            config.filetypes = {
                'javascript',
                'javascriptreact',
                'javascript.jsx',
                'typescript',
                'typescriptreact',
                'typescript.tsx',
                'vue',
                'svelte',
                'astro',
            }
        end

        if lsp == "lua_ls" then
            config.settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    completion = {
                        callSnippet = "Replace",
                    },
                },
            }
        end

        if lsp == "yamlls" then
            config.settings = {
                yaml = {
                    schemaStore = {
                        -- You must disable built-in schemaStore support if you want to use
                        -- this plugin and its advanced options like `ignore`.
                        enable = false,
                        -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                        url = "",
                    },
                    schemas = require('schemastore').yaml.schemas {
                        replace = {
                            ["openapi.json"] = {
                                description = "A Open API documentation files",
                                fileMatch = { "openapi.json", "openapi.yml", "openapi.yaml" },
                                name = "openapi.json",
                                url = "https://spec.openapis.org/oas/3.1/schema/2022-10-07",
                                versions = {
                                    ["3.0"] = "https://spec.openapis.org/oas/3.0/schema/2021-09-28",
                                    ["3.1"] = "https://spec.openapis.org/oas/3.1/schema/2022-10-07"
                                }
                            },
                            ['gitlab-ci'] = {
                                description = "configuring Gitlab CI",
                                fileMatch = { '**/.gitlab/**/*.yml', "*.gitlab-ci.yml" },
                                name = "gitlab-ci",
                                url = "https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"
                            },
                        }
                    },
                    customTags = {
                        '!Ref',
                        '!reference sequence',
                        '!reference scalar',
                    }
                },
            }
        end

        if lsp == "clangd" then
            config.cmd = {
                "clangd",
                "--background-index",
                "--suggest-missing-includes",
                "--clang-tidy",
            }
            config.filetypes = { "c", "cc", "cpp", "objc", "objcpp", "cuda" }
        end

        if lsp == "volar" then
            return
        end

        lspconfig[lsp].setup(config)
    end
})




rt.setup({
    server = {
        on_attach = function(client, bufnr)
            keyset("n", "<C-space>", rt.hover_actions.hover_actions)
            keyset("n", "<leader>a", rt.code_action_group.code_action_group)
            on_attach(client, bufnr)
        end,
    },
})

lspconfig.pkgbuild_language_server.setup({
    filetypes = { "PKGBUILD", "sh", "makepkg.conf" },
    on_attach = on_attach,
    capabilities = capabilities,
    root_dir = util.root_pattern("PKGBUILD"),
})

lspconfig.esbonio.setup({
    on_attach = on_attach,
    capabilities = capabilities,
})

lspconfig.gopls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
            gofumpt = true,
        },
    },
})

lspconfig.qmlls.setup({
    on_attach = on_attach,
    capabilities = capabilities,
})
