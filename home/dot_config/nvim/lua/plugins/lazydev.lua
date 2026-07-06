require("lazydev").setup({
  library = {
    { path = vim.fn.stdpath("config") .. "/lua", words = { "vim%.api" } },
  },
  integrations = {
    lspconfig = true,
  },
})
