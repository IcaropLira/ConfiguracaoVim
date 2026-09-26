if exists('g:loaded_my_runner')
    finish
endif
let g:loaded_my_runner = 1

" ============================================================
" Executor de comandos (compilar/rodar) num terminal de verdade,
" em vez do ":!" bloqueante.
"
" Por quê: ":!comando" trava a entrada do Vim até o comando acabar.
" Se você cola um texto grande no editor e logo em seguida compila,
" o que ainda estava "na fila" pra ser digitado só chega no Vim
" DEPOIS que o ":!" devolve o controle — e nesse momento vira uma
" sequência de comandos de modo normal, jogando pedaços de texto no
" meio do código sem você querer. Rodando num ":terminal" de verdade
" (assíncrono), isso não acontece: o Vim continua processando o
" teclado normalmente o tempo todo, sem travar esperando o comando.
" ============================================================

let g:icaro_runner_bufnr = -1

function! IcaroRunInTerminal(cmd) abort
    if !exists('*term_start')
        " Vim muito antigo, sem suporte a terminal — cai de volta pro
        " jeito antigo (bloqueante), mas isso não deveria acontecer
        " em nenhuma instalação moderna
        execute '!' . a:cmd
        return
    endif

    " Fecha o terminal anterior (se tiver) pra não acumular um por
    " cada F5/F6/F7/F8 que você aperta
    if g:icaro_runner_bufnr != -1 && bufexists(g:icaro_runner_bufnr)
        execute 'silent! bwipeout! ' . g:icaro_runner_bufnr
    endif

    botright 14new

    " O terminal não fecha mais sozinho quando o comando termina: a
    " janela fica aberta mostrando toda a saída (e o código de saída,
    " no fim). Quem some o terminal antigo é a limpeza lá em cima
    " (antes de abrir um novo com F5/F6/F7/F8) — ou você mesmo, com
    " 'q' (veja abaixo).
    let l:wrapped = a:cmd . '; echo; echo "[Codigo de saida: $?]"'

    let l:shell = executable('bash') ? 'bash' : 'sh'
    let g:icaro_runner_bufnr = term_start([l:shell, '-c', l:wrapped], {
                \ 'curwin': 1,
                \ 'term_kill': 'kill',
                \ 'term_name': 'output',
                \ })
    setlocal nonumber norelativenumber signcolumn=no

    " ------------------------------------------------------------
    " Scroll: por padrão, um terminal do Vim fica em "Terminal-Job
    " mode" (as teclas vão direto pro processo, pra você poder digitar
    " a entrada do programa), e nesse modo as setas/Ctrl-U/Ctrl-D não
    " rolam a tela — elas também são enviadas pro processo. Se a saída
    " (ou a entrada que você colou/digitou) for maior que as 14 linhas
    " da janela, ela passa batido sem dar pra ver o começo.
    "
    " Aperte Esc (a qualquer momento, rodando ou já terminado) pra
    " entrar no "Terminal-Normal mode" (o modo normal do Vim de
    " verdade): setas, j/k, Ctrl-U/Ctrl-D, gg (vai pro topo — início
    " da execução), G (vai pro fim) rolam a tela livremente. 'i' (ou
    " 'a') volta pro modo de terminal, caso o programa ainda esteja
    " rodando e esperando você digitar algo.
    " ------------------------------------------------------------
    tnoremap <buffer><silent> <Esc> <C-\><C-n>

    " Fecha a janela com uma tecla só, uma vez em Terminal-Normal mode
    " ('q' é uma tecla livre lá, não é usada pra mais nada nesse modo)
    nnoremap <buffer><silent> q :bwipeout!<CR>
endfunction
