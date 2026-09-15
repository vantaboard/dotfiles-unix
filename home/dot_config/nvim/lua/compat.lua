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
  -- Short aliases are valid only in the deprecated table form.
  -- Neovim 0.11+ positional form requires full lua-type() names.
  local type_aliases = {
    b = "boolean",
    c = "callable",
    f = "function",
    n = "number",
    s = "string",
    t = "table",
  }

  local function expand_validator(validator)
    if type(validator) == "string" then
      return type_aliases[validator] or validator
    end
    if type(validator) == "table" then
      local expanded = {}
      for i, t in ipairs(validator) do
        expanded[i] = type_aliases[t] or t
      end
      return expanded
    end
    return validator
  end

  ---@diagnostic disable-next-line: duplicate-set-field
  function vim.validate(name, value, validator, optional, message)
    -- Old form: vim.validate({ arg = { value, validator, optional_or_msg } })
    -- Rewrite to the positional form so checkhealth does not warn, expanding
    -- aliases that vscode-neovim and similar plugins still pass as "s"/"t".
    if validator == nil and type(name) == "table" then
      for param_name, spec in pairs(name) do
        orig_validate(param_name, spec[1], expand_validator(spec[2]), spec[3])
      end
      return
    end
    return orig_validate(name, value, validator, optional, message)
  end
end
