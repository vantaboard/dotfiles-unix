require("minuet").setup({
  provider = "openai_compatible",
  provider_options = {
    openai_compatible = {
      model = "qwen2.5-coder:7b",
      end_point = "http://localhost:11434/v1/chat/completions",
      api_key = "TERM",
      name = "Ollama",
      stream = true,
      optional = {
        max_tokens = 256,
        stop = { "\n" },
      },
    },
  },
  virtualtext = {
    auto_trigger_ft = { "*" },
    auto_trigger_ignore_ft = { "help", "TelescopePrompt", "neo-tree", "lazy", "AvanteInput" },
    keymap = {
      accept = "<Tab>",
      accept_line = "<C-l>",
      next = "<C-]>",
      dismiss = "<C-e>",
    },
  },
})
