-- lua/windows.lua

vim.cmd([[
let g:python3_host_prog  = 'C:\Python39\python.exe'
let g:python_host_prog  = 'C:\Python27\python.exe'

let &shell = "pwsh.exe"
set shellquote= shellpipe=\| shellxquote=
set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
set shellredir=\|\ Out-File\ -Encoding\ UTF8
]])
