local util = require("lspconfig/util")
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

-- Configure LSP servers using vim.lsp.config() (mason-lspconfig v2.0.0+)
-- Java Language Server
vim.lsp.config('jdtls', {
    capabilities = capabilities,
    settings = {
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
    },
})

-- Python Language Server (pylsp)
vim.lsp.config('pylsp', {
    capabilities = capabilities,
    settings = {
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
    },
})

-- Pyright Language Server
vim.lsp.config('pyright', {
    capabilities = capabilities,
    root_dir = util.root_pattern('.venv', 'venv', 'pyrightconfig.json'),
    settings = {
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
    },
})

-- GLSL Language Server
vim.lsp.config('glslls', {
    capabilities = capabilities,
    cmd = { 'glslls', '--target-env', 'opengl', '--stdin' },
})

-- Terraform Language Server
vim.lsp.config('terraformls', {
    capabilities = capabilities,
    filetypes = { "terraform", "tf" },
})

-- Go Language Server
vim.lsp.config('gopls', {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        client.server_capabilities.didChangeWatchedFiles = {
            dynamicRegistration = true
        }
    end,
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
    },
})

vim.lsp.config('golangcilsp', {
    capabilities = capabilities,
    init_options = {
        command = {
            "golangci-lint", "run",
            "--output.json.path", "stdout", -- v2 specific flag
            "--show-stats=false",
            "--issues-exit-code=1"
        },
    }
})


-- ESLint Language Server
vim.lsp.config('eslint', {
    capabilities = capabilities,
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx',
        'vue',
        'svelte',
        'astro',
    },
})

-- Lua Language Server
vim.lsp.config('lua_ls', {
    capabilities = capabilities,
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

-- YAML Language Server
vim.lsp.config('yamlls', {
    capabilities = capabilities,
    settings = {
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
                    -- Catalog name must match SchemaStore.nvim (see lua/schemastore/catalog.lua).
                    ["Golangci-lint Configuration"] = {
                        description = "golangci-lint configuration file",
                        fileMatch = {
                            ".golangci.yml",
                            ".golangci.yaml",
                            "**/.golangci.yml",
                            "**/.golangci.yaml",
                            ".golangci.toml",
                            ".golangci.json",
                            "**/.golangci.toml",
                            "**/.golangci.json",
                        },
                        name = "Golangci-lint Configuration",
                        url = "https://golangci-lint.run/jsonschema/golangci.jsonschema.json",
                        versions = {
                            ["1"] = "https://golangci-lint.run/jsonschema/golangci.v1.jsonschema.json",
                            ["2"] = "https://golangci-lint.run/jsonschema/golangci.v2.jsonschema.json",
                        },
                    },
                }
            },
            customTags = {
                '!Ref',
                '!reference sequence',
                '!reference scalar',
            }
        },
    },
})

-- Clangd Language Server
vim.lsp.config('clangd', {
    capabilities = capabilities,
    cmd = {
        "clangd",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
    },
    filetypes = { "c", "cc", "cpp", "objc", "objcpp", "cuda" },
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then return end

    keyset("v", "<leader>f", lbuf.format)

    keyset("n", "<leader>d", lbuf.definition)

    if client.name == "pylsp" then
        client.server_capabilities.documentFormattingProvider = false
    end

    if client.name == "ruff" then
        client.server_capabilities.hoverProvider = false
    end

    keyset("n", "gr", lbuf.rename)
    keyset("n", "gy", lbuf.type_definition)
    keyset("n", "K", lbuf.hover)
    keyset("n", "<leader>r", lbuf.references)
    keyset("n", "<leader>q", function()
        lbuf.format({ async = true })
    end)

    if client.name == "cssls" or client.name == "glslls" or client.name == "yamlls" or client.name == "esbonio" then
        keyset("n", "<leader>q", function()
            vim.cmd("Format")
        end)
    end

    if client.name == "gopls" then
        keyset("n", "<leader>q", function()
            local params = vim.lsp.util.make_range_params()
            params.context = { only = { "source.organizeImports" } }
            -- buf_request_sync defaults to a 1000ms timeout. Depending on your
            -- machine and codebase, you may want longer. Add an additional
            -- argument after params if you find that you have to write the file
            -- twice for changes to be saved.
            -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
            local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
            for cid, res in pairs(result or {}) do
                for _, r in pairs(res.result or {}) do
                    if r.edit then
                        local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                        vim.lsp.util.apply_workspace_edit(r.edit, enc)
                    end
                end
            end
            vim.lsp.buf.format({ async = false })
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
  end,
})

-- Additional LSP servers using vim.lsp.config
vim.lsp.config('pkgbuild_language_server', {
    filetypes = { "PKGBUILD", "sh", "makepkg.conf" },
    capabilities = capabilities,
    root_dir = util.root_pattern("PKGBUILD"),
})

vim.lsp.enable({"jdtls", "html", "eslint", "cssls", "lua_ls", "jsonls", "pylsp", "pyright", "ruff", "ts_ls"})
