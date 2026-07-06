local hooks = function(ev)
  local name, kind = ev.data.spec.name, ev.data.kind
  local path = ev.data.path

  -- Only run on install or update
  if not (kind == 'install' or kind == 'update') then return end

  local function run_cmd(cmd_table)
    -- Wrap in pcall to catch errors without crashing Neovim
    local ok, obj = pcall(vim.system, cmd_table, { cwd = path })
    if not ok then
      vim.notify("Build failed for " .. name .. ": " .. tostring(obj), vim.log.levels.ERROR)
    end
  end

  if name == 'LuaSnip' and vim.fn.executable('make') == 1 then
    run_cmd({ 'make', 'install_jsregexp' })

  elseif name == 'markdown-preview' then
    vim.fn["mkdp#util#install"]()

  elseif name == 'peek' and vim.fn.executable('deno') == 1 then
    run_cmd({ 'deno', 'task', '--quiet', 'build:fast' })

  elseif name == 'telescope-fzf-native' and vim.fn.executable('make') == 1 then
    -- make is more reliable than cmake on Termux and with newer cmake versions
    run_cmd({ 'make' })

  elseif name == 'avante.nvim' and vim.fn.executable('make') == 1 then
    run_cmd({ 'make' })
  end
end

vim.api.nvim_create_autocmd('PackChanged', { callback = hooks })

local pack_plugins = {
  'https://github.com/Mathijs-Bakker/godotdev.nvim',
  'https://github.com/ray-x/go.nvim',
  -- recommended if need floating window support
  'https://github.com/ray-x/guihua.lua',
  'https://github.com/tpope/vim-dadbod',
'https://github.com/kristijanhusak/vim-dadbod-ui',
'https://github.com/kristijanhusak/vim-dadbod-completion',
        -- misc
'https://github.com/m-demare/attempt.nvim',
  {
    src = 'https://github.com/toppair/peek.nvim',
    name = 'peek',
  },
'https://github.com/saecki/live-rename.nvim',
'https://github.com/MunifTanjim/nui.nvim',
'https://github.com/rcarriga/nvim-notify',
'https://github.com/folke/noice.nvim',
'https://github.com/junegunn/fzf',
'https://github.com/mhanberg/output-panel.nvim',
'https://github.com/vitalk/vim-shebang',
'https://github.com/lambdalisue/suda.vim',
        -- debugging
'https://github.com/nvim-neotest/nvim-nio',
'https://github.com/antoinemadec/FixCursorHold.nvim',
'https://github.com/nvim-neotest/neotest',
'https://github.com/nvim-neotest/neotest-python',
'https://github.com/ianding1/leetcode.vim',
'https://github.com/leoluz/nvim-dap-go',
'https://github.com/mfussenegger/nvim-dap',
'https://github.com/mfussenegger/nvim-dap-python',
'https://github.com/Weissle/persistent-breakpoints.nvim',
'https://github.com/aznhe21/actions-preview.nvim',
        'https://github.com/mxsdev/nvim-dap-vscode-js',
'https://github.com/Pocco81/dap-buddy.nvim',
        'https://github.com/gbprod/yanky.nvim',
        'https://github.com/gbrlsnchs/telescope-lsp-handlers.nvim',
        'https://github.com/nvim-telescope/telescope-dap.nvim',
'https://github.com/theHamsta/nvim-dap-virtual-text',
        -- completion
'https://github.com/b0o/SchemaStore.nvim',
'https://github.com/folke/neodev.nvim',
'https://github.com/folke/neoconf.nvim',
        'https://github.com/rcarriga/nvim-dap-ui',
'https://github.com/hrsh7th/nvim-cmp',
'https://github.com/hrsh7th/cmp-buffer',
'https://github.com/hrsh7th/cmp-path',
'https://github.com/hrsh7th/cmp-cmdline',
'https://github.com/hrsh7th/cmp-nvim-lsp-signature-help',
'https://github.com/hrsh7th/cmp-nvim-lsp',
'https://github.com/petertriho/cmp-git',
'https://github.com/norcalli/nvim-colorizer.lua',
'https://github.com/onsails/lspkind.nvim',
'https://github.com/rafamadriz/friendly-snippets',
  {
    src = 'https://github.com/L3MON4D3/LuaSnip',
    name = 'LuaSnip',
    version = 'v2.5.0',
  },
'https://github.com/saadparwaiz1/cmp_luasnip',
-- dependencies
'https://github.com/stevearc/dressing.nvim',
'https://github.com/MeanderingProgrammer/render-markdown.nvim',

-- AI
{
    src = 'https://github.com/yetone/avante.nvim',
    name = 'avante.nvim',
},
'https://github.com/milanglacier/minuet-ai.nvim',
        -- fuzzy
'https://github.com/debugloop/telescope-undo.nvim',
'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  {
    src = 'https://github.com/nvim-telescope/telescope.nvim',
    version = 'v0.2.2',
  },
