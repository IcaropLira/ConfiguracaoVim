scriptencoding utf-8
if exists('g:loaded_my_themes')
    finish
endif
let g:loaded_my_themes = 1

" ============================================================
" Sistema de temas
"
" F1       -> próximo tema
" Shift+F1 -> tema anterior
"
" A lista abaixo é o catálogo principal. Para criar temas sem
" precisar mexer nesta lista, use :ThemeNew. Os temas criados por
" você ficam em ~/.vim/themes/ e o catálogo deles em
" ~/.vim/config/themes.local.vim, então uma nova instalação não
" apaga suas criações.
" ============================================================

let g:icaro_themes = [
      \ {'id': 'maria_isabel',       'title': 'Maria Isabel',       'short': 'MI',  'subtitle': 'Pensão de Pet'},
      \ {'id': 'jales',              'title': 'Jales',              'short': 'JAL', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'camelo',             'title': 'Camelo',             'short': 'CAM', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'sassa',              'title': 'Sassá?',              'short': 'SAS', 'subtitle': 'Antiresenha+'},
      \ {'id': 'malvadao',           'title': 'Malvadão',           'short': 'MAL', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'mateus_sao_paulino', 'title': 'Mateus São Paulino', 'short': 'MSP', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'pedro_de',           'title': 'Pedro de...',         'short': 'PED', 'subtitle': 'Pensão de Pet, cor : Clara'},
      \ {'id': 'belchior',           'title': 'Belchior',            'short': 'BEL', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'lucas_ribeiro',      'title': 'Lucas Ribeiro?',      'short': 'LUC', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'alan_turing',        'title': 'Alan Turing',         'short': 'AT',  'subtitle': 'Pensão de Pet'},
      \ {'id': 'alan_turing',        'title': 'Alan Turing',         'short': 'AT',  'subtitle': 'Antiresenha'},
      \ {'id': 'henrique',           'title': 'Henrique',             'short': 'HEN', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'off_light',          'title': 'Of(f) Light',          'short': 'OFF', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'geraldo',            'title': 'Geraldo',              'short': 'GER', 'subtitle': 'Pensão de Pet'},
      \ {'id': 'cabeludo',           'title': 'Cabeludo',             'short': 'CAB', 'subtitle': 'Antiresenha'},
      \ {'id': 'cookie',             'title': 'Cookie',               'short': 'CK',  'subtitle': 'Antiresenha'},
      \ {'id': 'ruiva',              'title': 'Ruiva',                'short': 'RUI', 'subtitle': 'Antiresenha'},
      \ {'id': 'baiana',             'title': 'Baiana',               'short': 'BAI', 'subtitle': 'Antiresenha'},
      \ {'id': 'do_mal',             'title': 'Do Mal',               'short': 'DM',  'subtitle': 'Antagonista'},
      \ {'id': 'sofia',              'title': 'Sofia',                'short': 'SOF', 'subtitle': 'Antiresenha'},
      \ {'id': 'guerra',             'title': 'Guerra',               'short': 'WAR', 'subtitle': 'Antiresenha+'},
      \ {'id': 'soares',             'title': 'Soares',               'short': 'SOA', 'subtitle': 'Pensão de Pet+'},
      \ {'id': 'biscoitinho',        'title': 'Biscoitinho',           'short': 'BIS', 'subtitle': 'Antagonista'},
      \ {'id': 'gvsl',               'title': 'GVSL',                  'short': 'GVS', 'subtitle': 'Antagonista'},
      \ {'id': 'jf',                 'title': 'JF',                    'short': 'JF',  'subtitle': 'GOATS'},
      \ {'id': 'toyman',             'title': 'ToyMan',                'short': 'TOY', 'subtitle': 'Antagonista'},
      \ {'id': 'massoni',            'title': 'Massoni',                'short': 'MAS', 'subtitle': 'GOATS'},
      \ {'id': 'dijkstra',           'title': 'Dijkstra',              'short': 'DIJ', 'subtitle': 'Como é que se escreve Dijkstra?'},
      \ {'id': 'ever_dream_this_man','title': 'Ever Dream This Man?',  'short': 'EDM', 'subtitle': ''},
      \ {'id': 'raul',               'title': 'Raul',                  'short': 'RAU', 'subtitle': ''},
      \ {'id': 'acesso_negado',      'title': 'ACESSO NEGADO',         'short': 'NEG', 'subtitle': ''},
      \ ]

let g:icaro_theme_state_file = expand('~/.vim/.icaro_theme_state')
let g:icaro_theme_local_file = expand('~/.vim/config/themes.local.vim')
let g:icaro_theme_local_root = expand('~/.vim/themes')
let g:icaro_theme_index = 0

" ------------------------------------------------------------
" Temas personalizados
" ------------------------------------------------------------
let g:icaro_custom_themes = []
if filereadable(g:icaro_theme_local_file)
    silent! execute 'source ' . fnameescape(g:icaro_theme_local_file)
