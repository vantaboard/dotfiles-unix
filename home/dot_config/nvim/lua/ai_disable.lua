--- Disable Avante and Minuet when a marker file exists in a parent directory.
--- Add an empty `.no-ai` file (or directory) at a project root to work without AI.
local M = {}

M.markers = { ".no-ai" }

---@param start string|nil Directory or file path to search upward from.
---@return string|nil Directory containing a marker, if any.
function M.root_with_marker(start)
  if not start or start == "" then
    return nil
  end

  local dir = start
  if vim.fn.isdirectory(dir) ~= 1 then
    dir = vim.fs.dirname(dir)
  end

  while dir and dir ~= "" do
    for _, marker in ipairs(M.markers) do
      local path = vim.fs.joinpath(dir, marker)
      if vim.fn.filereadable(path) == 1 or vim.fn.isdirectory(path) == 1 then
        return dir
      end
    end

    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then
      break
    end
    dir = parent
  end

  return nil
end

---@param opts? { bufnr?: number, path?: string }
function M.is_disabled(opts)
  opts = opts or {}

  local start = opts.path
  if not start then
    local bufnr = opts.bufnr or 0
    if bufnr > 0 and vim.api.nvim_buf_is_valid(bufnr) then
      local name = vim.api.nvim_buf_get_name(bufnr)
      if name ~= "" then
        start = name
      end
    end
  end

  if not start or start == "" then
    start = vim.fn.getcwd()
  end

  return M.root_with_marker(start) ~= nil
end

local function avante_keymaps()
  local Config = require("avante.config")
  local api = require("avante.api")
  local avante = require("avante")

  return {
    { { "n", "v" }, Config.mappings.ask, function() api.ask() end, "avante: ask" },
    { { "n", "v" }, Config.mappings.zen_mode, function() api.zen_mode() end, "avante: toggle Zen Mode" },
    { { "n", "v" }, Config.mappings.new_ask, function() api.ask({ new_chat = true }) end, "avante: create new ask" },
    { "v", Config.mappings.edit, function() api.edit() end, "avante: edit" },
    { "n", Config.mappings.stop, function() api.stop() end, "avante: stop" },
    { "n", Config.mappings.refresh, function() api.refresh() end, "avante: refresh" },
    { "n", Config.mappings.focus, function() api.focus() end, "avante: focus" },
    { "n", Config.mappings.toggle.default, function() avante.toggle() end, "avante: toggle" },
    { "n", Config.mappings.toggle.debug, function() avante.toggle.debug() end, "avante: toggle debug" },
    { "n", Config.mappings.toggle.selection, function() avante.toggle.hint() end, "avante: toggle selection" },
    { "n", Config.mappings.toggle.suggestion, function() avante.toggle.suggestion() end, "avante: toggle suggestion" },
    { "n", Config.mappings.toggle.repomap, function() require("avante.repo_map").show() end, "avante: display repo map" },
    { "n", Config.mappings.select_model, function() api.select_model() end, "avante: select model" },
    { "n", Config.mappings.select_history, function() api.select_history() end, "avante: select history" },
    { "n", Config.mappings.select_acp_model, function() api.select_acp_model() end, "avante: select ACP model" },
    { "n", Config.mappings.select_acp_mode, function() api.select_acp_mode() end, "avante: select ACP mode" },
    { "n", Config.mappings.files.add_all_buffers, function() api.add_buffer_files() end, "avante: add all open buffers" },
  }
end

local function del_keymap(mode, lhs)
  pcall(vim.keymap.del, mode, lhs)
end

local function del_keymaps(modes, lhs)
  if type(modes) == "table" then
    for _, mode in ipairs(modes) do
      del_keymap(mode, lhs)
    end
  else
    del_keymap(modes, lhs)
  end
end

function M.disable_avante()
  pcall(require("avante").close_sidebar)

  for _, entry in ipairs(avante_keymaps()) do
    del_keymaps(entry[1], entry[2])
  end
end

function M.enable_avante()
  local Utils = require("avante.utils")
  for _, entry in ipairs(avante_keymaps()) do
    local modes, lhs, rhs, desc = entry[1], entry[2], entry[3], entry[4]
    Utils.safe_keymap_set(modes, lhs, rhs, { desc = desc })
  end
end

function M.sync()
  local disabled = M.is_disabled()
  if disabled == M._disabled then
    return
  end
  M._disabled = disabled

  if disabled then
    M.disable_avante()
    vim.b.minuet_virtual_text_auto_trigger = false
    pcall(function()
      require("minuet.lsp").actions.completion.disable_auto_trigger()
    end)
  else
    M.enable_avante()
    vim.b.minuet_virtual_text_auto_trigger = true
    pcall(function()
      require("minuet.lsp").actions.completion.enable_auto_trigger()
    end)
  end
end

function M.setup()
  M._disabled = nil

  local group = vim.api.nvim_create_augroup("ai_disable", { clear = true })
  vim.api.nvim_create_autocmd({ "DirChanged", "VimEnter", "BufEnter" }, {
    group = group,
    callback = function()
      M.sync()
    end,
  })

  vim.api.nvim_create_user_command("NoAiSync", function()
    M._disabled = nil
    M.sync()
    local root = M.root_with_marker(vim.fn.getcwd())
    if root then
      vim.notify("AI disabled under " .. root, vim.log.levels.INFO)
    else
      vim.notify("AI enabled", vim.log.levels.INFO)
    end
  end, { desc = "Re-check .no-ai markers and sync Avante/Minuet" })
end

return M