'https://github.com/nvim-lua/plenary.nvim',
        -- formatting
'https://github.com/mhartington/formatter.nvim',
        -- linting
'https://github.com/mfussenegger/nvim-lint',
        -- lsp
'https://github.com/simrat39/rust-tools.nvim',
'https://github.com/williamboman/mason.nvim',
'https://github.com/williamboman/mason-lspconfig.nvim',
'https://github.com/neovim/nvim-lspconfig',
        -- ricing
        { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
'https://github.com/xiyaowong/transparent.nvim',
'https://github.com/gu-fan/InstantRst',
  {
    src = 'https://github.com/iamcco/markdown-preview.nvim',
    name = 'markdown-preview',
  },
'https://github.com/xolox/vim-misc',
'https://github.com/startup-nvim/startup.nvim',
'https://github.com/lewis6991/gitsigns.nvim',
        -- colos
'https://github.com/xero/miasma.nvim',
'https://github.com/eldritch-theme/eldritch.nvim',
'https://github.com/oxfist/night-owl.nvim',
'https://github.com/uloco/bluloco.nvim',
'https://github.com/rktjmp/lush.nvim',
'https://github.com/kyazdani42/nvim-web-devicons',
'https://github.com/junegunn/seoul256.vim',
'https://github.com/morhetz/gruvbox',
'https://github.com/arcticicestudio/nord-vim',
'https://github.com/tomasr/molokai',
'https://github.com/nyoom-engineering/oxocarbon.nvim',
'https://github.com/savq/melange-nvim',
'https://github.com/svrana/neosolarized.nvim',
'https://github.com/neanias/everforest-nvim',
'https://github.com/nyngwang/nvimgelion',
'https://github.com/maxmx03/FluoroMachine.nvim',
'https://github.com/dasupradyumna/midnight.nvim',
'https://github.com/sekke276/dark_flat.nvim',
'https://github.com/zootedb0t/citruszest.nvim',
'https://github.com/shaeinst/roshnivim-cs',
'https://github.com/tomasiser/vim-code-dark',
'https://github.com/Mofiqul/vscode.nvim',
'https://github.com/marko-cerovac/material.nvim',
'https://github.com/bluz71/vim-nightfly-colors',
'https://github.com/bluz71/vim-moonfly-colors',
'https://github.com/ChristianChiarulli/nvcode-color-schemes.vim',
'https://github.com/folke/tokyonight.nvim',
'https://github.com/sainnhe/sonokai',
'https://github.com/kyazdani42/blue-moon',
'https://github.com/mhartington/oceanic-next',
'https://github.com/glepnir/zephyr-nvim',
'https://github.com/rockerBOO/boo-colorscheme-nvim',
'https://github.com/jim-at-jibba/ariake-vim-colors',
'https://github.com/Scysta/pink-panic.nvim',
'https://github.com/ishan9299/modus-theme-vim',
'https://github.com/sainnhe/edge',
'https://github.com/theniceboy/nvim-deus',
'https://github.com/Th3Whit3Wolf/one-nvim',
'https://github.com/PHSix/nvim-hybrid',
'https://github.com/Th3Whit3Wolf/space-nvim',
'https://github.com/yonlu/omni.vim',
'https://github.com/ray-x/aurora',
'https://github.com/tanvirtin/monokai.nvim',
'https://github.com/savq/melange',
'https://github.com/fenetikm/falcon',
'https://github.com/andersevenrud/nordic.nvim',
'https://github.com/shaunsingh/nord.nvim',
'https://github.com/ishan9299/nvim-solarized-lua',
'https://github.com/shaunsingh/moonlight.nvim',
'https://github.com/navarasu/onedark.nvim',
'https://github.com/lourenci/github-colors',
'https://github.com/sainnhe/gruvbox-material',
'https://github.com/sainnhe/everforest',
'https://github.com/NTBBloodbath/doom-one.nvim',
'https://github.com/dracula/vim',
'https://github.com/Mofiqul/dracula.nvim',
'https://github.com/yashguptaz/calvera-dark.nvim',
'https://github.com/nxvu699134/vn-night.nvim',
'https://github.com/adisen99/codeschool.nvim',
'https://github.com/projekt0n/github-nvim-theme',
'https://github.com/kdheepak/monochrome.nvim',
'https://github.com/mcchrish/zenbones.nvim',
'https://github.com/catppuccin/nvim',
'https://github.com/FrenzyExists/aquarium-vim',
'https://github.com/EdenEast/nightfox.nvim',
'https://github.com/kvrohit/substrata.nvim',
'https://github.com/ldelossa/vimdark',
'https://github.com/Everblush/everblush.nvim',
'https://github.com/adisen99/apprentice.nvim',
'https://github.com/olimorris/onedarkpro.nvim',
'https://github.com/rmehri01/onenord.nvim',
'https://github.com/RishabhRD/gruvy',
'https://github.com/echasnovski/mini.nvim',
'https://github.com/luisiacc/gruvbox-baby',
'https://github.com/titanzero/zephyrium',
'https://github.com/rebelot/kanagawa.nvim',
'https://github.com/tiagovla/tokyodark.nvim',
'https://github.com/cpea2506/one_monokai.nvim',
'https://github.com/phha/zenburn.nvim',
'https://github.com/kvrohit/rasmus.nvim',
'https://github.com/chrsm/paramount-ng.nvim',
'https://github.com/kaiuri/nvim-juliana',
'https://github.com/rockyzhang24/arctic.nvim',
'https://github.com/ramojus/mellifluous.nvim',
'https://github.com/Yazeed1s/minimal.nvim',
'https://github.com/Mofiqul/adwaita.nvim',
'https://github.com/olivercederborg/poimandres.nvim',
'https://github.com/kvrohit/mellow.nvim',
'https://github.com/Yazeed1s/oh-lucy.nvim',
        -- version control
'https://github.com/tpope/vim-fugitive',
'https://github.com/pwntester/octo.nvim',
  {
    src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
    name = 'telescope-fzf-native',
  },
        -- navigation
'https://github.com/johmsalas/text-case.nvim',
'https://github.com/s1n7ax/nvim-search-and-replace',
'https://github.com/Pocco81/auto-save.nvim',
'https://github.com/tpope/vim-rhubarb',
'https://github.com/nacro90/numb.nvim',
'https://github.com/tpope/vim-repeat',
'https://github.com/ThePrimeagen/harpoon',
'https://github.com/easymotion/vim-easymotion',
        'https://github.com/nvim-lualine/lualine.nvim',
'https://github.com/kyazdani42/nvim-tree.lua',
'https://github.com/jbyuki/instant.nvim',
'https://github.com/akinsho/bufferline.nvim',
'https://github.com/haya14busa/is.vim',
'https://github.com/kevinhwang91/promise-async',
'https://github.com/mbbill/undotree',
'https://github.com/tpope/vim-surround',
'https://github.com/tpope/vim-commentary',
'https://github.com/famiu/bufdelete.nvim',
'https://github.com/michaeljsmith/vim-indent-object',
'https://github.com/nvim-pack/nvim-spectre',
'https://github.com/bkad/CamelCaseMotion',
'https://github.com/wellle/targets.vim',
        -- fun
'https://github.com/jakewvincent/texmagic.nvim',
'https://github.com/tpope/vim-sleuth',
}

