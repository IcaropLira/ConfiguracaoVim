scriptencoding utf-8
if exists('g:loaded_my_explorer')
    finish
endif
let g:loaded_my_explorer = 1

" ============================================================
" Explorer de arquivos (NERDTree, com ou sem ícones de Nerd Font)
" ============================================================
"
" A decisão sobre usar ícones de Nerd Font (g:icaro_use_nerd_font) já
" foi tomada mais cedo, no ~/.vimrc — aqui só respeitamos ela, sem
" mexer em g:webdevicons_enable de novo.

let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeWinSize = 30
let g:NERDTreeIgnore = ['\.o$', '\.out$', '\.class$']

if get(g:, 'icaro_use_nerd_font', 0)
    let g:WebDevIconsUnicodeDecorateFolderNodes = 1
    let g:DevIconsEnableFoldersOpenClose = 1
else
    " Sem Nerd Font: usa setinhas simples de pasta aberta/fechada
    " (Unicode comum, funciona em qualquer fonte monoespaçada)
    let g:NERDTreeDirArrowExpandable = '▸'
    let g:NERDTreeDirArrowCollapsible = '▾'
endif

" ------------------------------------------------------------
" Status do git dentro do NERDTree (M/A/U/? coloridos do lado do
" nome do arquivo, igual mostrado na referência que você mandou)
" ------------------------------------------------------------
let g:NERDTreeGitStatusEnable = 1
let g:NERDTreeGitStatusUseNerdFonts = get(g:, 'icaro_use_nerd_font', 0)
let g:NERDTreeGitStatusIndicatorMapCustom = {
            \ 'Modified'  : 'M',
            \ 'Staged'    : '+',
            \ 'Untracked' : '?',
            \ 'Renamed'   : 'R',
            \ 'Unmerged'  : 'U',
            \ 'Deleted'   : 'D',
            \ 'Dirty'     : '*',
            \ 'Ignored'   : 'I',
            \ 'Clean'     : '',
            \ 'Unknown'   : ''
            \ }
" Cores próprias por status (em vez de herdar de grupos de sintaxe
" genéricos) — mais variação de tons dentro da mesma paleta
let g:NERDTreeGitStatusHighlightingCustom = {
            \ 'Staged'    : 'guifg=#8fbf7f ctermfg=108',
            \ 'Modified'  : 'guifg=#e0a458 ctermfg=179',
            \ 'Untracked' : 'guifg=#7a7478 ctermfg=243',
            \ 'Renamed'   : 'guifg=#7fa8d9 ctermfg=67',
            \ 'Unmerged'  : 'guifg=#ff5d5d ctermfg=203',
            \ 'Deleted'   : 'guifg=#9d0208 ctermfg=88',
            \ 'Dirty'     : 'guifg=#ff5d5d ctermfg=203',
            \ 'Ignored'   : 'guifg=#4a4448 ctermfg=238',
            \ 'Clean'     : 'guifg=#8fbf7f ctermfg=108',
            \ }
let g:NERDTreeGitStatusShowClean = 0

" Fecha o vim se o NERDTree ficar como única janela aberta
autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1
            \ && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

" Fallback: caso o NERDTree não tenha sido instalado, mantém o netrw disponível
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
