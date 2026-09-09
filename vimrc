set nocompatible
syntax enable
set termguicolors
set background=dark

" ============================================================
" Vim Codeforces IDE
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

" Theme
colorscheme catppuccin

" Modular configuration
source ~/.vim/config/appearance.vim
source ~/.vim/config/cpp.vim
source ~/.vim/config/keymaps.vim
source ~/.vim/config/explorer.vim
source ~/.vim/config/search.vim

" Airline, when available
if exists('g:loaded_airline')
    let g:airline_powerline_fonts = 1
    let g:airline_theme = 'catppuccin'
endif
