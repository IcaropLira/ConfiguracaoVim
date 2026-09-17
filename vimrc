set nocompatible
filetype plugin indent on
syntax enable
set termguicolors
set background=dark

" ============================================================
" Vim Codeforces / Java IDE — Configuração Ícaro Lira
" ============================================================

" O vim-airline lê estas variáveis assim que ele mesmo inicializa
" (antes do resto da nossa config ser carregada). Se a gente só
" definir isso depois (em config/appearance.vim), o airline já vai
" ter montado a statusline com os padrões dele, e simplesmente
" sobrescrever a variável global depois não força ele a redesenhar —
" por isso essas duas funções e as seções customizadas ficam aqui,
" bem no topo, antes de qualquer 'packadd'.
let g:my_autocomplete_enabled = get(g:, 'my_autocomplete_enabled', 1)

function! AutocompleteStatus() abort
    return get(g:, 'my_autocomplete_enabled', 1) ? '● AC ON' : '○ AC OFF'
endfunction

function! CreditFooter() abort
    return 'Config: Ícaro Lira'
endfunction

let g:airline_section_y = '%{AutocompleteStatus()}'
let g:airline_section_z = '%#__accent_bold#%l%#__restore__#:%v %3p%%  %{CreditFooter()}'

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
" Cada 'packadd!' carrega o que foi clonado/copiado pelo install.sh em
" ~/.vim/pack/plugins/opt/<nome>. Se um plugin não estiver
" instalado, o packadd falha silenciosamente e o resto funciona.
" ------------------------------------------------------------
silent! packadd! icaro-theme
silent! packadd! vim-airline
silent! packadd! vim-airline-themes
silent! packadd! nerdtree
silent! packadd! vim-devicons
silent! packadd! coc.nvim

" Corrige as cores dentro do tmux/screen. Sem 'termguicolors' entrando
" em vigor DEPOIS que o Vim já sabe que está dentro do tmux, as cores
" ficam com aparência "lavada"/erradas. Isso ainda depende do seu
" tmux.conf permitir truecolor (veja o README, seção de tmux); mesmo
" sem isso, o tema tem um fallback de 256 cores que continua preto+
" vermelho, só um pouco menos preciso.
if !empty($TMUX)
    set termguicolors
endif

" Theme: preto + vermelho (Configuração Ícaro Lira)
silent! colorscheme icaro

" Configuração modular
source ~/.vim/config/appearance.vim
source ~/.vim/config/explorer.vim
source ~/.vim/config/search.vim
source ~/.vim/config/coc.vim
source ~/.vim/config/cpp.vim
source ~/.vim/config/java.vim
source ~/.vim/config/keymaps.vim