endif
if !empty(g:icaro_custom_themes)
    let g:icaro_themes += g:icaro_custom_themes
endif

" ~/.vim/themes é um runtimepath separado dos temas que vêm com o projeto.
" Assim :ThemeNew não precisa alterar os arquivos oficiais.
if isdirectory(g:icaro_theme_local_root)
    execute 'set runtimepath^=' . fnameescape(g:icaro_theme_local_root)
endif

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

function! IcaroCurrentTheme() abort
    return g:icaro_themes[g:icaro_theme_index]
endfunction

function! IcaroThemeName() abort
    return get(IcaroCurrentTheme(), 'title', 'Tema')
endfunction

function! IcaroThemeShort() abort
    return get(IcaroCurrentTheme(), 'short', 'THEME')
endfunction

function! IcaroThemeSubtitle() abort
    return get(IcaroCurrentTheme(), 'subtitle', '')
endfunction

function! IcaroThemeBadge() abort
    return '[' . IcaroThemeShort() . '] ' . IcaroThemeName()
endfunction

function! IcaroThemeHeader() abort
    let l:subtitle = IcaroThemeSubtitle()
    return empty(l:subtitle) ? IcaroThemeBadge() : IcaroThemeBadge() . ' › ' . l:subtitle
endfunction

function! IcaroGitBranch() abort
    if exists('*FugitiveHead')
        let l:branch = FugitiveHead()
        if !empty(l:branch)
            return 'git:' . l:branch
        endif
    endif
    return ''
endfunction

function! IcaroClock() abort
    return strftime('%H:%M')
endfunction

function! IcaroModeLabel() abort
    let l:mode = mode()
    if l:mode =~# '^i'
        return 'INSERT'
    elseif l:mode =~# '^R'
        return 'REPLACE'
    elseif l:mode =~# '^v\|^V\|^'
        return 'VISUAL'
    elseif l:mode ==# 'c'
        return 'COMMAND'
    elseif l:mode ==# 't'
        return 'TERM'
    endif
    return 'NORMAL'
endfunction

function! s:ApplyTheme(idx) abort
    let g:icaro_theme_index = a:idx
    let l:theme = g:icaro_themes[a:idx]

    execute 'silent! colorscheme ' . l:theme.id

    " O Airline acompanha exatamente o colorscheme carregado.
    let g:airline_theme = l:theme.id
    if exists(':AirlineRefresh')
        silent! AirlineRefresh
    endif

    try
        call writefile([a:idx], g:icaro_theme_state_file)
    catch /.*/
        " Sem permissão de escrita, apenas não persiste.
    endtry
    redrawstatus!
endfunction

function! s:ShowThemePopup() abort
    let l:theme = IcaroCurrentTheme()
    let l:lines = ['[' . get(l:theme, 'short', 'THEME') . '] ' . l:theme.title]

    if !empty(l:theme.subtitle)
        call add(l:lines, l:theme.subtitle)
    endif

    call add(l:lines, '')
    call add(l:lines, 'F1 próximo  ·  Shift+F1 anterior')

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

function! CycleTheme() abort
    let l:next = (g:icaro_theme_index + 1) % len(g:icaro_themes)
    call s:ApplyTheme(l:next)
    call s:ShowThemePopup()
endfunction

function! PreviousTheme() abort
    let l:prev = (g:icaro_theme_index - 1 + len(g:icaro_themes)) % len(g:icaro_themes)
    call s:ApplyTheme(l:prev)
    call s:ShowThemePopup()
endfunction

function! ThemeInfo() abort
    call s:ShowThemePopup()
endfunction

function! s:ThemeSourcePath(theme) abort
    let l:id = a:theme.id
    if get(a:theme, 'custom', 0)
        return g:icaro_theme_local_root . '/colors/' . l:id . '.vim'
    endif
    return expand('~/.vim/pack/plugins/opt/icaro-theme/colors/' . l:id . '.vim')
endfunction

function! ThemeEdit() abort
    let l:path = s:ThemeSourcePath(IcaroCurrentTheme())
    if !filereadable(l:path)
        echoerr 'Arquivo de cores não encontrado: ' . l:path
        return
    endif
    execute 'edit ' . fnameescape(l:path)
endfunction

function! ThemeEditCatalog() abort
    let l:path = get(IcaroCurrentTheme(), 'custom', 0)
          \ ? g:icaro_theme_local_file
          \ : expand('~/.vim/config/themes.vim')
    if !filereadable(l:path)
        echoerr 'Catálogo de temas não encontrado: ' . l:path
        return
    endif
    execute 'edit ' . fnameescape(l:path)
endfunction

function! s:SlugifyThemeName(name) abort
    let l:s = tolower(a:name)
    let l:s = substitute(l:s, '[^a-z0-9_ -]', '', 'g')
    let l:s = substitute(l:s, '[ -]\+', '_', 'g')
    let l:s = substitute(l:s, '^_\|_$', '', 'g')
    return empty(l:s) ? 'meu_tema' : l:s
