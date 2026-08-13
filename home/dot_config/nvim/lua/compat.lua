--- Compatibility shims for Neovim 0.13+ APIs that unmaintained plugins still call.
--- Without these, :checkhealth reports vim.deprecated warnings from plenary,
--- peek.nvim, telescope-ui-select, and similar.

if vim.F then
  if vim.nonnil then
    vim.F.if_nil = vim.nonnil
  end
  if vim.npcall then
    vim.F.npcall = vim.npcall
  end
end

do
  local orig_validate = vim.validate
  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.validate(name, value, validator, optional, message)
    -- Old form: vim.validate({ arg = { value, validator, optional_or_msg } })
    if validator == nil and type(name) == "table" then
      for param_name, spec in pairs(name) do
        orig_validate(param_name, spec[1], spec[2], spec[3])
      end
      return
    end
    return orig_validate(name, value, validator, optional, message)
  end
end
