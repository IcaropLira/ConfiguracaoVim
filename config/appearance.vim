scriptencoding utf-8
if exists('g:loaded_my_appearance')
    finish
endif
let g:loaded_my_appearance = 1

" ============================================================
" Aparência (cores em si ficam no colorscheme, ~/.vim/pack/plugins/
" opt/icaro-theme/colors/icaro.vim — aqui só a estrutura da UI)
" ============================================================

set numberwidth=4
set signcolumn=yes

" ------------------------------------------------------------
" Blocos coloridos do winbar (estilo "powerline" em setas, igual à
" referência) — em vez de um winbar de cor única com "›" como texto,
" monta 3 blocos (MODO / tema+arquivo / branch) com fundos diferentes,
" ligados por setas cheias.
"
" Em vez de criar cores novas (e ter que repetir isso nos 19 temas em
" theme/icaro-theme/colors/*.vim), ele reaproveita 3 highlights que já
" existem, idênticos, em TODO colorscheme do projeto: TabLineSel (cor
" de destaque forte), WinBar (o tom já usado no topo) e Pmenu (um
" terceiro tom mais sutil). Assim os blocos já nascem combinando com
" qualquer tema, inclusive os criados via :ThemeNew.
" ------------------------------------------------------------
if get(g:, 'icaro_use_nerd_font', 0)
    let s:wb_sep_r = ''
    let s:wb_sep_l = ''
else
    " Fallback sem Nerd Font: triângulos Unicode comuns. Não encaixam
    " tão perfeitamente sem "buraco" quanto os glifos powerline, mas
    " já dão o efeito de bloco/seta em qualquer fonte monoespaçada.
    let s:wb_sep_r = '▶'
    let s:wb_sep_l = '◀'
endif

function! s:HiAttr(group, what) abort
    let l:gui = synIDattr(synIDtrans(hlID(a:group)), a:what, 'gui')
    let l:cterm = synIDattr(synIDtrans(hlID(a:group)), a:what, 'cterm')
    return [empty(l:gui) ? 'NONE' : l:gui, empty(l:cterm) ? 'NONE' : l:cterm]
endfunction

function! s:HiSet(group, guifg, ctermfg, guibg, ctermbg, style) abort
    execute 'hi ' . a:group
          \ . ' guifg=' . a:guifg . ' ctermfg=' . a:ctermfg
          \ . ' guibg=' . a:guibg . ' ctermbg=' . a:ctermbg
          \ . ' gui=' . a:style . ' cterm=' . a:style
endfunction

function! IcaroDefineWinBarBlocks() abort
    let [l:s1fg, l:s1fgc] = s:HiAttr('TabLineSel', 'fg#')
    let [l:s1bg, l:s1bgc] = s:HiAttr('TabLineSel', 'bg#')
    let [l:s2fg, l:s2fgc] = s:HiAttr('WinBar', 'fg#')
    let [l:s2bg, l:s2bgc] = s:HiAttr('WinBar', 'bg#')
    let [l:s3fg, l:s3fgc] = s:HiAttr('Pmenu', 'fg#')
    let [l:s3bg, l:s3bgc] = s:HiAttr('Pmenu', 'bg#')

    call s:HiSet('WinBarSeg1', l:s1fg, l:s1fgc, l:s1bg, l:s1bgc, 'bold')
    call s:HiSet('WinBarSeg2', l:s2fg, l:s2fgc, l:s2bg, l:s2bgc, 'bold')
    call s:HiSet('WinBarSeg3', l:s3fg, l:s3fgc, l:s3bg, l:s3bgc, 'NONE')

    " A seta herda o fundo do bloco anterior como cor de "tinta" (fg) e
    " o fundo do próximo bloco como fundo — é isso que cria a ilusão de
    " uma seta sólida "empurrando" um bloco para dentro do outro.
    call s:HiSet('WinBarSep12', l:s1bg, l:s1bgc, l:s2bg, l:s2bgc, 'NONE')
    call s:HiSet('WinBarSep23', l:s2bg, l:s2bgc, l:s3bg, l:s3bgc, 'NONE')
endfunction

if exists('+winbar')
    call IcaroDefineWinBarBlocks()
    augroup icaro_winbar_blocks
        autocmd!
        " Recalcula as cores dos blocos sempre que o tema muda (F1 / Shift+F1).
        autocmd ColorScheme * call IcaroDefineWinBarBlocks()
    augroup END

    " Cabeçalho: [MODO]▶[tema › arquivo]  ...............  [branch]◀[crédito]
    let &winbar = '%#WinBarSeg1# %{IcaroModeLabel()} '
          \ . '%#WinBarSep12#' . s:wb_sep_r
          \ . '%#WinBarSeg2# %{IcaroThemeBadge()} › %f%m '
          \ . '%='
          \ . '%#WinBarSep23#' . s:wb_sep_l
          \ . '%#WinBarSeg3# %{IcaroGitBranch()} '
          \ . '%#WinBarSep12#' . s:wb_sep_l
          \ . '%#WinBarSeg2# %{CreditFooter()} '
endif

" ------------------------------------------------------------
" Tela inicial (quando o vim abre sem nenhum arquivo). De propósito
" só usa caracteres ASCII puros (sem blocos/linhas Unicode) — isso
" também depende de fonte/locale do terminal, e ASCII simples é o
" único jeito de garantir que nunca vai aparecer embaralhado.
" ------------------------------------------------------------
set shortmess+=I

