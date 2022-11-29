require('packer').startup({
    function()
    use 'wbthomason/packer.nvim'
    -- completion
    use 'folke/lua-dev.nvim'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/nvim-cmp'
    use 'petertriho/cmp-git'
    use 'hrsh7th/cmp-buffer'
    use 'github/copilot.vim'
    use 'norcalli/nvim-colorizer.lua'
    use 'L3MON4D3/LuaSnip'
    -- fuzzy
    use 'nvim-telescope/telescope-fzf-native.nvim'
    use 'nvim-telescope/telescope-ui-select.nvim'
    use 'nvim-telescope/telescope.nvim'
    use({ "kelly-lin/telescope-ag", requires = { { "nvim-telescope/telescope.nvim" } } })
    use 'BurntSushi/ripgrep'
    use 'nvim-lua/plenary.nvim'
    -- lsp
    -- use 'mhartington/formatter.nvim'
    use 'neovim/nvim-lspconfig'
    use 'nvim-treesitter/nvim-treesitter'
    use 'RRethy/nvim-treesitter-textsubjects'
    use 'windwp/nvim-ts-autotag'
    use 'jose-elias-alvarez/null-ls.nvim'
    use 'jose-elias-alvarez/nvim-lsp-ts-utils'
    -- ricing
    use 'mrjones2014/lighthaus.nvim'
    use 'machakann/vim-colorscheme-imas'
    use 'schickele/vim-fruchtig'
    use 'rktjmp/lush.nvim'
    use 'shaeinst/roshnivim-cs'
    use 'tomasiser/vim-code-dark'
    use 'marko-cerovac/material.nvim'
    use 'folke/tokyonight.nvim'
    use 'kyazdani42/blue-moon'
    use 'rockerBOO/boo-colorscheme-nvim'
    use 'RishabhRD/nvim-rdark'
    use 'ishan9299/modus-theme-vim'
    use 'sainnhe/edge'
    use 'theniceboy/nvim-deus'
    use 'PHSix/nvim-hybrid'
    use 'yonlu/omni.vim'
    use 'ray-x/aurora'
    use 'novakne/kosmikoa.nvim'
    use 'tanvirtin/monokai.nvim'
    use 'andersevenrud/nordic.nvim'
    use 'shaunsingh/nord.nvim'
    use 'MordechaiHadad/nvim-papadark'
    use 'ishan9299/nvim-solarized-lua'
    use 'shaunsingh/moonlight.nvim'
    use 'navarasu/onedark.nvim'
    use 'lourenci/github-colors'
    use 'sainnhe/gruvbox-material'
    use 'sainnhe/everforest'
    use 'NTBBloodbath/doom-one.nvim'
    use 'dracula/vim'
    use 'Mofiqul/dracula.nvim'
    use 'yashguptaz/calvera-dark.nvim'
    use 'nxvu699134/vn-night.nvim'
    use 'adisen99/codeschool.nvim'
    use 'projekt0n/github-nvim-theme'
    use 'kdheepak/monochrome.nvim'
    use 'rose-pine/neovim'
    use 'adisen99/apprentice.nvim'
    use 'olimorris/onedarkpro.nvim'
    use 'rmehri01/onenord.nvim'
    use 'RishabhRD/gruvy'
    use 'luisiacc/gruvbox-baby'
    use 'titanzero/zephyrium'
    use 'tiagovla/tokyodark.nvim'
    use 'cpea2506/one_monokai.nvim'
    use 'phha/zenburn.nvim'
    -- use 'andweeb/presence.nvim'
    use 'kyazdani42/nvim-web-devicons'
    use 'startup-nvim/startup.nvim'
    use 'caglartoklu/borlandp.vim'
    -- use 'mrjones2014/lighthaus.nvim'
    use 'morhetz/gruvbox'
    use 'SmiteshP/nvim-gps'
    use 'lewis6991/gitsigns.nvim'
    -- webdev
    -- use 'styled-components/vim-styled-components'
    use 'jparise/vim-graphql'
    -- navigation
    use 'Pocco81/AutoSave.nvim'
    use 'tpope/vim-fugitive'
    use 'nacro90/numb.nvim'
    use {
        "luukvbaal/stabilize.nvim",
        config = function() require("stabilize").setup() end
    }
    use 'tpope/vim-repeat'
    use 'ThePrimeagen/harpoon'
    use 'ggandor/lightspeed.nvim'
    use 'kyazdani42/nvim-tree.lua'
    use 'feline-nvim/feline.nvim'
    use 'jbyuki/instant.nvim'
    use 'akinsho/bufferline.nvim'
    use 'haya14busa/is.vim'
    use 'mbbill/undotree'
    use 'tpope/vim-surround'
    use 'tpope/vim-commentary'
    use 'famiu/bufdelete.nvim'
    use 'michaeljsmith/vim-indent-object'
    use 'nvim-pack/nvim-spectre'
    use 'bkad/CamelCaseMotion'
    use 'wellle/targets.vim'
    -- fun
    use 'wakatime/vim-wakatime'
    use 'jakewvincent/texmagic.nvim'
  end,
  config = {
    max_jobs = 10,
  }
  })

require('formatting')
require('initialize')
-- require('windows')
-- require('plugins')
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
require('plugins.telescope')
require('plugins.treesitter')
require('plugins.spectre')
require('plugins.autosave')
require('plugins.texmagic')

vim.cmd([[
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif
]])
