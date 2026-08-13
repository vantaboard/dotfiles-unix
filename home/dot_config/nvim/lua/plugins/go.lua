-- gopls is configured and enabled in plugins.lsp.servers (not by go.nvim).
require("go").setup({
  lsp_cfg = false,
})

-- go.nvim health warns whenever gopls is not attached to the current buffer.
-- Treat an enabled gopls config as healthy when no Go file is open.
do
  local go_health = require("go.health")
  local go_lsp = require("go.lsp")
  local orig_check = go_health.check
  function go_health.check()
    local orig_client = go_lsp.client
    go_lsp.client = function(bufnr)
      local client = orig_client(bufnr)
      if client then
        return client
      end
      if vim.lsp.is_enabled("gopls") then
        return { name = "gopls" }
      end
    end
    orig_check()
    go_lsp.client = orig_client
  end
end

