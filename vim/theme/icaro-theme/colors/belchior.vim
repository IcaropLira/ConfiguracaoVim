" ============================================================
" belchior.vim — colorscheme "Belchior" (Configuracao Vim Icaro Lira)
" ============================================================

set background=dark
hi clear
if exists('syntax_on')
    syntax reset
endif
let g:colors_name = 'belchior'

" ------------------------------------------------------------
" Paleta
" ------------------------------------------------------------
let s:bg0        = ['#f4f7fb', 15]
let s:bg1        = ['#e9eef5', 255]
let s:bg2        = ['#dce5ef', 254]
let s:bg3        = ['#c8d6e5', 188]
let s:border     = ['#9eb2c7', 146]
let s:fg0        = ['#14202b', 234]
let s:fg1        = ['#506477', 60]
let s:comment    = ['#71869a', 66]

let s:red        = ['#1e5fa8', 25]
let s:red_bright = ['#2f7fd0', 32]
let s:red_dim    = ['#143f70', 23]
let s:red_soft   = ['#3a8ab0', 67]

let s:green      = ['#267a4b', 29]
let s:amber      = ['#9a6500', 94]
let s:blue       = ['#245f9b', 24]
let s:cyan       = ['#167c80', 6]
let s:orange     = ['#b35c17', 130]
" Helper
" ------------------------------------------------------------
function! s:hi(group, fg, bg, style) abort
    let l:cmd = 'hi ' . a:group
    if !empty(a:fg)
        let l:cmd .= ' guifg=' . a:fg[0] . ' ctermfg=' . a:fg[1]
    else
        let l:cmd .= ' guifg=NONE ctermfg=NONE'
    endif
    if !empty(a:bg)
        let l:cmd .= ' guibg=' . a:bg[0] . ' ctermbg=' . a:bg[1]
    else
        let l:cmd .= ' guibg=NONE ctermbg=NONE'
    endif
    if !empty(a:style)
        let l:cmd .= ' gui=' . a:style . ' cterm=' . a:style
    else
        let l:cmd .= ' gui=NONE cterm=NONE'
    endif
    execute l:cmd
endfunction

" ------------------------------------------------------------
" UI base
" ------------------------------------------------------------
call s:hi('Normal',        s:fg0, s:bg0, '')
call s:hi('NormalNC',      s:fg0, s:bg0, '')
call s:hi('NonText',       s:fg1, s:bg0, '')
call s:hi('EndOfBuffer',   s:bg1, s:bg0, '')
call s:hi('Cursor',        s:bg0, s:red_bright, '')
call s:hi('CursorLine',    [], s:bg2, 'NONE')
call s:hi('CursorColumn',  [], s:bg2, 'NONE')
call s:hi('ColorColumn',   [], s:bg2, 'NONE')
call s:hi('LineNr',        s:fg1, s:bg0, '')
call s:hi('CursorLineNr',  s:red_bright, s:bg0, 'bold')
call s:hi('SignColumn',    s:fg1, s:bg0, '')
call s:hi('FoldColumn',    s:fg1, s:bg1, '')
call s:hi('Folded',        s:fg1, s:bg1, 'italic')
call s:hi('VertSplit',     s:border, s:bg0, '')
call s:hi('WinSeparator',  s:border, s:bg0, '')
call s:hi('StatusLine',    s:fg0, s:bg1, '')
call s:hi('StatusLineNC',  s:fg1, s:bg0, '')
call s:hi('TabLine',       s:fg1, s:bg1, '')
call s:hi('TabLineFill',   s:fg1, s:bg0, '')
call s:hi('TabLineSel',    s:bg0, s:red, 'bold')
call s:hi('WinBar',        s:red_soft, s:bg1, 'bold')
call s:hi('WinBarNC',      s:fg1, s:bg0, '')
call s:hi('Visual',        [], s:bg3, '')
call s:hi('VisualNOS',     [], s:bg3, '')
call s:hi('Search',        s:bg0, s:amber, 'bold')
call s:hi('IncSearch',     s:bg0, s:red_bright, 'bold')
call s:hi('CurSearch',     s:bg0, s:red_bright, 'bold')
call s:hi('MatchParen',    s:fg0, s:red_dim, 'bold')
call s:hi('Directory',     s:cyan, [], '')
call s:hi('Title',         s:red_bright, [], 'bold')
call s:hi('ModeMsg',       s:red_bright, [], 'bold')
call s:hi('MoreMsg',       s:green, [], '')
call s:hi('Question',      s:amber, [], '')
call s:hi('WarningMsg',    s:amber, [], 'bold')
call s:hi('ErrorMsg',      s:fg0, s:red_dim, 'bold')
call s:hi('WildMenu',      s:bg0, s:red, 'bold')
call s:hi('Pmenu',         s:fg0, s:bg2, '')
call s:hi('PmenuSel',      s:fg0, s:red_dim, 'bold')
call s:hi('PmenuMatch',    s:amber, s:bg2, 'bold')
call s:hi('PmenuMatchSel', s:amber, s:red_dim, 'bold')
call s:hi('PmenuSbar',     [], s:bg2, '')
call s:hi('PmenuThumb',    [], s:red_dim, '')
call s:hi('SpecialKey',    s:fg1, [], '')
call s:hi('Whitespace',    s:border, [], '')

