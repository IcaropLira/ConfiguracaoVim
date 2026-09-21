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

if exists('+winbar')
    set winbar=%#WinBar#\ %f\ %m
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
" g:airline_powerline_fonts e g:webdevicons_enable já foram decididos
" no ~/.vimrc a partir de g:icaro_use_nerd_font — aqui só ajustamos os
" separadores visuais pra cada caso. g:airline_theme quem decide é o
" config/themes.vim (F1 troca).
if !get(g:, 'icaro_use_nerd_font', 0)
    " Sem Nerd Font: separadores em formato de seta fina (‹ ›) — igual
    " ao visual que você mandou de referência. São caracteres Unicode
    " bem comuns (aspas angulares), suportados por praticamente
    " qualquer fonte, sem precisar de Nerd Font. Se ainda assim
    " embaralhar no seu terminal, troque as 4 linhas abaixo por
    " '>' e '<' (ASCII puro, sempre funciona em qualquer lugar).
    let g:airline_left_sep = '›'
    let g:airline_right_sep = '‹'
    let g:airline_left_alt_sep = '›'
    let g:airline_right_alt_sep = '‹'
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

" g:airline_section_y/z (indicador de autocomplete + créditozinho)
" e as funções AutocompleteStatus()/CreditFooter() já são definidas
" no topo do ~/.vimrc — de propósito, veja o comentário lá.

" ------------------------------------------------------------
" Statusline usada caso o Airline não esteja instalado (fallback)
" ------------------------------------------------------------
if !exists('g:loaded_airline')
    set statusline=
    set statusline+=%#StatusLine#
    set statusline+=\ %{&modified?'●\ ':''}
    set statusline+=%f
    set statusline+=\ %=
    set statusline+=%{exists('*AutocompleteStatus')?AutocompleteStatus():''}
    set statusline+=\ │\ 
    set statusline+=%y
    set statusline+=\ │\ 
    set statusline+=%l:%c
    set statusline+=\ │\ 
    set statusline+=%p%%
    set statusline+=\ │\ Config:\ Ícaro\ Lira
    set statusline+=\ 
endif
