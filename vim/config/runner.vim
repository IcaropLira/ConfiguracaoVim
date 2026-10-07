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

let g:icaro_runner_job = -1
let g:icaro_runner_bufnr = -1

" O terminal "terminou" quando o processo acabou (term_getstatus contém "finished").
" Consultamos o estado real do buffer em vez de uma flag, que dependia de callback.
function! IcaroRunnerFinished() abort
    if !exists('*term_getstatus')
        return 0
    endif
    return term_getstatus(bufnr('%')) =~# 'finished'
endfunction

" Enter em Terminal-Job mode (programa ainda rodando ou acabou de terminar).
function! IcaroRunnerEnter() abort
    if IcaroRunnerFinished()
        " Sai do Terminal-Job mode e fecha a janela.
        " (\<CR> e não <CR>: dentro de aspas duplas, <CR> seria texto literal.)
        return "\<C-\\>\<C-n>:bwipeout!\<CR>"
    endif
    " Enquanto o programa ainda está rodando, o Enter vai normalmente
    " para o processo (stdin).
    return "\<CR>"
endfunction

" Enter em Terminal-Normal mode. É AQUI que o Vim fica depois que o programa
" termina (ou depois de apertar Esc): o tnoremap acima não vale mais nesse modo.
function! IcaroRunnerNormalEnter() abort
    if IcaroRunnerFinished()
        bwipeout!
    else
        normal! j
    endif
endfunction

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
    " Marca o terminal como "em execução". O callback abaixo troca
    " para 1 quando o processo terminar.
    let l:wrapped = a:cmd . '; icaro_ec=$?; echo; echo "[Codigo de saida: $icaro_ec]  —  Enter ou q fecha"'
    let l:shell = executable('bash') ? 'bash' : 'sh'
    let g:icaro_runner_job = term_start([l:shell, '-c', l:wrapped], {
                \ 'curwin': 1,
                \ 'term_kill': 'kill',
                \ 'term_name': 'output',
                \ })
    let g:icaro_runner_bufnr = exists('*term_getbuf') ? term_getbuf(g:icaro_runner_job) : bufnr('%')
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
    tnoremap <buffer><silent><expr> <CR> IcaroRunnerEnter()
    tnoremap <buffer><silent> <Esc> <C-\><C-n>
    nnoremap <buffer><silent> <CR> :call IcaroRunnerNormalEnter()<CR>

    " Fecha a janela com uma tecla só, uma vez em Terminal-Normal mode
    " ('q' é uma tecla livre lá, não é usada pra mais nada nesse modo)
    nnoremap <buffer><silent> q :bwipeout!<CR>
endfunction
