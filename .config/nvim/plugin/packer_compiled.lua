-- Automatically generated packer.nvim plugin loader code

if vim.api.nvim_call_function('has', {'nvim-0.5'}) ~= 1 then
  vim.api.nvim_command('echohl WarningMsg | echom "Invalid Neovim version for packer.nvim! | echohl None"')
  return
end

vim.api.nvim_command('packadd packer.nvim')

local no_errors, error_msg = pcall(function()

  local time
  local profile_info
  local should_profile = false
  if should_profile then
    local hrtime = vim.loop.hrtime
    profile_info = {}
    time = function(chunk, start)
      if start then
        profile_info[chunk] = hrtime()
      else
        profile_info[chunk] = (hrtime() - profile_info[chunk]) / 1e6
      end
    end
  else
    time = function(chunk, start) end
  end
  
local function save_profiles(threshold)
  local sorted_times = {}
  for chunk_name, time_taken in pairs(profile_info) do
    sorted_times[#sorted_times + 1] = {chunk_name, time_taken}
  end
  table.sort(sorted_times, function(a, b) return a[2] > b[2] end)
  local results = {}
  for i, elem in ipairs(sorted_times) do
    if not threshold or threshold and elem[2] > threshold then
      results[i] = elem[1] .. ' took ' .. elem[2] .. 'ms'
    end
  end

  _G._packer = _G._packer or {}
  _G._packer.profile_output = results
end

time([[Luarocks path setup]], true)
local package_path_str = "/home/blackboardd/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?.lua;/home/blackboardd/.cache/nvim/packer_hererocks/2.1.0-beta3/share/lua/5.1/?/init.lua;/home/blackboardd/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?.lua;/home/blackboardd/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/luarocks/rocks-5.1/?/init.lua"
local install_cpath_pattern = "/home/blackboardd/.cache/nvim/packer_hererocks/2.1.0-beta3/lib/lua/5.1/?.so"
if not string.find(package.path, package_path_str, 1, true) then
  package.path = package.path .. ';' .. package_path_str
end

if not string.find(package.cpath, install_cpath_pattern, 1, true) then
  package.cpath = package.cpath .. ';' .. install_cpath_pattern
end

time([[Luarocks path setup]], false)
time([[try_loadstring definition]], true)
local function try_loadstring(s, component, name)
  local success, result = pcall(loadstring(s), name, _G.packer_plugins[name])
  if not success then
    vim.schedule(function()
      vim.api.nvim_notify('packer.nvim: Error running ' .. component .. ' for ' .. name .. ': ' .. result, vim.log.levels.ERROR, {})
    end)
  end
  return result
end

time([[try_loadstring definition]], false)
time([[Defining packer_plugins]], true)
_G.packer_plugins = {
  ["AutoSave.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/AutoSave.nvim",
    url = "https://github.com/Pocco81/AutoSave.nvim"
  },
  CamelCaseMotion = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/CamelCaseMotion",
    url = "https://github.com/bkad/CamelCaseMotion"
  },
  LuaSnip = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/LuaSnip",
    url = "https://github.com/L3MON4D3/LuaSnip"
  },
  ["apprentice.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/apprentice.nvim",
    url = "https://github.com/adisen99/apprentice.nvim"
  },
  aurora = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/aurora",
    url = "https://github.com/ray-x/aurora"
  },
  ["blue-moon"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/blue-moon",
    url = "https://github.com/kyazdani42/blue-moon"
  },
  ["boo-colorscheme-nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/boo-colorscheme-nvim",
    url = "https://github.com/rockerBOO/boo-colorscheme-nvim"
  },
  ["borlandp.vim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/borlandp.vim",
    url = "https://github.com/caglartoklu/borlandp.vim"
  },
  ["bufdelete.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/bufdelete.nvim",
    url = "https://github.com/famiu/bufdelete.nvim"
  },
  ["bufferline.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/bufferline.nvim",
    url = "https://github.com/akinsho/bufferline.nvim"
  },
  ["calvera-dark.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/calvera-dark.nvim",
    url = "https://github.com/yashguptaz/calvera-dark.nvim"
  },
  ["cmp-buffer"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/cmp-buffer",
    url = "https://github.com/hrsh7th/cmp-buffer"
  },
  ["cmp-git"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/cmp-git",
    url = "https://github.com/petertriho/cmp-git"
  },
  ["cmp-nvim-lsp"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/cmp-nvim-lsp",
    url = "https://github.com/hrsh7th/cmp-nvim-lsp"
  },
  ["codeschool.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/codeschool.nvim",
    url = "https://github.com/adisen99/codeschool.nvim"
  },
  ["copilot.vim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/copilot.vim",
    url = "https://github.com/github/copilot.vim"
  },
  ["doom-one.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/doom-one.nvim",
    url = "https://github.com/NTBBloodbath/doom-one.nvim"
  },
  ["dracula.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/dracula.nvim",
    url = "https://github.com/Mofiqul/dracula.nvim"
  },
  edge = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/edge",
    url = "https://github.com/sainnhe/edge"
  },
  everforest = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/everforest",
    url = "https://github.com/sainnhe/everforest"
  },
  ["feline.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/feline.nvim",
    url = "https://github.com/feline-nvim/feline.nvim"
  },
  ["github-colors"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/github-colors",
    url = "https://github.com/lourenci/github-colors"
  },
  ["github-nvim-theme"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/github-nvim-theme",
    url = "https://github.com/projekt0n/github-nvim-theme"
  },
  ["gitsigns.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/gitsigns.nvim",
    url = "https://github.com/lewis6991/gitsigns.nvim"
  },
  gruvbox = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/gruvbox",
    url = "https://github.com/morhetz/gruvbox"
  },
  ["gruvbox-baby"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/gruvbox-baby",
    url = "https://github.com/luisiacc/gruvbox-baby"
  },
  ["gruvbox-material"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/gruvbox-material",
    url = "https://github.com/sainnhe/gruvbox-material"
  },
  gruvy = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/gruvy",
    url = "https://github.com/RishabhRD/gruvy"
  },
  harpoon = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/harpoon",
    url = "https://github.com/ThePrimeagen/harpoon"
  },
  ["instant.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/instant.nvim",
    url = "https://github.com/jbyuki/instant.nvim"
  },
  ["is.vim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/is.vim",
    url = "https://github.com/haya14busa/is.vim"
  },
  ["kosmikoa.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/kosmikoa.nvim",
    url = "https://github.com/novakne/kosmikoa.nvim"
  },
  ["lighthaus.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/lighthaus.nvim",
    url = "https://github.com/mrjones2014/lighthaus.nvim"
  },
  ["lightspeed.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/lightspeed.nvim",
    url = "https://github.com/ggandor/lightspeed.nvim"
  },
  ["lua-dev.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/lua-dev.nvim",
    url = "https://github.com/folke/lua-dev.nvim"
  },
  ["lush.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/lush.nvim",
    url = "https://github.com/rktjmp/lush.nvim"
  },
  ["material.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/material.nvim",
    url = "https://github.com/marko-cerovac/material.nvim"
  },
  ["modus-theme-vim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/modus-theme-vim",
    url = "https://github.com/ishan9299/modus-theme-vim"
  },
  ["monochrome.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/monochrome.nvim",
    url = "https://github.com/kdheepak/monochrome.nvim"
  },
  ["monokai.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/monokai.nvim",
    url = "https://github.com/tanvirtin/monokai.nvim"
  },
  ["moonlight.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/moonlight.nvim",
    url = "https://github.com/shaunsingh/moonlight.nvim"
  },
  neovim = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/neovim",
    url = "https://github.com/rose-pine/neovim"
  },
  ["nord.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nord.nvim",
    url = "https://github.com/shaunsingh/nord.nvim"
  },
  ["nordic.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nordic.nvim",
    url = "https://github.com/andersevenrud/nordic.nvim"
  },
  ["null-ls.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/null-ls.nvim",
    url = "https://github.com/jose-elias-alvarez/null-ls.nvim"
  },
  ["numb.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/numb.nvim",
    url = "https://github.com/nacro90/numb.nvim"
  },
  ["nvim-cmp"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-cmp",
    url = "https://github.com/hrsh7th/nvim-cmp"
  },
  ["nvim-colorizer.lua"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-colorizer.lua",
    url = "https://github.com/norcalli/nvim-colorizer.lua"
  },
  ["nvim-deus"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-deus",
    url = "https://github.com/theniceboy/nvim-deus"
  },
  ["nvim-gps"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-gps",
    url = "https://github.com/SmiteshP/nvim-gps"
  },
  ["nvim-hybrid"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-hybrid",
    url = "https://github.com/PHSix/nvim-hybrid"
  },
  ["nvim-lsp-ts-utils"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-lsp-ts-utils",
    url = "https://github.com/jose-elias-alvarez/nvim-lsp-ts-utils"
  },
  ["nvim-lspconfig"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-lspconfig",
    url = "https://github.com/neovim/nvim-lspconfig"
  },
  ["nvim-papadark"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-papadark",
    url = "https://github.com/MordechaiHadad/nvim-papadark"
  },
  ["nvim-rdark"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-rdark",
    url = "https://github.com/RishabhRD/nvim-rdark"
  },
  ["nvim-solarized-lua"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-solarized-lua",
    url = "https://github.com/ishan9299/nvim-solarized-lua"
  },
  ["nvim-spectre"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-spectre",
    url = "https://github.com/nvim-pack/nvim-spectre"
  },
  ["nvim-tree.lua"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-tree.lua",
    url = "https://github.com/kyazdani42/nvim-tree.lua"
  },
  ["nvim-treesitter"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-treesitter",
    url = "https://github.com/nvim-treesitter/nvim-treesitter"
  },
  ["nvim-treesitter-textsubjects"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-treesitter-textsubjects",
    url = "https://github.com/RRethy/nvim-treesitter-textsubjects"
  },
  ["nvim-ts-autotag"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-ts-autotag",
    url = "https://github.com/windwp/nvim-ts-autotag"
  },
  ["nvim-web-devicons"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/nvim-web-devicons",
    url = "https://github.com/kyazdani42/nvim-web-devicons"
  },
  ["omni.vim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/omni.vim",
    url = "https://github.com/yonlu/omni.vim"
  },
  ["one_monokai.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/one_monokai.nvim",
    url = "https://github.com/cpea2506/one_monokai.nvim"
  },
  ["onedark.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/onedark.nvim",
    url = "https://github.com/navarasu/onedark.nvim"
  },
  ["onedarkpro.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/onedarkpro.nvim",
    url = "https://github.com/olimorris/onedarkpro.nvim"
  },
  ["onenord.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/onenord.nvim",
    url = "https://github.com/rmehri01/onenord.nvim"
  },
  ["packer.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/packer.nvim",
    url = "https://github.com/wbthomason/packer.nvim"
  },
  ["plenary.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/plenary.nvim",
    url = "https://github.com/nvim-lua/plenary.nvim"
  },
  ["presence.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/presence.nvim",
    url = "https://github.com/andweeb/presence.nvim"
  },
  ripgrep = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/ripgrep",
    url = "https://github.com/BurntSushi/ripgrep"
  },
  ["roshnivim-cs"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/roshnivim-cs",
    url = "https://github.com/shaeinst/roshnivim-cs"
  },
  ["stabilize.nvim"] = {
    config = { "\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14stabilize\frequire\0" },
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/stabilize.nvim",
    url = "https://github.com/luukvbaal/stabilize.nvim"
  },
  ["startup.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/startup.nvim",
    url = "https://github.com/startup-nvim/startup.nvim"
  },
  ["targets.vim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/targets.vim",
    url = "https://github.com/wellle/targets.vim"
  },
  ["telescope-ag"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/telescope-ag",
    url = "https://github.com/kelly-lin/telescope-ag"
  },
  ["telescope-fzf-native.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/telescope-fzf-native.nvim",
    url = "https://github.com/nvim-telescope/telescope-fzf-native.nvim"
  },
  ["telescope-ui-select.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/telescope-ui-select.nvim",
    url = "https://github.com/nvim-telescope/telescope-ui-select.nvim"
  },
  ["telescope.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/telescope.nvim",
    url = "https://github.com/nvim-telescope/telescope.nvim"
  },
  ["texmagic.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/texmagic.nvim",
    url = "https://github.com/jakewvincent/texmagic.nvim"
  },
  ["tokyodark.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/tokyodark.nvim",
    url = "https://github.com/tiagovla/tokyodark.nvim"
  },
  ["tokyonight.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/tokyonight.nvim",
    url = "https://github.com/folke/tokyonight.nvim"
  },
  undotree = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/undotree",
    url = "https://github.com/mbbill/undotree"
  },
  vim = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim",
    url = "https://github.com/dracula/vim"
  },
  ["vim-code-dark"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-code-dark",
    url = "https://github.com/tomasiser/vim-code-dark"
  },
  ["vim-colorscheme-imas"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-colorscheme-imas",
    url = "https://github.com/machakann/vim-colorscheme-imas"
  },
  ["vim-commentary"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-commentary",
    url = "https://github.com/tpope/vim-commentary"
  },
  ["vim-fruchtig"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-fruchtig",
    url = "https://github.com/schickele/vim-fruchtig"
  },
  ["vim-fugitive"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-fugitive",
    url = "https://github.com/tpope/vim-fugitive"
  },
  ["vim-graphql"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-graphql",
    url = "https://github.com/jparise/vim-graphql"
  },
  ["vim-indent-object"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-indent-object",
    url = "https://github.com/michaeljsmith/vim-indent-object"
  },
  ["vim-repeat"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-repeat",
    url = "https://github.com/tpope/vim-repeat"
  },
  ["vim-surround"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-surround",
    url = "https://github.com/tpope/vim-surround"
  },
  ["vim-wakatime"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vim-wakatime",
    url = "https://github.com/wakatime/vim-wakatime"
  },
  ["vn-night.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/vn-night.nvim",
    url = "https://github.com/nxvu699134/vn-night.nvim"
  },
  ["zenburn.nvim"] = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/zenburn.nvim",
    url = "https://github.com/phha/zenburn.nvim"
  },
  zephyrium = {
    loaded = true,
    path = "/home/blackboardd/.local/share/nvim/site/pack/packer/start/zephyrium",
    url = "https://github.com/titanzero/zephyrium"
  }
}

time([[Defining packer_plugins]], false)
-- Config for: stabilize.nvim
time([[Config for stabilize.nvim]], true)
try_loadstring("\27LJ\2\n7\0\0\3\0\3\0\0066\0\0\0'\2\1\0B\0\2\0029\0\2\0B\0\1\1K\0\1\0\nsetup\14stabilize\frequire\0", "config", "stabilize.nvim")
time([[Config for stabilize.nvim]], false)
if should_profile then save_profiles() end

end)

if not no_errors then
  error_msg = error_msg:gsub('"', '\\"')
  vim.api.nvim_command('echohl ErrorMsg | echom "Error in packer_compiled: '..error_msg..'" | echom "Please check your config for correctness" | echohl None')
end
