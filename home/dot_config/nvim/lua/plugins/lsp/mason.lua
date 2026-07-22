-- Mason installs language servers; we still enable them explicitly via vim.lsp.enable.
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "lua_ls",
    "jsonls",
    "html",
    "cssls",
    "eslint",
    "ts_ls",
    "clangd",
    "jdtls",
    "pylsp",
    "pyright",
    "ruff",
    "gopls",
    "golangci_lint_ls",
  },
  -- Keep enable list in servers.lua; do not auto-enable every Mason package.
  automatic_enable = false,
})
