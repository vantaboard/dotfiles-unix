-- init.lua

require('formatting')
require('initialize')
-- require('windows')
require('packer_plugs')
require('autocommands')
require('mappings')
require('tsconfig')

require('undotree_conf')
vim.cmd('source $HOME/.config/nvim/lua/restore_cursor.vim')
vim.cmd('source $HOME/.config/nvim/lua/colorschemeswitcher.vim')

-- plugin configurations
require('plugins.cmp-buffer')
require('plugins.colorizer')
require('plugins.feline')
require('plugins.goto-preview')
require('plugins.lspconfig')
require('plugins.luasnip')
require('plugins.numb')
require('plugins.nvim-treesitter-textsubjects')
require('plugins.nvimtree')
require('plugins.presence')
require('plugins.startup')
require('plugins.telescope')
require('plugins.treesitter')
require('plugins.spectre')
