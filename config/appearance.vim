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
" Airline (barra inferior)
" ------------------------------------------------------------
let g:airline_powerline_fonts = 1
let g:airline_theme = 'icaro'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#coc#enabled = 1

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
