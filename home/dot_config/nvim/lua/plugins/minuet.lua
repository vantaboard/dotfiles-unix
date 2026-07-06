local ollama_models = require("ollama_models")

local function is_termux()
  return os.getenv("TERMUX_VERSION") ~= nil
end

-- Git/VCS buffers: local cmp-git is enough; minuet would call Ollama on every keystroke.
local auto_trigger_ignore_ft = {
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
}

require("minuet").setup({
  provider = "openai_compatible",
  provider_options = {
    openai_compatible = {
      model = ollama_models.get_coder(),
      end_point = "http://localhost:11434/v1/chat/completions",
      -- Ollama ignores the Bearer token; any non-empty string works. TERM is
      -- usually set in terminals; fall back for GUI / stripped environments.
      api_key = function()
        return vim.env.TERM or "ollama"
      end,
      name = "Ollama",
      stream = true,
      optional = {
        max_tokens = 256,
        stop = { "\n" },
      },
    },
  },
  notify = "warn",
  virtualtext = {
    -- Termux has no local Ollama; skip auto-trigger to avoid pointless requests.
    auto_trigger_ft = is_termux() and {} or { "*" },
    auto_trigger_ignore_ft = auto_trigger_ignore_ft,
    keymap = {
      accept = "<Tab>",
      accept_line = "<C-l>",
      next = "<C-]>",
      dismiss = "<C-e>",
    },
  },
})

-- Ollama often isn't running; connection failures shouldn't spam the UI.
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
