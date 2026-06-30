--- Read hardware-selected Ollama models written by chezmoi (run_after_pull-ollama-models).
local M = {}

local DEFAULT_QWEN = "qwen2.5-coder:7b"
local DEFAULT_GEMMA = "gemma3:4b"
local MODELS_FILE = vim.fn.stdpath("config") .. "/ollama/models.json"

local function load()
  if vim.fn.filereadable(MODELS_FILE) == 0 then
    return nil
  end
  local ok, data = pcall(function()
    return vim.json.decode(vim.fn.readfile(MODELS_FILE, { type = "blob" }))
  end)
  if ok and type(data) == "table" then
    return data
  end
  return nil
end

function M.get_qwen()
  local data = load()
  if data and type(data.qwen) == "string" and data.qwen ~= "" then
    return data.qwen
  end
  return DEFAULT_QWEN
end

function M.get_gemma()
  local data = load()
  if data and type(data.gemma) == "string" and data.gemma ~= "" then
    return data.gemma
  end
  return DEFAULT_GEMMA
end

--- Primary coding/chat model for IDE plugins (Qwen family).
function M.get_coder()
  return M.get_qwen()
end

return M
