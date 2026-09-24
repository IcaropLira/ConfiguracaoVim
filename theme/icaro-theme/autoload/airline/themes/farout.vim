" ============================================================
" Tema do vim-airline "farout"
" ============================================================

let s:black = '#0F0908'
let s:panel = '#291916'
let s:panel2 = '#1F1311'
let s:fg = '#E0CCAE'
let s:fg_dim = '#A67458'

let s:red = '#F2A766'
let s:red_bright = '#F2DDBC'
let s:red_dim = '#BF472C'
let s:red_soft = '#D47D49'
let s:amber = '#F2DDBC'

let s:t_black  = 232
let s:t_panel  = 234
let s:t_fg     = 187
let s:t_fgdim  = 137
let s:t_red        = 215
let s:t_red_bright = 223
let s:t_red_dim    = 130
let s:t_red_soft   = 173
let s:t_amber      = 223

let g:airline#themes#farout#palette = {}

let s:N1 = [ s:black, s:red,   s:t_black, s:t_red ]
let s:N2 = [ s:fg,    s:panel, s:t_fg,    s:t_panel ]
let s:N3 = [ s:red,   s:panel2, s:t_red,   s:t_panel ]
let g:airline#themes#farout#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let s:I1 = [ s:black, s:red_bright, s:t_black, s:t_red_bright ]
let s:I2 = s:N2
let s:I3 = [ s:red_bright, s:panel2, s:t_red_bright, s:t_panel ]
let g:airline#themes#farout#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)

let s:V1 = [ s:black, s:red_soft, s:t_black, s:t_red_soft ]
let s:V2 = s:N2
let s:V3 = [ s:red_soft, s:panel2, s:t_red_soft, s:t_panel ]
let g:airline#themes#farout#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let s:R1 = [ s:fg, s:red, s:t_fg, s:t_red ]
let s:R2 = s:N2
let s:R3 = [ s:red, s:panel2, s:t_red, s:t_panel ]
let g:airline#themes#farout#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)

let s:IA1 = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let s:IA2 = [ s:fg_dim, s:panel, s:t_fgdim, s:t_panel ]
let s:IA3 = s:IA2
let g:airline#themes#farout#palette.inactive = airline#themes#generate_color_map(s:IA1, s:IA2, s:IA3)

let s:MOD = [ s:amber, '', s:t_amber, '', '' ]
let g:airline#themes#farout#palette.normal_modified   = { 'airline_c': s:MOD }
let g:airline#themes#farout#palette.insert_modified   = { 'airline_c': s:MOD }
let g:airline#themes#farout#palette.visual_modified   = { 'airline_c': s:MOD }
let g:airline#themes#farout#palette.replace_modified  = { 'airline_c': s:MOD }
let g:airline#themes#farout#palette.inactive_modified = { 'airline_c': s:MOD }

let s:WARN = [ s:black, s:amber, s:t_black, s:t_amber ]
let s:ERR  = [ s:fg, s:red_dim, s:t_fg, s:t_red_dim ]

for s:mode in ['normal', 'insert', 'visual', 'replace', 'inactive']
  execute 'let g:airline#themes#farout#palette.' . s:mode . '.airline_warning = ' . string(s:WARN)
  execute 'let g:airline#themes#farout#palette.' . s:mode . '.airline_warning2 = ' . string(s:WARN)
  execute 'let g:airline#themes#farout#palette.' . s:mode . '.airline_error = ' . string(s:ERR)
endfor

let g:airline#themes#farout#palette.tabline = {}
let s:T1 = [ s:fg,   s:panel,  s:t_fg,    s:t_panel ]
let s:T2 = [ s:red,  s:black,  s:t_red,   s:t_black ]
let s:T3 = [ s:black, s:red,   s:t_black, s:t_red ]
let g:airline#themes#farout#palette.tabline.airline_tab      = s:T1
let g:airline#themes#farout#palette.tabline.airline_tabsel   = s:T3
let g:airline#themes#farout#palette.tabline.airline_tabtype  = s:T2
let g:airline#themes#farout#palette.tabline.airline_tabfill  = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let g:airline#themes#farout#palette.tabline.airline_tabmod   = [ s:amber, s:panel, s:t_amber, s:t_panel, '' ]
let g:airline#themes#farout#palette.tabline.airline_tabhid   = [ s:fg_dim, s:panel2, s:t_fgdim, s:t_panel ]
