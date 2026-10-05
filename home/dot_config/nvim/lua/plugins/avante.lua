-- Avante inserts into its log-level table while iterating that same table.
-- On Neovim 0.12 the loop sometimes skips WARN (level 3) and startup errors.
-- Upstream iterates the original table instead; keep installed copies aligned.
do
  local log_lua = vim.fs.joinpath(
    vim.fn.stdpath("data"),
    "site/pack/core/opt/avante.nvim/lua/avante/utils/log.lua"
  )
  if vim.fn.filereadable(log_lua) == 1 then
    local text = table.concat(vim.fn.readfile(log_lua), "\n")
    local fixed, replacements = text:gsub(
      "for levelstr, levelnr in pairs%(log_levels%) do",
      "for levelstr, levelnr in pairs(vim.log.levels) do",
      1
    )
    if replacements > 0 then
      vim.fn.writefile(vim.split(fixed, "\n", { plain = true }), log_lua)
    end
  end
end

require("avante").setup({
  provider = "openai",
  providers = {
    openai = {
      endpoint = "http://127.0.0.1:9292/v1",
      model = "chat",
      api_key_name = "TERM",
      timeout = 30000,
      extra_request_body = {
        temperature = 0,
        max_tokens = 4096,
      },
      ["local"] = true,
    },
  },
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = false,
    minimize_diff = true,
    enable_token_counting = true,
  },
})

require("render-markdown").setup({
  file_types = { "markdown", "Avante" },
  latex = { enabled = false },
})
