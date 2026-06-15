require("avante").setup({
  provider = "ollama", -- Use the built-in ollama provider
  providers = {
    ollama = {
      endpoint = "http://localhost:11434",
      model = "qwen2.5-coder:7b",
      api_key_name = "TERM",
      timeout = 30000, -- 30 seconds
      temperature = 0,
      max_tokens = 4096,
      -- Optional: you can still inherit from openai if you need specific parsing
      -- but the new native ollama provider handles most standard setups.
      ["local"] = true,
    },
  },
  -- Ensure these match your previous intent
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

require('render-markdown').setup({
  file_types = { "markdown", "Avante" },
})