vim.pack.add(pack_plugins)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- List of filetypes to ignore
    local ignore_ft = { "cmp_menu", "cmp_docs", "noice", "prompt", "TelescopePrompt" }
    if vim.tbl_contains(ignore_ft, vim.bo.filetype) then
      return
    end

    -- Use pcall (protected call) to catch errors silently if a parser is missing
    pcall(vim.treesitter.start)
  end,
})

require("transparent").setup({
    enable = true,
    extra_groups = {
        "NormalFloat",
        "NormalNC",
        "MsgArea",
        "NvimTreeNormal",
        "NvimTreeNormalNC",
        "TelescopeNormal",
        "TelescopeBorder",
        "StatusLine",
        "StatusLineNC",
        "WinBar",
        "WinBarNC",
        "TabLine",
        "TabLineFill",
        "TabLineSel",
        "BufferLineTabClose",
        "BufferlineBufferSelected",
        "BufferLineFill",
        "BufferLineBackground",
        "BufferLineSeparator",
        "BufferLineIndicatorSelected",
    },
    exclude = {},
})

require('transparent').clear_prefix('BufferLine')

require("output_panel").setup({})

require("formatting")
require("autocommands")
require("mappings")
require("tsconfig")

require("plugins.dap")
require("plugins.lualine")
require("plugins.lsp.completion")
require("plugins.lsp.servers")
require("plugins.markdown-preview")
require("plugins.numb")
require("plugins.nvimtree")
require("plugins.godot")
-- require("plugins.nvim-treesitter")
require("plugins.telescope")
require("plugins.noice")
require("plugins.spectre")
require("plugins.autosave")
require("plugins.texmagic")
require("plugins.go")
require("plugins.renamer")
require("plugins.dadbod")
require("plugins.attempt")
require("plugins.avante")
require("plugins.minuet")

vim.o.exrc = true
vim.g.python3_host_prog = "/usr/bin/python"
vim.g.python_host_prog = "/usr/bin/python2"

-- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
