set nocompatible
filetype plugin indent on
syntax enable
set termguicolors
set background=dark

" ============================================================
" Vim Codeforces / Java IDE — Configuração Ícaro Lira
" ============================================================

" Editor
set number
set relativenumber
set mouse=a
set clipboard=unnamedplus
set hidden
set autoindent
set smartindent
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set ignorecase
set smartcase
set incsearch
set hlsearch
set wildmenu
set wildmode=longest:full,full
set cursorline
set scrolloff=5
set sidescrolloff=5
set signcolumn=yes
set updatetime=250
set timeoutlen=500
set history=1000
set nobackup
set noswapfile
set nowritebackup
set laststatus=2
set nolist
set splitbelow
set splitright

" ------------------------------------------------------------
" Plugins (pacotes nativos do Vim, carregados em ordem controlada)
" Cada 'packadd!' carrega o que foi clonado pelo install.sh em
" ~/.vim/pack/plugins/opt/<nome>. Se um plugin não estiver
" instalado, o packadd falha silenciosamente e o resto funciona.
" ------------------------------------------------------------
silent! packadd! catppuccin
silent! packadd! vim-airline
silent! packadd! vim-airline-themes
silent! packadd! nerdtree
silent! packadd! vim-devicons
silent! packadd! coc.nvim

" Theme
silent! colorscheme catppuccin

" Configuração modular
source ~/.vim/config/appearance.vim
source ~/.vim/config/explorer.vim
source ~/.vim/config/search.vim
source ~/.vim/config/coc.vim
source ~/.vim/config/cpp.vim
source ~/.vim/config/java.vim
source ~/.vim/config/keymaps.vim
