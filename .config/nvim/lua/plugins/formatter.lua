local M = {}

local function prettier()
  return {
    exe = "prettier",
    args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
    stdin = true,
  }
end

local function black()
  return {
    exe = "black",
    args = {"-q", "-"}
  }
end

function M.setup()
  require("formatter").setup({
    logging = true,
    filetype = {
      javascript = {prettier},
      javascriptreact = {prettier},
      typescript = {prettier},
      typescriptreact = {prettier},
      python = {black},
    }
  })
end

return M

