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
" Glifos oficiais da família Powerline.
" Eles formam uma junção contínua entre os blocos, ao contrário de ▶/◀.
" Se a fonte não possuir esses glifos, a configuração antiga continua
" disponível com g:icaro_powerline = 0.
let g:icaro_powerline = get(g:, 'icaro_powerline', 1)

if g:icaro_powerline
    let s:wb_sep_r = ''
    let s:wb_sep_l = ''
else
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
    call s:HiSet('WinBarSep32', l:s3bg, l:s3bgc, l:s2bg, l:s2bgc, 'NONE')
endfunction

if exists('+winbar')
    call IcaroDefineWinBarBlocks()
    augroup icaro_winbar_blocks
        autocmd!
        " Recalcula as cores dos blocos sempre que o tema muda (F1 / Shift+F1).
        autocmd ColorScheme * call IcaroDefineWinBarBlocks()
    augroup END

    " Cabeçalho: blocos reais de Powerline.
    " Esquerda = modo + tema/arquivo | direita = branch + crédito.
    let &winbar = '%#WinBarSeg1# %{IcaroModeLabel()} '
          \ . '%#WinBarSep12#' . s:wb_sep_r
          \ . '%#WinBarSeg2# %{IcaroThemeBadge()}  %f%m '
          \ . '%='
          \ . '%#WinBarSep32#' . s:wb_sep_l
          \ . '%#WinBarSeg3# %{IcaroGitBranch()} '
          \ . '%#WinBarSep32#' . s:wb_sep_l
          \ . '%#WinBarSeg2# %{CreditFooter()} '
endif

" ------------------------------------------------------------
" Contraste inteligente dos popups
" ------------------------------------------------------------
" Alguns temas têm uma paleta visual clara mesmo estando marcados como
" background=dark. Em vez de depender desse flag, olhamos a cor real do
" fundo do popup. Assim:
"   fundo escuro -> texto claro
"   fundo claro  -> texto escuro
" Isso vale para o menu do COC, popup de tema e listas do Vim.
function! s:PopupLuma(hex) abort
    let l:h = substitute(a:hex, '^#', '', '')
    if strlen(l:h) != 6
        return -1
    endif
    let l:r = str2nr(strpart(l:h, 0, 2), 16)
    let l:g = str2nr(strpart(l:h, 2, 2), 16)
    let l:b = str2nr(strpart(l:h, 4, 2), 16)
    return (0.2126 * l:r) + (0.7152 * l:g) + (0.0722 * l:b)
endfunction

function! s:PopupText(bg) abort
    " Fundo escuro -> texto claro. Fundo claro -> texto escuro.
    let l:luma = s:PopupLuma(a:bg)
    if l:luma < 0 || l:luma < 128
        return ['#f2f2f2', 15]
    endif
    return ['#202020', 0]
endfunction

function! s:SetPopupText(group, bg) abort
    let l:text = s:PopupText(a:bg)
    execute 'hi ' . a:group . ' guifg=' . l:text[0] . ' ctermfg=' . l:text[1]
endfunction

function! IcaroFixPopupContrast() abort
    let l:pmenu_bg = synIDattr(synIDtrans(hlID('Pmenu')), 'bg#', 'gui')
    let l:sel_bg = synIDattr(synIDtrans(hlID('PmenuSel')), 'bg#', 'gui')
    let l:coc_bg = synIDattr(synIDtrans(hlID('CocFloating')), 'bg#', 'gui')

    if !empty(l:pmenu_bg)
        call s:SetPopupText('Pmenu', l:pmenu_bg)
        call s:SetPopupText('CocPumMenu', l:pmenu_bg)
        call s:SetPopupText('CocPumDetail', l:pmenu_bg)
        call s:SetPopupText('CocPumShortcut', l:pmenu_bg)
    endif

    if !empty(l:sel_bg)
        call s:SetPopupText('PmenuSel', l:sel_bg)
        call s:SetPopupText('PmenuMatchSel', l:sel_bg)
        call s:SetPopupText('CocMenuSel', l:sel_bg)
    endif

    if !empty(l:coc_bg)
        call s:SetPopupText('CocFloating', l:coc_bg)
        call s:SetPopupText('Float', l:coc_bg)
        call s:SetPopupText('CocErrorFloat', l:coc_bg)
        call s:SetPopupText('CocWarningFloat', l:coc_bg)
        call s:SetPopupText('CocInfoFloat', l:coc_bg)
    endif
endfunction

augroup icaro_popup_contrast
    autocmd!
    autocmd ColorScheme * call IcaroFixPopupContrast()
augroup END
call IcaroFixPopupContrast()

" ------------------------------------------------------------
" Abertura direta
" ------------------------------------------------------------
" Nao existe mais uma tela de boas-vindas intermediaria: `vim` abre
" direto no buffer, pronto para editar. Isso evita a necessidade de
" apertar ENTER/Q para comecar no terminal do laboratorio.
set shortmess+=I

" ------------------------------------------------------------
" Airline (barra inferior)
" ------------------------------------------------------------
" A ideia aqui é reproduzir a leitura visual da referência:
"   MODO › git:branch › [SIGLA] Tema › arquivo   ... posição / % / hora
" O nome do tema aparece no rodapé e também no winbar do topo.
" O install.sh instala a Nerd Font automaticamente; mantemos um fallback
" para o caso de a fonte não poder ser baixada no momento da instalação.
if get(g:, 'icaro_powerline', 1)
    let g:airline_left_sep = ''
    let g:airline_right_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_alt_sep = ''
else
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
if exists('*airline#section#create')
    let g:airline_section_x = airline#section#create(['coc_error_count', 'coc_warning_count', ' ', 'filetype'])
else
    let g:airline_section_x = '%{get(g:, "coc_error_count", "")} %y'
endif

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
if exists('*airline#section#create')
    let g:airline_section_x = airline#section#create(['coc_error_count', 'coc_warning_count', ' ', 'filetype'])
else
    let g:airline_section_x = '%{get(g:, "coc_error_count", "")} %y'
endif
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
