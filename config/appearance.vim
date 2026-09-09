if exists('g:loaded_my_appearance')
    finish
endif
let g:loaded_my_appearance = 1

" Catppuccin / UI colors
highlight StatusLine guibg=#1e1e2e guifg=#cdd6f4
highlight StatusLineNC guibg=#181825 guifg=#6c7086
highlight LineNr guibg=#1e1e2e guifg=#585b70
highlight CursorLineNr guibg=#1e1e2e guifg=#cba6f7
highlight CursorLine guibg=#181825
highlight WinSeparator guibg=#1e1e2e guifg=#313244

" Modern Vim winbar, when supported
if exists('+winbar')
    set winbar=%#WinBar#\ %f\ %m
    highlight WinBar guibg=#1e1e2e guifg=#cba6f7
    highlight WinBarNC guibg=#181825 guifg=#6c7086
endif

" Statusline
set statusline=
set statusline+=%#StatusLine#
set statusline+=\ %{&modified?'●\ ':''}
set statusline+=%f
set statusline+=\ %=
set statusline+=%y
set statusline+=\ │\ 
set statusline+=%l:%c
set statusline+=\ │\ 
set statusline+=%p%%
set statusline+=\ 

" Airline, if installed
if exists('g:loaded_airline')
    let g:airline_powerline_fonts = 1
    let g:airline_theme = 'catppuccin'
endif
