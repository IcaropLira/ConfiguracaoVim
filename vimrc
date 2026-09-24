set encoding=utf-8
scriptencoding utf-8
set fileencodings=utf-8
set nocompatible
filetype plugin indent on
syntax enable
set termguicolors
set background=dark

" ============================================================
" Vim Codeforces / Java IDE — Configuração Ícaro Lira
" ============================================================

" ------------------------------------------------------------
" Preferências locais (nerd font sim/não, etc). Esse arquivo NÃO faz
" parte do pacote em si — o install.sh cria/pergunta uma vez só, e
" nunca sobrescreve depois, pra guardar sua escolha.
" ------------------------------------------------------------
if filereadable(expand('~/.vim/config/local.vim'))
    source ~/.vim/config/local.vim
endif
let g:icaro_use_nerd_font = get(g:, 'icaro_use_nerd_font', 0)
" Powerline pode ser usado independentemente dos ícones da Nerd Font.
" O padrão é 1 para manter winbar/statusline com os separadores reais.
let g:icaro_powerline = get(g:, 'icaro_powerline', 1)

" ------------------------------------------------------------
" Persistência dos toggles (autocomplete / dicas de parâmetro).
" Cada F4/F3 (veja config/coc.vim) grava um arquivinho de 1 caractere
" em ~/.vim/; aqui a gente lê ele de volta ANTES de qualquer plugin
" carregar — é o que garante que "desligado" continua desligado depois
" de fechar e abrir o vim de novo.
" ------------------------------------------------------------
let g:icaro_ac_state_file    = expand('~/.vim/.icaro_autocomplete_state')
let g:icaro_inlay_state_file = expand('~/.vim/.icaro_inlayhints_state')

function! s:ReadState(file, default) abort
    if filereadable(a:file)
        let l:lines = readfile(a:file)
        if !empty(l:lines) && l:lines[0] ==# '0'
            return 0
        endif
    endif
    return a:default
endfunction

let g:my_autocomplete_enabled = s:ReadState(g:icaro_ac_state_file, 1)
let g:my_inlay_hints_enabled  = s:ReadState(g:icaro_inlay_state_file, 1)

" Impede o coc.nvim de sequer iniciar o serviço se a última escolha
" salva foi "desligado" — assim ele nasce desligado de verdade, em vez
" de ligar e a gente desligar na marra logo em seguida.
let g:coc_start_at_startup = g:my_autocomplete_enabled

" O vim-airline lê estas variáveis assim que ele mesmo inicializa
" (antes do resto da nossa config ser carregada). Se a gente só
" definir isso depois (em config/appearance.vim), o airline já vai
" ter montado a statusline com os padrões dele, e simplesmente
" sobrescrever a variável global depois não força ele a redesenhar —
" por isso essas funções e as seções customizadas ficam aqui, bem no
" topo, antes de qualquer 'packadd'.
function! AutocompleteStatus() abort
    return get(g:, 'my_autocomplete_enabled', 1) ? '[AC:ON]' : '[AC:OFF]'
endfunction

function! InlayHintStatus() abort
    return get(g:, 'my_inlay_hints_enabled', 1) ? '[IH:ON]' : '[IH:OFF]'
endfunction

" O créditozinho é escrito por extenso a partir de códigos de
" caractere de propósito (em vez de string literal), e reaplicado
" sozinho se alguém apagar a linha da statusline/winbar — veja
" config/credit.vim. Isso é só um capricho pessoal, não uma trava de
" verdade; qualquer um com paciência consegue tirar editando os dois
" arquivos certos, mas não é algo que sai só apertando um "delete".
if filereadable(expand('~/.vim/config/credit.vim'))
    source ~/.vim/config/credit.vim
endif
if !exists('*CreditFooter')
    function! CreditFooter() abort
        return 'Config: Ícaro Lira'
    endfunction
endif

let g:airline_section_a = '%{IcaroModeLabel()}'
let g:airline_section_b = '%{IcaroGitBranch()}'
let g:airline_section_c = '%{IcaroThemeBadge()} › %f%m'
let g:airline_section_y = '%{AutocompleteStatus()} %{InlayHintStatus()}'
let g:airline_section_z = '%l:%v %3p%% ‹ %{IcaroClock()} ‹ %{CreditFooter()}'

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
silent! packadd! vim-fugitive
silent! packadd! nerdtree
silent! packadd! nerdtree-git-plugin

" vim-devicons (ícones por tipo de arquivo) só é carregado se você
" confirmou ter uma Nerd Font instalada (pergunta feita pelo
" install.sh, guardada em config/local.vim). Sem isso, os ícones
" aparecem como caixinhas/losangos — pior do que não ter ícone
" nenhum. Sem uma Nerd Font, a interface usa símbolos Unicode comuns,
" que praticamente qualquer fonte monoespaçada já sabe desenhar.
if g:icaro_use_nerd_font
    silent! packadd! vim-devicons
    let g:webdevicons_enable = 1
    let g:airline_powerline_fonts = 1
else
    let g:webdevicons_enable = 0
    let g:airline_powerline_fonts = 0
endif

" Powerline da barra inferior é independente dos ícones da Nerd Font.
if get(g:, 'icaro_powerline', 1)
    let g:airline_powerline_fonts = 1
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_alt_sep = ''
endif

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

" Tema: quem decide qual está ativo (e aplica o salvo da última vez)
" é o config/themes.vim, carregado logo abaixo — o tema "Malvadão" é
" só o primeiro da lista/padrão de fábrica.
source ~/.vim/config/themes.vim

" Configuração modular
source ~/.vim/config/appearance.vim
source ~/.vim/config/explorer.vim
source ~/.vim/config/search.vim
source ~/.vim/config/coc.vim
source ~/.vim/config/runner.vim
source ~/.vim/config/cpp.vim
source ~/.vim/config/java.vim
source ~/.vim/config/cheatsheet.vim
source ~/.vim/config/keymaps.vim