function! s:ShowStartScreen() abort
    if argc() != 0 || line('$') > 1 || getline(1) !=# '' || &modified
        return
    endif
    setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
    setlocal nonumber norelativenumber signcolumn=no cursorline
    let l:banner = [
                \ '',
                \ '',
                \ '        _________  _____  ____  ____  ',
                \ '       /  _/ ___/ / _ | / __ \/ __ \ ',
                \ '      _/ // /__  / __ |/ /_/ / /_/ / ',
                \ '     /___/\___/ /_/ |_|\____/\____/  ',
                \ '',
                \ '          vim  --  c++ & java',
                \ '          config: Icaro Lira',
                \ '',
                \ '',
                \ '   F2  explorer              F5  compilar',
                \ '   F3  dicas de parametro    F6  executar',
                \ '   F4  autocomplete          F7  compilar + executar',
                \ '   F9  terminal              F8  testar com input.txt',
                \ '',
                \ '   :e nome.cpp   ou   :e nome.java   para comecar',
                \ '',
                \ ]
    call setline(1, l:banner)
    setlocal nomodifiable nomodified
    syntax match IcaroStartBanner '[_/\\|]'
    syntax match IcaroStartSubtitle '\Vvim  --  c++ & java\|\Vconfig: Icaro Lira'
    syntax match IcaroStartKey '\<F[2-9]\>'
    highlight IcaroStartBanner guifg=#e63946 gui=bold
    highlight IcaroStartSubtitle guifg=#7a7478 gui=italic
    highlight IcaroStartKey guifg=#ff5d5d gui=bold
    nnoremap <buffer><silent> q :q<CR>
    autocmd BufWipeout <buffer> setlocal modifiable
endfunction

augroup icaro_start_screen
    autocmd!
    autocmd VimEnter * call s:ShowStartScreen()
augroup END

" ------------------------------------------------------------
" Airline (barra inferior)
" ------------------------------------------------------------
" A ideia aqui é reproduzir a leitura visual da referência:
"   MODO › git:branch › [SIGLA] Tema › arquivo   ... posição / % / hora
" O nome do tema aparece no rodapé e também no winbar do topo.
if !get(g:, 'icaro_use_nerd_font', 0)
    " Sem Nerd Font: usa triângulos Unicode comuns (▶/◀) em vez das
    " setas powerline ( / ) — já dá o efeito de "bloco em seta" da
    " referência, sem precisar instalar fonte nenhuma. Com Nerd Font
    " (g:icaro_use_nerd_font = 1) essas linhas nem rodam: o Airline usa
    " os glifos powerline de verdade, que encaixam sem nenhum espaço
    " entre um bloco e o outro (g:airline_powerline_fonts, no vimrc).
    let g:airline_left_sep = '▶'
    let g:airline_right_sep = '◀'
    let g:airline_left_alt_sep = '▶'
    let g:airline_right_alt_sep = '◀'
endif
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#coc#enabled = 1
let g:airline#extensions#coc#error_symbol = 'E:'
let g:airline#extensions#coc#warning_symbol = 'W:'

" Contador de erros/avisos do coc na statusline (canto, perto do
" filetype), igual a referência que você mandou
let g:airline_section_x = airline#section#create(['coc_error_count', 'coc_warning_count', ' ', 'filetype'])

" Sem isso, seções inteiras da statusline (inclusive o indicador de
" autocomplete) somem sozinhas em janelas estreitas — exatamente o
" que acontece num split de tmux. Forçando 0, elas nunca são
" escondidas por causa da largura da janela.
let g:airline#extensions#default#section_truncate_width = {
      \ 'b': 0,
      \ 'x': 0,
      \ 'y': 0,
      \ 'z': 0,
      \ 'warning': 0,
      \ 'error': 0,
      \ 'warning2': 0,
      \ }

" ------------------------------------------------------------
" Conteúdo das seções do Airline.
" ------------------------------------------------------------
let g:airline_section_a = '%{IcaroModeLabel()}'
let g:airline_section_b = '%{IcaroGitBranch()}'
let g:airline_section_c = '%{IcaroThemeBadge()} › %f%m'
let g:airline_section_x = airline#section#create(['coc_error_count', 'coc_warning_count', ' ', 'filetype'])
let g:airline_section_y = '%{AutocompleteStatus()} %{InlayHintStatus()}'
let g:airline_section_z = '%l:%v %3p%% ‹ %{IcaroClock()} ‹ %{CreditFooter()}'

" ------------------------------------------------------------
" Statusline usada caso o Airline não esteja instalado (fallback)
" ------------------------------------------------------------
if !exists('g:loaded_airline')
    set statusline=
    set statusline+=%#StatusLine#
    set statusline+=\ %{IcaroModeLabel()}
    set statusline+=\ ›\ 
    set statusline+=%{IcaroGitBranch()}
    set statusline+=\ ›\ 
    set statusline+=%{IcaroThemeBadge()}
    set statusline+=\ ›\ %f\ %m
    set statusline+=\ %=
    set statusline+=%{exists('*AutocompleteStatus')?AutocompleteStatus():''}
    set statusline+=\ │\ 
    set statusline+=%y
    set statusline+=\ │\ 
    set statusline+=%l:%c
    set statusline+=\ │\ 
    set statusline+=%p%%
    set statusline+=\ ‹\ %{IcaroClock()}
    set statusline+=\ ‹\ %{CreditFooter()}
    set statusline+=\ 
endif