endfunction

function! s:ThemeExists(id) abort
    for l:theme in g:icaro_themes
        if l:theme.id ==# a:id
            return 1
        endif
    endfor
    return 0
endfunction

function! s:EnsureThemeLocalFile() abort
    if !isdirectory(g:icaro_theme_local_root . '/colors')
        call mkdir(g:icaro_theme_local_root . '/colors', 'p')
    endif
    if !isdirectory(g:icaro_theme_local_root . '/autoload/airline/themes')
        call mkdir(g:icaro_theme_local_root . '/autoload/airline/themes', 'p')
    endif
    if !filereadable(g:icaro_theme_local_file)
        call writefile([
              \ 'scriptencoding utf-8',
              \ '',
              \ '" Catálogo de temas pessoais — gerado/atualizado por :ThemeNew.',
              \ 'let g:icaro_custom_themes = []',
              \ ], g:icaro_theme_local_file)
    endif
endfunction

function! s:AppendCustomTheme(theme) abort
    call s:EnsureThemeLocalFile()
    call writefile([
          \ '',
          \ 'call add(g:icaro_custom_themes, ' . string(a:theme) . ')',
          \ ], g:icaro_theme_local_file, 'a')
endfunction

function! ThemeNew() abort
    let l:name = input('Nome do novo tema: ')
    if empty(l:name)
        return
    endif

    let l:default_id = s:SlugifyThemeName(l:name)
    let l:id = input('ID/arquivo [' . l:default_id . ']: ', l:default_id)
    let l:id = tolower(substitute(l:id, '[^a-z0-9_]', '_', 'g'))
    if empty(l:id) || s:ThemeExists(l:id)
        echoerr 'ID vazio ou já existente: ' . l:id
        return
    endif

    let l:short = input('Sigla do header [3-4 chars]: ')
    if empty(l:short)
        let l:short = toupper(strpart(l:id, 0, 3))
    endif
    let l:short = toupper(l:short)
    let l:subtitle = input('Subtítulo/descrição (opcional): ')

    let l:source = s:ThemeSourcePath(IcaroCurrentTheme())
    let l:dest = g:icaro_theme_local_root . '/colors/' . l:id . '.vim'
    call s:EnsureThemeLocalFile()

    if !filereadable(l:source)
        echoerr 'Não consegui localizar o tema atual para copiar.'
        return
    endif

    call writefile(readfile(l:source), l:dest)

    " Se existir um tema Airline correspondente, copia também. Se não
    " existir, o Airline simplesmente usa o fallback dele.
    let l:air_source = substitute(l:source, '/colors/', '/autoload/airline/themes/', '')
    if filereadable(l:air_source)
        let l:air_dest = g:icaro_theme_local_root . '/autoload/airline/themes/' . l:id . '.vim'
        call writefile(readfile(l:air_source), l:air_dest)
    endif

    let l:theme = {
          \ 'id': l:id,
          \ 'title': l:name,
          \ 'short': l:short,
          \ 'subtitle': l:subtitle,
          \ 'custom': 1,
          \ }
    call s:AppendCustomTheme(l:theme)

    " Adiciona em memória e já muda para o novo tema.
    call add(g:icaro_themes, l:theme)
    call s:ApplyTheme(len(g:icaro_themes) - 1)

    echo 'Tema criado. :ThemeEdit abre as cores para você editar.'
    call ThemeEdit()
endfunction

function! ThemeList() abort
    let l:lines = [' TEMAS  —  F1 próximo / Shift+F1 anterior ', '']
    for l:i in range(0, len(g:icaro_themes) - 1)
        let l:t = g:icaro_themes[l:i]
        let l:marker = l:i == g:icaro_theme_index ? '>' : ' '
        call add(l:lines, printf('%s %2d  %-4s  %s', l:marker, l:i + 1, get(l:t, 'short', '----'), l:t.title))
    endfor

    if exists('*popup_create')
        call popup_create(l:lines, {
              \ 'pos': 'center',
              \ 'border': [1, 1, 1, 1],
              \ 'padding': [0, 1, 0, 1],
              \ 'highlight': 'Pmenu',
              \ 'borderhighlight': ['PmenuSel'],
              \ 'zindex': 300,
              \ 'maxheight': &lines - 4,
              \ 'scrollbar': 1,
              \ })
    else
        echo join(l:lines, "\n")
    endif
endfunction

command! ThemeNext call CycleTheme()
command! ThemePrev call PreviousTheme()
command! ThemeInfo call ThemeInfo()
command! ThemeList call ThemeList()
command! ThemeEdit call ThemeEdit()
command! ThemeMeta call ThemeEditCatalog()
command! ThemeNew call ThemeNew()

" Aplica o tema salvo (ou o primeiro da lista na primeira execução).
call s:ApplyTheme(s:LoadThemeIndex())