" ------------------------------------------------------------
" Diff
" ------------------------------------------------------------
call s:hi('DiffAdd',    s:green,  s:bg1, '')
call s:hi('DiffChange', s:amber,  s:bg1, '')
call s:hi('DiffDelete', s:red_dim, s:bg1, '')
call s:hi('DiffText',   s:bg0, s:red, 'bold')

" ------------------------------------------------------------
" Sintaxe (código com cores variadas, para legibilidade)
" ------------------------------------------------------------
call s:hi('Comment',       s:comment, [], 'italic')
call s:hi('Constant',      s:amber, [], '')
call s:hi('String',        s:green, [], '')
call s:hi('Character',     s:green, [], '')
call s:hi('Number',        s:amber, [], '')
call s:hi('Boolean',       s:amber, [], 'bold')
call s:hi('Float',         s:amber, [], '')
call s:hi('Identifier',    s:fg0, [], '')
call s:hi('Function',      s:orange, [], 'bold')
call s:hi('Statement',     s:red_bright, [], 'bold')
call s:hi('Conditional',   s:red_bright, [], 'bold')
call s:hi('Repeat',        s:red_bright, [], 'bold')
call s:hi('Label',         s:red_bright, [], '')
call s:hi('Operator',      s:red, [], '')
call s:hi('Keyword',       s:red_bright, [], 'bold')
call s:hi('Exception',     s:red_bright, [], 'bold')
call s:hi('PreProc',       s:red_soft, [], '')
call s:hi('Include',       s:red_soft, [], '')
call s:hi('Define',        s:red_soft, [], '')
call s:hi('Macro',         s:red_soft, [], '')
call s:hi('PreCondit',     s:red_soft, [], '')
call s:hi('Type',          s:blue, [], 'bold')
call s:hi('StorageClass',  s:blue, [], '')
call s:hi('Structure',     s:blue, [], '')
call s:hi('Typedef',       s:blue, [], '')
call s:hi('Special',       s:red_soft, [], '')
call s:hi('SpecialChar',   s:red_soft, [], '')
call s:hi('Tag',           s:red_bright, [], '')
call s:hi('Delimiter',     s:fg1, [], '')
call s:hi('SpecialComment', s:comment, [], 'italic,bold')
call s:hi('Debug',         s:red_dim, [], '')
call s:hi('Underlined',    s:red_bright, [], 'underline')
call s:hi('Ignore',        s:fg1, [], '')
call s:hi('Error',         s:fg0, s:red_dim, 'bold')
call s:hi('Todo',          s:bg0, s:amber, 'bold')

