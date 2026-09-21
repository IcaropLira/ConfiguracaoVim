" ============================================================
" Tema do vim-airline "alan_turing" — arco-íris
" ============================================================

let s:black = '#0b0b10'
let s:panel = '#131318'
let s:panel2 = '#1c1c24'
let s:fg = '#f5f5fa'
let s:fg_dim = '#9a9ab0'

let s:mode_normal  = '#ff3b3b'
let s:mode_insert  = '#3bff6e'
let s:mode_visual  = '#3b9dff'
let s:mode_replace = '#fff23b'
let s:amber = '#fff23b'
let s:purple = '#8b3bff'
let s:pink = '#ff3bcb'
let s:orange = '#ff9d3b'
let s:cyan = '#3bfff2'

let s:t_black = 233
let s:t_panel = 234
let s:t_fg = 255
let s:t_fgdim = 249
let s:t_normal = 203
let s:t_insert = 83
let s:t_visual = 75
let s:t_replace = 227
let s:t_amber = 227

let g:airline#themes#alan_turing#palette = {}

let s:N1 = [ s:black, s:mode_normal, s:t_black, s:t_normal ]
let s:N2 = [ s:fg, s:panel, s:t_fg, s:t_panel ]
let s:N3 = [ s:purple, s:black, 135, s:t_black ]
let g:airline#themes#alan_turing#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let s:I1 = [ s:black, s:mode_insert, s:t_black, s:t_insert ]
let s:I3 = [ s:cyan, s:black, 87, s:t_black ]
let g:airline#themes#alan_turing#palette.insert = airline#themes#generate_color_map(s:I1, s:N2, s:I3)

let s:V1 = [ s:black, s:mode_visual, s:t_black, s:t_visual ]
let s:V3 = [ s:pink, s:black, 205, s:t_black ]
let g:airline#themes#alan_turing#palette.visual = airline#themes#generate_color_map(s:V1, s:N2, s:V3)

let s:R1 = [ s:black, s:mode_replace, s:t_black, s:t_replace ]
let s:R3 = [ s:orange, s:black, 215, s:t_black ]
let g:airline#themes#alan_turing#palette.replace = airline#themes#generate_color_map(s:R1, s:N2, s:R3)

let s:IA1 = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let s:IA2 = [ s:fg_dim, s:panel, s:t_fgdim, s:t_panel ]
let g:airline#themes#alan_turing#palette.inactive = airline#themes#generate_color_map(s:IA1, s:IA2, s:IA2)

let s:MOD = [ s:amber, '', s:t_amber, '', '' ]
let g:airline#themes#alan_turing#palette.normal_modified   = { 'airline_c': s:MOD }
let g:airline#themes#alan_turing#palette.insert_modified   = { 'airline_c': s:MOD }
let g:airline#themes#alan_turing#palette.visual_modified   = { 'airline_c': s:MOD }
let g:airline#themes#alan_turing#palette.replace_modified  = { 'airline_c': s:MOD }
let g:airline#themes#alan_turing#palette.inactive_modified = { 'airline_c': s:MOD }

let s:WARN = [ s:black, s:amber, s:t_black, s:t_amber ]
let s:ERR  = [ s:fg, '#8b3bff', s:t_fg, 135 ]
for s:mode in ['normal', 'insert', 'visual', 'replace', 'inactive']
  execute 'let g:airline#themes#alan_turing#palette.' . s:mode . '.airline_warning = ' . string(s:WARN)
  execute 'let g:airline#themes#alan_turing#palette.' . s:mode . '.airline_warning2 = ' . string(s:WARN)
  execute 'let g:airline#themes#alan_turing#palette.' . s:mode . '.airline_error = ' . string(s:ERR)
endfor

let g:airline#themes#alan_turing#palette.tabline = {}
let s:T1 = [ s:fg, s:panel, s:t_fg, s:t_panel ]
let s:T3 = [ s:black, s:mode_normal, s:t_black, s:t_normal ]
let g:airline#themes#alan_turing#palette.tabline.airline_tab      = s:T1
let g:airline#themes#alan_turing#palette.tabline.airline_tabsel   = s:T3
let g:airline#themes#alan_turing#palette.tabline.airline_tabtype  = [ s:cyan, s:black, 87, s:t_black ]
let g:airline#themes#alan_turing#palette.tabline.airline_tabfill  = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let g:airline#themes#alan_turing#palette.tabline.airline_tabmod   = [ s:amber, s:panel, s:t_amber, s:t_panel, '' ]
let g:airline#themes#alan_turing#palette.tabline.airline_tabhid   = [ s:fg_dim, s:panel2, s:t_fgdim, s:t_panel ]
