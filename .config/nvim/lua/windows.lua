-- lua/windows.lua

vim.g.python3_host_prog = 'C:\\Python39\\python.exe'
vim.g.python_host_prog = 'C:\\Python27\\python.exe'

vim.opt.shell = "pwsh.exe"
vim.opt.shellquote = ""
vim.opt.shellpipe = "|"
vim.opt.shellxquote = ""
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellredir = "| Out-File -Encoding UTF8"
