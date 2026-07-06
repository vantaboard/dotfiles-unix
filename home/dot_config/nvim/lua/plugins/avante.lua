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
