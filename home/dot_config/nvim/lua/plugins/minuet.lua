-- Minuet inline completions via llama-swap (llama-server FIM backend).
require("minuet").setup({
  enable_predicates = {
    function()
      return not require("ai_disable").is_disabled()
    end,
  },
  provider = "openai_fim_compatible",
  n_completions = 1,
  context_window = 4096,
  request_timeout = 60,
  provider_options = {
    openai_fim_compatible = {
      model = "coder",
      end_point = "http://127.0.0.1:9292/v1/completions",
      api_key = function()
        return vim.env.TERM or "local"
      end,
      name = "Llama.cpp",
      stream = true,
      optional = {
        max_tokens = 56,
        top_p = 0.9,
        stop = { "\n\n" },
      },
      template = {
        prompt = function(context_before_cursor, context_after_cursor, _)
          return "<|fim_prefix|>"
            .. context_before_cursor
            .. "<|fim_suffix|>"
            .. context_after_cursor
            .. "<|fim_middle|>"
        end,
        suffix = false,
      },
    },
  },
  notify = "warn",
  virtualtext = {
    auto_trigger_ft = { "*" },
    auto_trigger_ignore_ft = {
      "help",
      "TelescopePrompt",
      "neo-tree",
      "lazy",
      "AvanteInput",
      "gitcommit",
      "gitrebase",
      "gitconfig",
      "fugitive",
      "fugitiveblame",
      "octo",
    },
    keymap = {
      accept = "<Tab>",
      accept_line = "<C-l>",
      next = "<C-]>",
      dismiss = "<C-e>",
    },
  },
})

-- llama-swap often isn't running; connection failures shouldn't spam the UI.
do
  local utils = require("minuet.utils")
  local notify = utils.notify
  local silent_exit_codes = {
    [6] = true, -- couldn't resolve host
    [7] = true, -- couldn't connect (connection refused)
    [28] = true, -- timeout
  }

  function utils.notify(msg, minuet_level, vim_level, opts)
    if minuet_level == "error" then
      local code = msg:match("^Request failed with exit code (%d+)$")
      if code and silent_exit_codes[tonumber(code)] then
        return
      end
    end
    notify(msg, minuet_level, vim_level, opts)
  end
end
