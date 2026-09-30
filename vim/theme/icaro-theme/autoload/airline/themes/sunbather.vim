" ============================================================
" Tema do vim-airline "sunbather"
" ============================================================

let s:black = '#000000'
let s:panel = '#121212'
let s:panel2 = '#262626'
let s:fg = '#c6c6c6'
let s:fg_dim = '#a8a8a8'

let s:red = '#e32791'
let s:red_bright = '#ff5f87'
let s:red_dim = '#7a1550'
let s:red_soft = '#d75f87'
let s:amber = '#ffff87'

let s:t_black  = 16
let s:t_panel  = 233
let s:t_fg     = 251
let s:t_fgdim  = 248
let s:t_red        = 162
let s:t_red_bright = 204
let s:t_red_dim    = 89
let s:t_red_soft   = 168
let s:t_amber      = 228

let g:airline#themes#sunbather#palette = {}

let s:N1 = [ s:black, s:red,   s:t_black, s:t_red ]
let s:N2 = [ s:fg,    s:panel, s:t_fg,    s:t_panel ]
let s:N3 = [ s:red,   s:panel2, s:t_red,   s:t_panel ]
let g:airline#themes#sunbather#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let s:I1 = [ s:black, s:red_bright, s:t_black, s:t_red_bright ]
let s:I2 = s:N2
let s:I3 = [ s:red_bright, s:panel2, s:t_red_bright, s:t_panel ]
let g:airline#themes#sunbather#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)

let s:V1 = [ s:black, s:red_soft, s:t_black, s:t_red_soft ]
let s:V2 = s:N2
let s:V3 = [ s:red_soft, s:panel2, s:t_red_soft, s:t_panel ]
let g:airline#themes#sunbather#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let s:R1 = [ s:fg, s:red, s:t_fg, s:t_red ]
let s:R2 = s:N2
let s:R3 = [ s:red, s:panel2, s:t_red, s:t_panel ]
let g:airline#themes#sunbather#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)

let s:IA1 = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let s:IA2 = [ s:fg_dim, s:panel, s:t_fgdim, s:t_panel ]
let s:IA3 = s:IA2
let g:airline#themes#sunbather#palette.inactive = airline#themes#generate_color_map(s:IA1, s:IA2, s:IA3)

let s:MOD = [ s:amber, '', s:t_amber, '', '' ]
let g:airline#themes#sunbather#palette.normal_modified   = { 'airline_c': s:MOD }
let g:airline#themes#sunbather#palette.insert_modified   = { 'airline_c': s:MOD }
let g:airline#themes#sunbather#palette.visual_modified   = { 'airline_c': s:MOD }
let g:airline#themes#sunbather#palette.replace_modified  = { 'airline_c': s:MOD }
let g:airline#themes#sunbather#palette.inactive_modified = { 'airline_c': s:MOD }

let s:WARN = [ s:black, s:amber, s:t_black, s:t_amber ]
let s:ERR  = [ s:fg, s:red_dim, s:t_fg, s:t_red_dim ]

for s:mode in ['normal', 'insert', 'visual', 'replace', 'inactive']
  execute 'let g:airline#themes#sunbather#palette.' . s:mode . '.airline_warning = ' . string(s:WARN)
  execute 'let g:airline#themes#sunbather#palette.' . s:mode . '.airline_warning2 = ' . string(s:WARN)
  execute 'let g:airline#themes#sunbather#palette.' . s:mode . '.airline_error = ' . string(s:ERR)
endfor

let g:airline#themes#sunbather#palette.tabline = {}
let s:T1 = [ s:fg,   s:panel,  s:t_fg,    s:t_panel ]
let s:T2 = [ s:red,  s:black,  s:t_red,   s:t_black ]
let s:T3 = [ s:black, s:red,   s:t_black, s:t_red ]
let g:airline#themes#sunbather#palette.tabline.airline_tab      = s:T1
let g:airline#themes#sunbather#palette.tabline.airline_tabsel   = s:T3
let g:airline#themes#sunbather#palette.tabline.airline_tabtype  = s:T2
let g:airline#themes#sunbather#palette.tabline.airline_tabfill  = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let g:airline#themes#sunbather#palette.tabline.airline_tabmod   = [ s:amber, s:panel, s:t_amber, s:t_panel, '' ]
let g:airline#themes#sunbather#palette.tabline.airline_tabhid   = [ s:fg_dim, s:panel2, s:t_fgdim, s:t_panel ]
