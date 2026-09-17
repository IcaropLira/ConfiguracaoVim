" ============================================================
" icaro.vim — colorscheme "Configuração Ícaro Lira"
" Base: preto + vermelho. Sintaxe do código com cores variadas
" pra manter legibilidade (verde/âmbar/azul), UI (statusline,
" sidebar, popups, bordas, números) predominantemente preto e
" vermelho.
" ============================================================

set background=dark
hi clear
if exists('syntax_on')
    syntax reset
endif
let g:colors_name = 'icaro'

" ------------------------------------------------------------
" Paleta
" ------------------------------------------------------------
let s:bg0      = ['#0a0a0c', 233]  " fundo principal
let s:bg1      = ['#131316', 234]  " statusline / sidebar / winbar
let s:bg2      = ['#1c1c20', 235]  " cursorline / pmenu / popups
let s:bg3      = ['#2a1216', 52]   " seleção visual (preto avermelhado)
let s:border   = ['#33262a', 237]  " separadores de janela
let s:fg0      = ['#e8e6e3', 253]  " texto principal
let s:fg1      = ['#7a7478', 243]  " números de linha / texto secundário
let s:comment  = ['#6a6467', 242]  " comentários

let s:red        = ['#e63946', 196]  " vermelho principal (statusline normal)
let s:red_bright = ['#ff5d5d', 203]  " vermelho vivo (insert / cursorline nr)
let s:red_dim    = ['#9d0208', 88]   " vermelho escuro (replace / bordas fortes)
let s:red_soft   = ['#c9184a', 161]  " magenta-vermelho (visual / preproc)

let s:green  = ['#8fbf7f', 108]  " strings
let s:amber  = ['#e0a458', 179]  " números / warnings
let s:blue   = ['#7fa8d9', 67]   " tipos / identifiers
let s:orange = ['#e08e45', 173]  " funções

" ------------------------------------------------------------
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
call s:hi('Directory',     s:blue, [], '')
call s:hi('Title',         s:red_bright, [], 'bold')
call s:hi('ModeMsg',       s:red_bright, [], 'bold')
call s:hi('MoreMsg',       s:green, [], '')
call s:hi('Question',      s:amber, [], '')
call s:hi('WarningMsg',    s:amber, [], 'bold')
call s:hi('ErrorMsg',      s:fg0, s:red_dim, 'bold')
call s:hi('WildMenu',      s:bg0, s:red, 'bold')
call s:hi('Pmenu',         s:fg0, s:bg2, '')
call s:hi('PmenuSel',      s:bg0, s:red_bright, 'bold')
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
call s:hi('CocInfoSign',       s:blue, [], '')
call s:hi('CocHintSign',       s:fg1, [], '')
call s:hi('CocErrorHighlight',   [], [], 'undercurl')
call s:hi('CocWarningHighlight', [], [], 'undercurl')
call s:hi('CocFloating',       s:fg0, s:bg2, '')
call s:hi('CocMenuSel',        s:bg0, s:red_bright, 'bold')
call s:hi('CocSearch',         s:red_bright, [], 'bold')
call s:hi('CocCodeLens',       s:fg1, [], '')
execute 'hi CocErrorFloat guifg=' . s:red_bright[0] . ' guibg=' . s:bg2[0]
execute 'hi CocWarningFloat guifg=' . s:amber[0] . ' guibg=' . s:bg2[0]
execute 'hi CocInfoFloat guifg=' . s:blue[0] . ' guibg=' . s:bg2[0]

" ------------------------------------------------------------
" NERDTree
" ------------------------------------------------------------
call s:hi('NERDTreeDir',        s:blue, [], 'bold')
call s:hi('NERDTreeDirSlash',   s:fg1, [], '')
call s:hi('NERDTreeOpenable',   s:red, [], '')
call s:hi('NERDTreeClosable',   s:red_bright, [], '')
call s:hi('NERDTreeFile',       s:fg0, [], '')
call s:hi('NERDTreeExecFile',   s:green, [], '')
call s:hi('NERDTreeCWD',        s:red_bright, [], 'bold')
call s:hi('NERDTreeUp',         s:fg1, [], '')
call s:hi('NERDTreeFlags',      s:red, [], '')

" ------------------------------------------------------------
" Terminal (:terminal), pra combinar com o resto
" ------------------------------------------------------------
let g:terminal_ansi_colors = [
      \ s:bg0[0], s:red[0], s:green[0], s:amber[0],
      \ s:blue[0], s:red_soft[0], s:blue[0], s:fg0[0],
      \ s:fg1[0], s:red_bright[0], s:green[0], s:amber[0],
      \ s:blue[0], s:red_soft[0], s:blue[0], s:fg0[0]
      \ ]
