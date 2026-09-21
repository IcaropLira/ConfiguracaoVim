scriptencoding utf-8
if exists('g:loaded_my_cheatsheet')
    finish
endif
let g:loaded_my_cheatsheet = 1

" ============================================================
" Folha de atalhos (F12) — liga/desliga (toggle)
" ============================================================
" Aperta F12 pra abrir e aperta F12 de novo pra fechar. Tentamos antes um modo "aparece enquanto segura" (baseado
" na repetição automática do teclado), mas na prática ficou
" inconsistente dependendo do sistema — o toggle simples é mais
" confiável.

let g:icaro_cheatsheet_id = -1

let s:CHEATSHEET_LINES = [
      \ ' ATALHOS DESTA CONFIGURACAO ',
      \ '',
      \ ' F1   trocar de tema (popup c/ nome)',
      \ ' F2   abrir/fechar o explorer (NERDTree)',
      \ ' F3   liga/desliga dicas de parametro inline',
      \ ' F4   liga/desliga o autocomplete',
      \ ' F5   compilar',
      \ ' F6   executar',
      \ ' F7   compilar + executar',
      \ ' F8   compilar + executar com input.txt',
      \ ' F9   abrir terminal',
      \ ' F12  esta folha de atalhos',
      \ '',
      \ ' Ctrl+S            salvar',
      \ ' Ctrl+H/J/K/L      navegar entre janelas',
      \ ' Tab / Shift+Tab   proximo / anterior buffer',
      \ ' Shift+BS / Ctrl+BS  apaga um par vazio () [] {} "" '' de uma vez',
      \ ' Esc               limpar highlight da busca',
      \ '',
      \ ' AUTOCOMPLETE (coc.nvim) ',
      \ ' gd    ir para definicao',
      \ ' gy    ir para definicao do tipo',
      \ ' gr    ver referencias',
      \ ' K     documentacao do simbolo',
      \ ' <leader>rn   renomear simbolo',
      \ ' <leader>oi   organizar imports',
      \ ' <leader>s    assinatura do metodo',
      \ ' Tab/S-Tab    navegar nas sugestoes',
      \ ' Enter        confirmar sugestao',
      \ ' Ctrl+j/k     pular entre parametros',
      \ '',
      \ ' NERDTREE (com o explorer aberto) ',
      \ ' Enter/o   abrir arquivo/diretorio',
      \ ' t         abrir em nova aba',
      \ ' i / s     abrir em split horiz./vert.',
      \ ' m         menu (criar/renomear/mover/apagar)',
      \ ' R         atualizar a arvore',
      \ ' q         fechar o NERDTree',
      \ '',
      \ ' EDICAO BASICA DO VIM ',
      \ ' i / a / o        entrar no insert (antes/depois/nova linha)',
      \ ' Esc               voltar pro modo normal',
      \ ' x / dd / yy / p   apagar char / linha / copiar linha / colar',
      \ ' u / Ctrl+r        desfazer / refazer',
      \ ' ciw / caw          trocar palavra (dentro/com espaco)',
      \ ' v / V / Ctrl+v    selecao visual (char/linha/bloco)',
      \ ' :w  :q  :wq       salvar / sair / salvar e sair',
      \ '',
      \ ' NAVEGACAO ',
      \ ' h j k l     esquerda/baixo/cima/direita',
      \ ' w / b       proxima / palavra anterior',
      \ ' 0 / $       inicio / fim da linha',
      \ ' gg / G      inicio / fim do arquivo',
      \ ' /texto      buscar  (n / N = proximo/anterior)',
      \ ' %           pular pro parentese/chave correspondente',
      \ '',
      \ ' (aperte qualquer tecla para fechar) ',
      \ ]

function! s:CloseCheatsheet() abort
    if g:icaro_cheatsheet_id != -1
        call popup_close(g:icaro_cheatsheet_id)
        let g:icaro_cheatsheet_id = -1
    endif
endfunction

" Função usada pelo mapeamento padrão do F12: aperta pra abrir,
" aperta F12 de novo pra fechar.
function! ToggleCheatsheet() abort
    if g:icaro_cheatsheet_id != -1 && popup_getpos(g:icaro_cheatsheet_id) != {}
        call s:CloseCheatsheet()
        return
    endif

    let g:icaro_cheatsheet_id = popup_create(s:CHEATSHEET_LINES, {
          \ 'pos': 'center',
          \ 'border': [1, 1, 1, 1],
          \ 'padding': [0, 2, 0, 2],
          \ 'highlight': 'Pmenu',
          \ 'borderhighlight': ['PmenuSel'],
          \ 'zindex': 300,
          \ 'maxheight': &lines - 6,
          \ 'scrollbar': 1,
          \ 'filter': function('s:CheatsheetFilter'),
          \ 'mapping': 0,
          \ })
endfunction

" O próprio F12 também fecha o popup quando ele está aberto
function! s:CheatsheetFilter(id, key) abort
    " O F12 precisa funcionar como toggle mesmo com o popup focado.
    " Qualquer outra tecla passa normalmente para o Vim.
    if a:key ==# "\<F12>"
        call s:CloseCheatsheet()
        return 1
    endif
    return 0
endfunction

" ------------------------------------------------------------
" Alternativa não usada por padrão: "aparece enquanto segura",
" baseado na repetição automática do teclado (o sistema operacional
" manda a tecla repetida enquanto você segura; quando solta, a
" repetição para). Na prática ficou inconsistente dependendo do
" sistema, por isso o F12 usa o ToggleCheatsheet() acima — mas essa
" função continua aqui, disponível, caso você queira usar em outra
" tecla e testar no seu computador.
" ------------------------------------------------------------
let g:icaro_cheatsheet_release_ms = 500

function! ShowCheatsheetWhileHeld() abort
    if g:icaro_cheatsheet_id != -1
        return
    endif

    let g:icaro_cheatsheet_id = popup_create(s:CHEATSHEET_LINES, {
          \ 'pos': 'center',
          \ 'border': [1, 1, 1, 1],
          \ 'padding': [0, 2, 0, 2],
          \ 'highlight': 'Pmenu',
          \ 'borderhighlight': ['PmenuSel'],
          \ 'zindex': 300,
          \ 'maxheight': &lines - 6,
          \ 'scrollbar': 1,
          \ 'mapping': 0,
          \ })
    redraw

    let l:threshold = get(g:, 'icaro_cheatsheet_release_ms', 500) / 1000.0
    let l:last_seen = reltime()

    while 1
        let l:c = getchar(0)

        if l:c == 0
            if reltimefloat(reltime(l:last_seen)) > l:threshold
                break
            endif
            sleep 15m
            continue
        endif

        if l:c ==# "\<F12>"
            let l:last_seen = reltime()
        else
            let l:key = (type(l:c) == v:t_number) ? nr2char(l:c) : l:c
            call feedkeys(l:key, 'i')
            break
        endif
    endwhile

    call s:CloseCheatsheet()
endfunction
