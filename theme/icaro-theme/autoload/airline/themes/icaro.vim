" ============================================================
" Tema do vim-airline "icaro" — preto + vermelho
" Estrutura baseada no formato oficial dos temas do vim-airline
" (airline#themes#generate_color_map), só trocando a paleta.
" ============================================================

let s:black      = '#0a0a0c'
let s:panel      = '#151518'
let s:panel2     = '#1c1c20'
let s:fg         = '#e8e6e3'
let s:fg_dim     = '#8a8488'

let s:red        = '#e63946'
let s:red_bright = '#ff5d5d'
let s:red_dim    = '#9d0208'
let s:red_soft   = '#c9184a'
let s:amber      = '#e0a458'

let s:t_black  = 233
let s:t_panel  = 234
let s:t_fg     = 253
let s:t_fgdim  = 244
let s:t_red        = 196
let s:t_red_bright = 203
let s:t_red_dim    = 88
let s:t_red_soft   = 161
let s:t_amber      = 179

let g:airline#themes#icaro#palette = {}

" Seção A (pílula do modo) / Seção B / Seção C
let s:N1 = [ s:black, s:red,   s:t_black, s:t_red ]
let s:N2 = [ s:fg,    s:panel, s:t_fg,    s:t_panel ]
let s:N3 = [ s:red,   s:black, s:t_red,   s:t_black ]
let g:airline#themes#icaro#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)

let s:I1 = [ s:black, s:red_bright, s:t_black, s:t_red_bright ]
let s:I2 = s:N2
let s:I3 = [ s:red_bright, s:black, s:t_red_bright, s:t_black ]
let g:airline#themes#icaro#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)

let s:V1 = [ s:black, s:red_soft, s:t_black, s:t_red_soft ]
let s:V2 = s:N2
let s:V3 = [ s:red_soft, s:black, s:t_red_soft, s:t_black ]
let g:airline#themes#icaro#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)

let s:R1 = [ s:fg, s:red_dim, s:t_fg, s:t_red_dim ]
let s:R2 = s:N2
let s:R3 = [ s:red_dim, s:black, s:t_red_dim, s:t_black ]
let g:airline#themes#icaro#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)

let s:IA1 = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let s:IA2 = [ s:fg_dim, s:panel, s:t_fgdim, s:t_panel ]
let s:IA3 = s:IA2
let g:airline#themes#icaro#palette.inactive = airline#themes#generate_color_map(s:IA1, s:IA2, s:IA3)

" modificado (buffer com alterações não salvas) usa um destaque sutil
let s:MOD = [ s:amber, '', s:t_amber, '', '' ]
let g:airline#themes#icaro#palette.normal_modified   = { 'airline_c': s:MOD }
let g:airline#themes#icaro#palette.insert_modified   = { 'airline_c': s:MOD }
let g:airline#themes#icaro#palette.visual_modified   = { 'airline_c': s:MOD }
let g:airline#themes#icaro#palette.replace_modified  = { 'airline_c': s:MOD }
let g:airline#themes#icaro#palette.inactive_modified = { 'airline_c': s:MOD }

" Warning / Error — mantidos em âmbar/vermelho vivo pra continuar
" funcionalmente legível (diagnóstico), mas ainda dentro da paleta
let s:WARN = [ s:black, s:amber, s:t_black, s:t_amber ]
let s:ERR  = [ s:fg, s:red_dim, s:t_fg, s:t_red_dim ]

for s:mode in ['normal', 'insert', 'visual', 'replace', 'inactive']
  execute 'let g:airline#themes#icaro#palette.' . s:mode . '.airline_warning = ' . string(s:WARN)
  execute 'let g:airline#themes#icaro#palette.' . s:mode . '.airline_warning2 = ' . string(s:WARN)
  execute 'let g:airline#themes#icaro#palette.' . s:mode . '.airline_error = ' . string(s:ERR)
endfor

" Seção Y (usada pro indicador de autocomplete) e tabline (buffers)
" combinando com o painel escuro
let g:airline#themes#icaro#palette.tabline = {}
let s:T1 = [ s:fg,   s:panel,  s:t_fg,    s:t_panel ]
let s:T2 = [ s:red,  s:black,  s:t_red,   s:t_black ]
let s:T3 = [ s:black, s:red,   s:t_black, s:t_red ]
let g:airline#themes#icaro#palette.tabline.airline_tab      = s:T1
let g:airline#themes#icaro#palette.tabline.airline_tabsel   = s:T3
let g:airline#themes#icaro#palette.tabline.airline_tabtype  = s:T2
let g:airline#themes#icaro#palette.tabline.airline_tabfill  = [ s:fg_dim, s:black, s:t_fgdim, s:t_black ]
let g:airline#themes#icaro#palette.tabline.airline_tabmod   = [ s:amber, s:panel, s:t_amber, s:t_panel, '' ]
let g:airline#themes#icaro#palette.tabline.airline_tabhid   = [ s:fg_dim, s:panel2, s:t_fgdim, s:t_panel ]
