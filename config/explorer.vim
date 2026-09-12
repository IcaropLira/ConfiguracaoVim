if exists('g:loaded_my_explorer')
    finish
endif
let g:loaded_my_explorer = 1

" ============================================================
" Explorer de arquivos (NERDTree + devicons)
" ============================================================
"
" REQUISITO: para os ícones aparecerem corretamente, seu terminal
" precisa estar usando uma "Nerd Font" (ex: FiraCode Nerd Font,
" JetBrainsMono Nerd Font). Sem isso, os ícones viram caixinhas/quadrados.
" Baixe em: https://www.nerdfonts.com

let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = 30
let g:NERDTreeIgnore = ['\.o$', '\.out$', '\.class$']

" Fecha o vim se o NERDTree ficar como única janela aberta
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1
            \ && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Ícones (vim-devicons)
let g:webdevicons_enable = 1
let g:WebDevIconsUnicodeDecorateFolderNodes = 1
let g:DevIconsEnableFoldersOpenClose = 1

" Fallback: caso o NERDTree não tenha sido instalado, mantém o netrw disponível
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
