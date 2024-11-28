local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath("data")
        .. "/site/pack/packer/start/packer.nvim"
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({
            "git",
            "clone",
            "--depth",
            "1",
            "https://github.com/wbthomason/packer.nvim",
            install_path,
        })
        vim.cmd("packadd packer.nvim")
        return true
    end
    return false
end

ensure_packer()
local use = require("packer").use

require("packer").startup({
    function()
        use("wbthomason/packer.nvim")
        -- golang
        use 'ray-x/go.nvim'
        use 'ray-x/guihua.lua' -- recommended if need floating window support
        -- database
        use("tpope/vim-dadbod")
        use("kristijanhusak/vim-dadbod-ui")
        use("kristijanhusak/vim-dadbod-completion")
        -- misc
        use {
            "toppair/peek.nvim",
            build = "deno task --quiet build:fast",
        }
        -- use("filipdutescu/renamer.nvim") -- last updated in 2022
        use("saecki/live-rename.nvim")
        use("MunifTanjim/nui.nvim")
        use("nvimtools/none-ls.nvim")
        use("junegunn/fzf")
        use("mhanberg/output-panel.nvim")
        use("vitalk/vim-shebang")
        use("lambdalisue/suda.vim")
        use {
            "3rd/image.nvim",
            requires = { "vhyrro/luarocks.nvim" },
        }
        -- debugging
        use("nvim-neotest/nvim-nio")
        use {
            "nvim-neotest/neotest",
            requires = {
                "nvim-neotest/nvim-nio",
                "nvim-lua/plenary.nvim",
                "antoinemadec/FixCursorHold.nvim",
                "nvim-treesitter/nvim-treesitter"
            }
        }
        use("nvim-neotest/neotest-python")
        use("ianding1/leetcode.vim")
        use("leoluz/nvim-dap-go")
        use("mfussenegger/nvim-dap")
        use("mfussenegger/nvim-dap-python")
        use("Weissle/persistent-breakpoints.nvim")
        use {
            "aznhe21/actions-preview.nvim",
        }
        use({
            "mxsdev/nvim-dap-vscode-js",
            requires = { "mfussenegger/nvim-dap" },
        })
        use("Pocco81/dap-buddy.nvim")
        use({
            "gbprod/yanky.nvim",
            requires = { { "nvim-telescope/telescope.nvim" } },
        })
        use({
            "gbrlsnchs/telescope-lsp-handlers.nvim",
            requires = { { "nvim-telescope/telescope.nvim" } },
        })
        use({
            "nvim-telescope/telescope-dap.nvim",
            requires = { { "nvim-telescope/telescope.nvim" } },
        })
        use("theHamsta/nvim-dap-virtual-text")
        -- completion
        use("b0o/SchemaStore.nvim")
        use("wakatime/vim-wakatime")
        use("folke/neodev.nvim")
        use("folke/neoconf.nvim")
        use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
        use("hrsh7th/nvim-cmp")
        use("hrsh7th/cmp-buffer")
        use("hrsh7th/cmp-path")
        use("hrsh7th/cmp-cmdline")
        use("hrsh7th/cmp-nvim-lsp-signature-help")
        use("hrsh7th/cmp-nvim-lsp")
        use("petertriho/cmp-git")
        use("norcalli/nvim-colorizer.lua")
        use("onsails/lspkind.nvim")
        use("rafamadriz/friendly-snippets")
        use({
            "L3MON4D3/LuaSnip",
            requires = { "rafamadriz/friendly-snippets" },
            -- follow latest release.
            tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
            -- install jsregexp (optional!:).
            run = "make install_jsregexp"
        })
        use("saadparwaiz1/cmp_luasnip")
        -- fuzzy
        use("debugloop/telescope-undo.nvim")
        use("nvim-telescope/telescope-ui-select.nvim")
        use({
            "nvim-telescope/telescope.nvim",
            tag = "0.1.x",
            dependencies = {
                "debugloop/telescope-undo.nvim",
            },
        })
        use("nvim-lua/plenary.nvim")
        -- formatting
        use("mhartington/formatter.nvim")
        -- linting
        use("mfussenegger/nvim-lint")
        -- lsp
        use("simrat39/rust-tools.nvim")
        use("williamboman/mason.nvim")
        use("williamboman/mason-lspconfig.nvim")
        use("neovim/nvim-lspconfig")
        -- ricing
        use("gu-fan/InstantRst")
        use({
            "iamcco/markdown-preview.nvim",
            run = function()
                vim.fn["mkdp#util#install"]()
            end,
        })
        use("xolox/vim-misc")
        use("startup-nvim/startup.nvim")
        use("SmiteshP/nvim-gps")
        use("lewis6991/gitsigns.nvim")
        -- colos
        use("xero/miasma.nvim")
        use("eldritch-theme/eldritch.nvim")
        use("oxfist/night-owl.nvim")
        use("uloco/bluloco.nvim")
        use("scottmckendry/cyberdream.nvim")
        use("rktjmp/lush.nvim")
        use("vantaboard/vim-colorscheme-switcher")
        use("kyazdani42/nvim-web-devicons")
        use("junegunn/seoul256.vim")
        use("morhetz/gruvbox")
        use("arcticicestudio/nord-vim")
        use("tomasr/molokai")
        use("nyoom-engineering/oxocarbon.nvim")
        use("savq/melange-nvim")
        use("svrana/neosolarized.nvim")
        use("neanias/everforest-nvim")
        use("nyngwang/nvimgelion")
        use("maxmx03/FluoroMachine.nvim")
        use("dasupradyumna/midnight.nvim")
        use("sekke276/dark_flat.nvim")
        use("zootedb0t/citruszest.nvim")
        use("shaeinst/roshnivim-cs")
        use("tomasiser/vim-code-dark")
        use("Mofiqul/vscode.nvim")
        use("marko-cerovac/material.nvim")
        use("bluz71/vim-nightfly-colors")
        use("bluz71/vim-moonfly-colors")
        use("ChristianChiarulli/nvcode-color-schemes.vim")
        use("folke/tokyonight.nvim")
        use("sainnhe/sonokai")
        use("kyazdani42/blue-moon")
        use("mhartington/oceanic-next")
        use("glepnir/zephyr-nvim")
        use("rockerBOO/boo-colorscheme-nvim")
        use("jim-at-jibba/ariake-vim-colors")
        use("Scysta/pink-panic.nvim")
        use("ishan9299/modus-theme-vim")
        use("sainnhe/edge")
        use("theniceboy/nvim-deus")
        use("Th3Whit3Wolf/one-nvim")
        use("PHSix/nvim-hybrid")
        use("Th3Whit3Wolf/space-nvim")
        use("yonlu/omni.vim")
        use("ray-x/aurora")
        use("tanvirtin/monokai.nvim")
        use("savq/melange")
        use("fenetikm/falcon")
        use("andersevenrud/nordic.nvim")
        use("shaunsingh/nord.nvim")
        use("ishan9299/nvim-solarized-lua")
        use("shaunsingh/moonlight.nvim")
        use("navarasu/onedark.nvim")
        use("lourenci/github-colors")
        use("sainnhe/gruvbox-material")
        use("sainnhe/everforest")
        use("NTBBloodbath/doom-one.nvim")
        use("dracula/vim")
        use("Mofiqul/dracula.nvim")
        use("yashguptaz/calvera-dark.nvim")
        use("nxvu699134/vn-night.nvim")
        use("adisen99/codeschool.nvim")
        use("projekt0n/github-nvim-theme")
        use("kdheepak/monochrome.nvim")
        use("rose-pine/neovim")
        use("mcchrish/zenbones.nvim")
        use("catppuccin/nvim")
        use("FrenzyExists/aquarium-vim")
        use("EdenEast/nightfox.nvim")
        use("kvrohit/substrata.nvim")
        use("ldelossa/vimdark")
        use("Everblush/everblush.nvim")
        use("adisen99/apprentice.nvim")
        use("olimorris/onedarkpro.nvim")
        use("rmehri01/onenord.nvim")
        use("RishabhRD/gruvy")
        use("echasnovski/mini.nvim")
        use("luisiacc/gruvbox-baby")
        use("titanzero/zephyrium")
        use("rebelot/kanagawa.nvim")
        use("tiagovla/tokyodark.nvim")
        use("cpea2506/one_monokai.nvim")
        use("phha/zenburn.nvim")
        use("kvrohit/rasmus.nvim")
        use("chrsm/paramount-ng.nvim")
        use("kaiuri/nvim-juliana")
        use("rockyzhang24/arctic.nvim")
        use("ramojus/mellifluous.nvim")
        use("Yazeed1s/minimal.nvim")
        use("Mofiqul/adwaita.nvim")
        use("olivercederborg/poimandres.nvim")
        use("kvrohit/mellow.nvim")
        use("Yazeed1s/oh-lucy.nvim")
        -- version control
        use("tpope/vim-fugitive")
        use("pwntester/octo.nvim")
        use {
            "harrisoncramer/gitlab.nvim",
            requires = {
                "MunifTanjim/nui.nvim",
                "nvim-lua/plenary.nvim",
                "sindrets/diffview.nvim",
                "stevearc/dressing.nvim",      -- Recommended but not required. Better UI for pickers.
                "nvim-tree/nvim-web-devicons", -- Recommended but not required. Icons in discussion tree.
            },
            build = function()
                require("gitlab.server").build()
            end,
            branch = "develop",
            config = function()
                require("diffview") -- We require some global state from diffview
                local gitlab = require("gitlab")
                gitlab.setup()
            end,
        }
        -- navigation
        use({
            "nvim-telescope/telescope-fzf-native.nvim",
            run =
            "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
        })
        use("johmsalas/text-case.nvim")
        use("nvim-treesitter/nvim-treesitter")
        use("nvim-treesitter/nvim-treesitter-refactor")
        use("nvim-treesitter/nvim-treesitter-textobjects")
        use("nvim-treesitter/playground")
        use("RRethy/nvim-treesitter-textsubjects")
        use("s1n7ax/nvim-search-and-replace")
        use("Pocco81/auto-save.nvim")
        use("tpope/vim-rhubarb")
        use("nacro90/numb.nvim")
        use("tpope/vim-repeat")
        use("ThePrimeagen/harpoon")
        use("easymotion/vim-easymotion")
        use("feline-nvim/feline.nvim")
        use("kyazdani42/nvim-tree.lua")
        use("jbyuki/instant.nvim")
        use("akinsho/bufferline.nvim")
        use("haya14busa/is.vim")
        use({
            "kevinhwang91/nvim-fundo",
            requires = "kevinhwang91/promise-async",
            run = function()
                require("fundo").install()
            end,
        })
        use("mbbill/undotree")
        use("tpope/vim-surround")
        use("tpope/vim-commentary")
        use("famiu/bufdelete.nvim")
        use("michaeljsmith/vim-indent-object")
        use("nvim-pack/nvim-spectre")
        use("bkad/CamelCaseMotion")
        use("wellle/targets.vim")
        -- fun
        use("jakewvincent/texmagic.nvim")
        use("tpope/vim-sleuth")
    end,
    config = {
        max_jobs = 10,
    },
})

if vim.fn.has("win32") == 1 then
    require("windows")
end

require("output_panel").setup()

require("formatting")
require("linting")
require("autocommands")
require("mappings")
require("tsconfig")

require("plugins.colorizer")
require("plugins.dap")
require("plugins.feline")
require("plugins.fundo-plug")
require("plugins.lsp.completion")
require("plugins.lsp.servers")
require("plugins.markdown-preview")
require("plugins.numb")
require("plugins.nvim-treesitter")
require("plugins.nvimtree")
require("plugins.telescope")
require("plugins.spectre")
require("plugins.autosave")
require("plugins.texmagic")
require("plugins.go")
require("plugins.renamer")
require("plugins.dadbod")
require("plugins.gitlab")
require("plugins.image")

vim.o.exrc = true
vim.g.suda_smart_edit = 1
vim.g.python3_host_prog = "/usr/bin/python3"
vim.g.python_host_prog = "/usr/bin/python2"
