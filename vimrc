set nocompatible
syntax enable
set termguicolors
set background=dark

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
set signcolumn=yes
set updatetime=250
set timeoutlen=500
set history=1000
set nobackup
set noswapfile
set nowritebackup
set laststatus=2
set nolist

" Theme
colorscheme catppuccin

" Modular configuration
execute 'source ' . expand('<sfile>:p:h') . '/config/appearance.vim'
execute 'source ' . expand('<sfile>:p:h') . '/config/cpp.vim'
execute 'source ' . expand('<sfile>:p:h') . '/config/keymaps.vim'

" Clear search highlight on startup
noh
