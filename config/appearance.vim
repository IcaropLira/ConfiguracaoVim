if exists('g:loaded_my_appearance')
    finish
endif
let g:loaded_my_appearance = 1

" ============================================================
" Aparência
" ============================================================

set numberwidth=4
set signcolumn=yes

highlight StatusLine guibg=#1e1e2e guifg=#cdd6f4
highlight StatusLineNC guibg=#181825 guifg=#6c7086
highlight LineNr guibg=#1e1e2e guifg=#585b70
highlight CursorLineNr guibg=#1e1e2e guifg=#cba6f7 gui=bold
highlight CursorLine guibg=#181825
highlight WinSeparator guibg=#1e1e2e guifg=#313244
highlight SignColumn guibg=#1e1e2e

" Menu de autocomplete (popup) combinando com o Catppuccin
highlight Pmenu guibg=#313244 guifg=#cdd6f4
highlight PmenuSel guibg=#45475a guifg=#cba6f7 gui=bold
highlight PmenuSbar guibg=#313244
highlight PmenuThumb guibg=#585b70

" Sinalizadores do coc.nvim (erros/avisos/infos aparecem coloridos
" na coluna de sinais e nas mensagens)
highlight CocErrorSign guifg=#f38ba8
highlight CocWarningSign guifg=#f9e2af
highlight CocInfoSign guifg=#94e2d5
highlight CocHintSign guifg=#89b4fa
highlight CocErrorHighlight gui=undercurl guisp=#f38ba8
highlight CocWarningHighlight gui=undercurl guisp=#f9e2af
highlight CocFloating guibg=#313244 guifg=#cdd6f4

if exists('+winbar')
    set winbar=%#WinBar#\ %f\ %m
    highlight WinBar guibg=#1e1e2e guifg=#cba6f7
    highlight WinBarNC guibg=#181825 guifg=#6c7086
endif

" Statusline usada caso Airline não esteja carregado
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

" ------------------------------------------------------------
" Configuração da statusline do Airline (barra inferior)
" ------------------------------------------------------------
let g:airline_powerline_fonts = 1
let g:airline_theme = 'catppuccin'
let g:airline#extensions#tabline#enabled = 1

" Créditozinho fixo no canto direito da barra
function! CreditFooter() abort
    return 'Config: Ícaro Lira'
endfunction

augroup airline_custom_sections
    autocmd!
    autocmd VimEnter,ColorScheme * call s:SetupAirlineSections()
augroup END

function! s:SetupAirlineSections() abort
    if !exists('g:loaded_airline')
        return
    endif
    call airline#parts#define_function('credit', 'CreditFooter')
    if exists('*AutocompleteStatus')
        call airline#parts#define_function('coc_ac', 'AutocompleteStatus')
        let g:airline_section_y = airline#section#create(['coc_ac'])
    endif
    let g:airline_section_z = airline#section#create(['%l:%c', '%3p%%', 'credit'])
endfunction
