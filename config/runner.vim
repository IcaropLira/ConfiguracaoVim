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

    " Antes o terminal fechava sozinho ('term_finish': 'close') assim
    " que o comando terminava — desse deu certo, deu erro, colou
    " entrada, tanto faz: a janela sumia rápido demais pra dar tempo
    " de ler a saída (ou o erro de compilação). Agora, depois do
    " comando terminar, a gente mostra o código de saída e espera
    " você apertar ENTER pra fechar. Só nesse momento o shell de
    " dentro do terminal termina de verdade, e aí sim o
    " 'term_finish': 'close' entra em ação e fecha a janela sozinha.
    let l:wrapped = a:cmd .
                \ '; __status=$?; echo;' .
                \ ' if [ "$__status" -eq 0 ]; then' .
                \ '   echo "[Concluído — pressione ENTER para fechar]";' .
                \ ' else' .
                \ '   echo "[Encerrou com código $__status — pressione ENTER para fechar]";' .
                \ ' fi;' .
                \ ' read -r _dummy'

    let l:shell = executable('bash') ? 'bash' : 'sh'
    let g:icaro_runner_bufnr = term_start([l:shell, '-c', l:wrapped], {
                \ 'curwin': 1,
                \ 'term_kill': 'kill',
                \ 'term_name': 'output',
                \ 'term_finish': 'close',
                \ })
    setlocal nonumber norelativenumber signcolumn=no
endfunction
