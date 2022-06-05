call plug#begin('~/.vim/plugged')
Plug 'wbthomason/packer.nvim'
Plug 'haya14busa/is.vim'
Plug 'mbbill/undotree'
Plug 'easymotion/vim-easymotion'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'michaeljsmith/vim-indent-object'
Plug 'justinmk/vim-sneak'
Plug 'bkad/CamelCaseMotion'
Plug 'wellle/targets.vim'
call plug#end()
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") |
  \   exe "normal! g`\"" |
  \ endif

nnoremap <silent><Space> <Nop>
let g:mapleader = ' '
let g:maplocalleader = ' '

set nohlsearch

let g:camelcasemotion_key = '<leader>'

set encoding=utf8
set fileencoding=utf8

set number
set relativenumber

set clipboard=unnamedplus

set colorcolumn = "80"

filetype plugin indent on
let tabstop = 2
let shiftwidth = 2
set expandtab

set breakindent

set autoindent
set smartindent

set ignorecase
set smartcase

set gdefault

set termguicolors
colo murphy
nmap <silent><leader>x "_d
nmap <silent><nowait><leader>xx "_dd
nmap <silent><nowait><leader>X "_d$
nnoremap <silent><leader>x "_d
nnoremap <silent><nowait><leader>xx "_dd
nnoremap <silent><nowait><leader>X "_d$

nmap <silent><nowait><leader>y v$hy
nmap <silent><nowait><leader>r v$h"_dp`[
nnoremap <silent><nowait><leader>y v$hy
nnoremap <silent><nowait><leader>r v$h"_dp`[

nmap <silent><nowait><leader>p _dp
nmap <silent><nowait><leader>P _dP
nnoremap <silent><nowait><leader>p _dp
nnoremap <silent><nowait><leader>P _dP

nmap <silent><nowait><leader>f :execute("normal vt" . nr2char(getchar()) . "\\"_dP")<cr>
nmap <silent><nowait><leader>F :execute("normal vf" . nr2char(getchar()) . "\\"_dP")<cr>
nnoremap <silent><nowait><leader>f :execute("normal vt" . nr2char(getchar()) . "\\"_dP")<cr>
nnoremap <silent><nowait><leader>F :execute("normal vf" . nr2char(getchar()) . "\\"_dP")<cr>

nnoremap <silent><nowait><leader>Q :q!<cr>
nmap <silent><nowait><leader>Q :q!<cr>
set noswapfile
set nobackup
set undofile
set undodir=~/.vim/undo

nnoremap <nowait><silent><leader>u :UndotreeToggle<cr>
autocmd BufReadPost *
  \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
  \ |   exe "normal! g`\""
  \ | endif
