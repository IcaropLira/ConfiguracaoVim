scriptencoding utf-8
if exists('g:loaded_my_themes')
    finish
endif
let g:loaded_my_themes = 1

" ============================================================
" Temas
"
" F1 alterna entre as entradas abaixo.
"
" IMPORTANTE:
" Entradas repetidas são INTENCIONAIS quando o subtitle muda.
" Ex.: Alan Turing / Pensão de Pet e Alan Turing / Antiresenha.
" O ID continua sendo o mesmo porque é o mesmo colorscheme; a
" tag inferior identifica a "edição" que está sendo exibida.
" ============================================================

let g:icaro_themes = [
      \ {'id': 'maria_isabel',       'title': 'Maria Isabel',       'subtitle': 'Pensão de Pet'},
      \ {'id': 'jales',              'title': 'Jales',              'subtitle': 'Pensão de Pet'},
      \ {'id': 'camelo',             'title': 'Camelo',             'subtitle': 'Pensão de Pet'},
      \ {'id': 'sassa',              'title': 'Sassá?',              'subtitle': 'Antiresenha+'},
      \ {'id': 'malvadao',           'title': 'Malvadão',           'subtitle': 'Pensão de Pet'},
      \ {'id': 'mateus_sao_paulino', 'title': 'Mateus São Paulino', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'pedro_de',           'title': 'Pedro de...',         'subtitle': 'Pensão de Pet, cor : Clara'},
      \ {'id': 'belchior',           'title': 'Belchior',            'subtitle': 'Pensão de Pet'},
      \ {'id': 'lucas_ribeiro',      'title': 'Lucas Ribeiro?',      'subtitle': 'Pensão de Pet'},
      \ {'id': 'alan_turing',        'title': 'Alan Turing',         'subtitle': 'Pensão de Pet'},
      \ {'id': 'alan_turing',        'title': 'Alan Turing',         'subtitle': 'Antiresenha'},
      \ {'id': 'henrique',           'title': 'Henrique',            'subtitle': 'Pensão de Pet'},
      \ {'id': 'off_light',          'title': 'Of(f) Light',          'subtitle': 'Pensão de Pet'},
      \ {'id': 'geraldo',            'title': 'Geraldo',              'subtitle': 'Pensão de Pet'},
      \ {'id': 'cabeludo',           'title': 'Cabeludo',             'subtitle': 'Antiresenha'},
      \ {'id': 'cookie',             'title': 'Cookie',               'subtitle': 'Antiresenha'},
      \ {'id': 'ruiva',              'title': 'Ruiva',                'subtitle': 'Antiresenha'},
      \ {'id': 'baiana',             'title': 'Baiana',               'subtitle': 'Antiresenha'},
      \ {'id': 'do_mal',             'title': 'Do Mal',               'subtitle': 'Antagonista'},
      \ {'id': 'sofia',              'title': 'Sofia',                'subtitle': 'Antiresenha'},
      \ {'id': 'guerra',             'title': 'Guerra',               'subtitle': 'Antiresenha+'},
      \ {'id': 'soares',             'title': 'Soares',               'subtitle': 'Pensão de Pet+'},
      \ {'id': 'biscoitinho',        'title': 'Biscoitinho',           'subtitle': 'Antagonista'},
      \ {'id': 'gvsl',               'title': 'GVSL',                  'subtitle': 'Antagonista'},
      \ {'id': 'jf',                 'title': 'JF',                    'subtitle': 'GOATS'},
      \ {'id': 'toyman',             'title': 'ToyMan',                'subtitle': 'Antagonista'},
      \ {'id': 'massoni',            'title': 'Massoni',                'subtitle': 'GOATS'},
      \ {'id': 'dijkstra',           'title': 'Dijkstra',              'subtitle': 'Como é que se escreve Dijkstra?'},
      \ {'id': 'ever_dream_this_man','title': 'Ever Dream This Man?',  'subtitle': ''},
      \ {'id': 'raul',               'title': 'Raul',                  'subtitle': ''},
      \ {'id': 'acesso_negado',      'title': 'ACESSO NEGADO',         'subtitle': ''},
      \ ]

let g:icaro_theme_state_file = expand('~/.vim/.icaro_theme_state')
let g:icaro_theme_index = 0

function! s:LoadThemeIndex() abort
    if filereadable(g:icaro_theme_state_file)
        let l:lines = readfile(g:icaro_theme_state_file)
        if !empty(l:lines)
            let l:idx = str2nr(l:lines[0])
            if l:idx >= 0 && l:idx < len(g:icaro_themes)
                return l:idx
            endif
        endif
    endif
    return 0
endfunction

function! s:ApplyTheme(idx) abort
    let g:icaro_theme_index = a:idx
    let l:theme = g:icaro_themes[a:idx]

    execute 'silent! colorscheme ' . l:theme.id

    " O Airline deve acompanhar EXATAMENTE o colorscheme carregado.
    let g:airline_theme = l:theme.id
    if exists(':AirlineRefresh')
        silent! AirlineRefresh
    endif

    try
        call writefile([a:idx], g:icaro_theme_state_file)
    catch /.*/
        " Sem permissão de escrita, apenas não persiste.
    endtry
endfunction

function! s:ShowThemePopup() abort
    let l:theme = g:icaro_themes[g:icaro_theme_index]
    let l:lines = [l:theme.title]

    if !empty(l:theme.subtitle)
        call add(l:lines, l:theme.subtitle)
    endif

    if exists('*popup_notification')
        call popup_notification(l:lines, {
              \ 'time': 1600,
              \ 'pos': 'center',
              \ 'border': [1, 1, 1, 1],
              \ 'padding': [0, 2, 0, 2],
              \ 'highlight': 'PmenuSel',
              \ 'borderhighlight': ['PmenuSel'],
              \ 'zindex': 300,
              \ })
    else
        echo join(l:lines, ' - ')
    endif
endfunction

" Alterna para a próxima entrada da lista (F1).
function! CycleTheme() abort
    let l:next = (g:icaro_theme_index + 1) % len(g:icaro_themes)
    call s:ApplyTheme(l:next)
    call s:ShowThemePopup()
endfunction

" Aplica o tema salvo (ou o primeiro da lista na primeira execução).
call s:ApplyTheme(s:LoadThemeIndex())