" ------------------------------------------------------------
" coc.nvim / diagnósticos
" ------------------------------------------------------------
call s:hi('CocErrorSign',      s:red_bright, [], '')
call s:hi('CocWarningSign',    s:amber, [], '')
call s:hi('CocInfoSign',       s:cyan, [], '')
call s:hi('CocHintSign',       s:fg1, [], '')
call s:hi('CocErrorHighlight',   [], [], 'undercurl')
call s:hi('CocWarningHighlight', [], [], 'undercurl')
call s:hi('CocFloating',       s:fg0, s:bg2, '')
call s:hi('CocMenuSel',        s:fg0, s:red_dim, 'bold')
call s:hi('CocSearch',         s:amber, [], 'bold')
call s:hi('CocPumSearch',      s:amber, [], 'bold')
call s:hi('CocPumMenu',        s:fg0, s:bg2, '')
call s:hi('CocPumDetail',      s:fg1, s:bg2, '')
call s:hi('CocPumShortcut',    s:fg1, s:bg2, '')
call s:hi('CocPumDeprecated',  s:fg1, s:bg2, 'strikethrough')
call s:hi('CocCodeLens',       s:fg1, [], '')
call s:hi('CocInlayHint',      s:cyan, [], 'italic')
execute 'hi CocErrorFloat guifg=' . s:red_bright[0] . ' guibg=' . s:bg2[0]
execute 'hi CocWarningFloat guifg=' . s:amber[0] . ' guibg=' . s:bg2[0]
execute 'hi CocInfoFloat guifg=' . s:cyan[0] . ' guibg=' . s:bg2[0]

" ------------------------------------------------------------
" NERDTree
" ------------------------------------------------------------
call s:hi('NERDTreeDir',        s:cyan, [], 'bold')
call s:hi('NERDTreeDirSlash',   s:fg1, [], '')
call s:hi('NERDTreeOpenable',   s:red, [], '')
call s:hi('NERDTreeClosable',   s:red_bright, [], '')
call s:hi('NERDTreeFile',       s:fg0, [], '')
call s:hi('NERDTreeExecFile',   s:green, [], '')
call s:hi('NERDTreeCWD',        s:red_bright, [], 'bold')
call s:hi('NERDTreeUp',         s:fg1, [], '')
call s:hi('NERDTreeFlags',      s:red, [], '')

" ------------------------------------------------------------
" Status do git no NERDTree
" ------------------------------------------------------------
let g:NERDTreeGitStatusHighlightingCustom = {
            \ 'Staged'    : 'guifg=' . s:green[0]  . ' ctermfg=' . s:green[1],
            \ 'Modified'  : 'guifg=' . s:amber[0]  . ' ctermfg=' . s:amber[1],
            \ 'Untracked' : 'guifg=' . s:fg1[0]    . ' ctermfg=' . s:fg1[1],
            \ 'Renamed'   : 'guifg=' . s:blue[0]   . ' ctermfg=' . s:blue[1],
            \ 'Unmerged'  : 'guifg=' . s:red_bright[0] . ' ctermfg=' . s:red_bright[1],
            \ 'Deleted'   : 'guifg=' . s:red_dim[0]. ' ctermfg=' . s:red_dim[1],
            \ 'Dirty'     : 'guifg=' . s:red_bright[0] . ' ctermfg=' . s:red_bright[1],
            \ 'Ignored'   : 'guifg=' . s:comment[0]. ' ctermfg=' . s:comment[1],
            \ 'Clean'     : 'guifg=' . s:green[0]  . ' ctermfg=' . s:green[1],
            \ }

" ------------------------------------------------------------
" Terminal (:terminal), pra combinar com o resto
" ------------------------------------------------------------
let g:terminal_ansi_colors = [
      \ s:bg0[0], s:red[0], s:green[0], s:amber[0],
      \ s:blue[0], s:red_soft[0], s:blue[0], s:fg0[0],
      \ s:fg1[0], s:red_bright[0], s:green[0], s:amber[0],
      \ s:blue[0], s:red_soft[0], s:blue[0], s:fg0[0]
      \ ]
