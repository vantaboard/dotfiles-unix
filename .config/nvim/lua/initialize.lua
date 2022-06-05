-- lua/initialize.lua
-- source: https://bit.ly/3yzjjEu

-- Auto install packer
-- local install_path = "C:\\Users\\brigh\\AppData\\Local\\nvim-data\\site\\pack\\packer\\start\\packer.nvim"
-- if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
--   execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
-- end
-- vim.cmd [[packadd packer.nvim]]
-- vim.cmd 'autocmd BufWritePost lua/plugins.lua PackerCompile'

-- use this one if on Linux
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
--execute('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]
vim.cmd 'autocmd BufWritePost plugins.lua PackerCompile' -- Auto compile when there are changes in plugins.lua
