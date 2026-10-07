scriptencoding utf-8
if exists('g:loaded_my_coc')
    finish
endif
let g:loaded_my_coc = 1

" ============================================================
" Autocomplete (coc.nvim)
" ============================================================
"
" REQUISITOS:
"   - Node.js instalado (node --version)
"   - JDK instalado (para o coc-java funcionar em arquivos .java)
"   - Extensões instaladas automaticamente na primeira vez que o vim
"     abrir: coc-java (.java), coc-clangd (.cpp) e coc-pyright (.py)
"     — dá pra forçar manualmente com :CocInstall coc-java coc-clangd
"     coc-pyright
"
" Se o coc.nvim não estiver instalado, este arquivo não faz nada
" (o resto da configuração continua funcionando normalmente).

if !exists('g:coc_config_home')
    let g:coc_config_home = expand('~/.vim')
endif

if !isdirectory(expand('~/.vim/pack/plugins/opt/coc.nvim'))
    " Sem o coc.nvim instalado, F4/F3/F10 não fazem nada e não quebram
    function! ToggleAutocomplete() abort
        echo 'coc.nvim não está instalado (rode install.sh de novo)'
    endfunction
    function! ToggleInlayHints() abort
        echo 'coc.nvim não está instalado (rode install.sh de novo)'
    endfunction
    function! ToggleAutoPairs() abort
        echo 'coc.nvim não está instalado (rode install.sh de novo)'
    endfunction
    function! ToggleQuietMode() abort
        let g:icaro_quiet_mode = !get(g:, 'icaro_quiet_mode', 0)
        if g:icaro_quiet_mode
            silent! NoMatchParen
            for l:id in popup_list()
                silent! call popup_close(l:id)
            endfor
            echo 'Modo silencioso: popups e marcacoes DESLIGADOS (coc.nvim não está instalado)'
        else
            silent! DoMatchParen
            echo 'Modo silencioso: DESLIGADO'
        endif
        redraw!
    endfunction
    finish
endif

" Instala/atualiza sozinho as extensões de C++, Java e Python na
" primeira vez que o vim abrir (não depende do install.sh terminar a
" tempo). Pode demorar um pouco na primeira execução, especialmente a
" de Java, pois baixa o Eclipse JDT Language Server.
let g:coc_global_extensions = ['coc-java', 'coc-clangd', 'coc-pyright']

" Menor tempo de atualização = sugestões mais rápidas
set updatetime=300
set shortmess+=c
set signcolumn=yes
set cmdheight=1

function! CheckBackspace() abort
    let l:col = col('.') - 1
    return !l:col || getline('.')[l:col - 1] =~# '\s'
endfunction

" ------------------------------------------------------------
" Autocomplete por linguagem: diz se o buffer ATUAL deve se comportar
" como "autocomplete ligado" (C++/Java/Python, cada um com seu próprio
" estado em g:icaro_ac_state, lido/gravado em ~/.vim/config e definido
" no topo do ~/.vimrc). Filetypes fora dessa lista não têm toggle
" individual e continuam com o autocomplete sempre disponível.
" ------------------------------------------------------------
function! IcaroAutocompleteEnabled() abort
    let l:ft = &filetype
    if index(g:icaro_ac_languages, l:ft) >= 0
        return get(g:icaro_ac_state, l:ft, 1)
    endif
    return 1
endfunction

" Aplica o estado da linguagem do buffer atual no coc.nvim. Usamos
" b:coc_suggest_disable (opção nativa do coc.nvim, por buffer) em vez
" de CocEnable/CocDisable: assim só o popup de sugestão é afetado,
" sem desligar diagnóstico, "ir para definição", hover, etc., e sem
" derrubar o processo do coc.nvim — que continua rodando normalmente
" pras outras linguagens que estiverem ligadas.
function! s:ApplyAutocompleteStateToBuffer() abort
    let b:coc_suggest_disable = IcaroAutocompleteEnabled() ? 0 : 1
endfunction

augroup icaro_coc_per_language_state
    autocmd!
    autocmd FileType * call s:ApplyAutocompleteStateToBuffer()
    autocmd BufEnter * call s:ApplyAutocompleteStateToBuffer()
augroup END

" ------------------------------------------------------------
" PA (Pareamento Automático): fechar sozinho aspas/parênteses/
" colchetes/chaves/`<>` ao digitar o caractere de abertura, e o popup
" de "ajuda de assinatura" (parâmetros da função) que aparece sozinho
" ao digitar "(" — os dois vêm de fora do nosso mapeamento de teclas
" (o fechamento é da extensão coc-pairs, se estiver instalada; o
" popup é o "signature.enable" do próprio coc.nvim) e por isso F4
" (autocomplete) não tinha efeito nenhum sobre eles: são recursos
" diferentes, com liga/desliga próprio, F10.
" ------------------------------------------------------------

" Mesma lista padrão de caracteres que a extensão coc-pairs habilita
" (:h coc-pairs, opção 'pairs.enableCharacters') — desligar PA
" desabilita o fechamento automático de todos eles.
let g:icaro_pairs_characters = ['(', '[', '{', '<', "'", '"', '`', '【', '「', '《', '『']

function! s:ApplyPairsStateToBuffer() abort
    let b:coc_pairs_disabled = g:icaro_pairs_enabled ? [] : g:icaro_pairs_characters
endfunction

augroup icaro_coc_pairs_state
    autocmd!
    autocmd FileType * call s:ApplyPairsStateToBuffer()
    autocmd BufEnter * call s:ApplyPairsStateToBuffer()
augroup END

function! ToggleAutoPairs() abort
    let g:icaro_pairs_enabled = !g:icaro_pairs_enabled

    " Aplica na hora em todos os buffers já abertos, não só no atual
    for l:bufnr in range(1, bufnr('$'))
        if bufexists(l:bufnr)
            call setbufvar(l:bufnr, 'coc_pairs_disabled',
                        \ g:icaro_pairs_enabled ? [] : g:icaro_pairs_characters)
        endif
    endfor

    " O popup de "ajuda de assinatura" é um recurso separado do
    " coc.nvim (não da extensão coc-pairs) — desligamos ele junto,
    " já que o pedido original juntava os dois ("fechando parênteses
    " ... e aparecendo alguns pop-ups"). updateConfig muda a
    " configuração em tempo real, sem precisar reiniciar o coc.
    try
        call CocAction('updateConfig', 'signature.enable', g:icaro_pairs_enabled ? v:true : v:false)
    catch /.*/
        " coc.nvim ainda não terminou de subir, ou não tem essa
        " configuração nessa versão — sem problema, só o fechamento
        " de pares já foi desligado/ligado acima
    endtry

    if g:icaro_pairs_enabled
        echo 'Fechamento automático de parênteses/aspas/colchetes e popup de assinatura: LIGADO'
    else
        echo 'Fechamento automático de parênteses/aspas/colchetes e popup de assinatura: DESLIGADO'
    endif

    try
        call writefile([g:icaro_pairs_enabled ? '1' : '0'], g:icaro_pairs_state_file)
    catch /.*/
    endtry
    redrawstatus!
endfunction

" ------------------------------------------------------------
" Teclas básicas de edição
" ------------------------------------------------------------
"
" O popup do coc.nvim pode capturar algumas teclas enquanto está
" visível. A regra aqui é simples:
"
"   popup aberto  -> o coc controla apenas a navegação/aceitação;
"   popup fechado -> Vim controla normalmente a edição.
"
" Isso evita o problema em que, depois de sair do autocomplete,
" Backspace, parênteses, chaves e colchetes deixam de funcionar.
" ------------------------------------------------------------
function! CocBackspace() abort
    if coc#pum#visible()
        call coc#pum#cancel()
    endif
    return "\<BS>"
endfunction

inoremap <silent><expr> <BS> CocBackspace()

function! CocEscape() abort
    if coc#pum#visible()
        call coc#pum#cancel()
    endif
    return "\<Esc>"
endfunction

inoremap <silent><expr> <Esc> CocEscape()

" Essas teclas não pertencem ao autocomplete. Deixamos explícito que
" continuam sendo inserção normal do Vim, mesmo quando o coc estiver
" instalado ou quando o autocomplete estiver desligado.
inoremap <silent> ( (
inoremap <silent> ) )
inoremap <silent> [ [
inoremap <silent> ] ]
inoremap <silent> { {
inoremap <silent> } }

" ------------------------------------------------------------
" Tab / Shift-Tab para navegar nas sugestões
" ------------------------------------------------------------
inoremap <silent><expr> <TAB>
            \ !IcaroAutocompleteEnabled() ? "\<Tab>" :
            \ coc#pum#visible() ? coc#pum#next(1) :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
inoremap <silent><expr> <S-TAB>
            \ !IcaroAutocompleteEnabled() ? "\<C-h>" :
            \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" ------------------------------------------------------------
" Enter
" ------------------------------------------------------------
inoremap <silent><expr> <CR>
            \ !IcaroAutocompleteEnabled() ? "\<CR>" :
            \ coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

" Ctrl+Space força a sugestão manualmente.
inoremap <silent><expr> <C-space>
            \ IcaroAutocompleteEnabled() ? coc#refresh() : ''

" Navega entre os "buracos" (parâmetros) de um método depois de
" aceitar a sugestão — exatamente como o Eclipse/VSCode fazem quando
" você aceita um `println(` e ele já deixa o cursor no primeiro
" argumento pronto pra editar.
imap <silent> <C-j> <Plug>(coc-snippet-next)
imap <silent> <C-k> <Plug>(coc-snippet-prev)

" Ir para definição / referências / documentação (útil pra quem não
" domina a sintaxe de Java ainda)
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation() abort
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . ' ' . expand('<cword>')
    endif
endfunction

" Assinatura do método (parâmetros) — normalmente aparece sozinha ao
" digitar "(" depois de um nome de método, mas dá pra forçar também
function! ShowSignatureHelp() abort
    call CocActionAsync('showSignatureHelp')
endfunction
nnoremap <silent> <leader>s :call ShowSignatureHelp()<CR>
inoremap <silent> <C-y> <Esc>:call ShowSignatureHelp()<CR>a

" Renomear símbolo
nnoremap <leader>rn <Plug>(coc-rename)

" Organizar imports (equivalente ao Ctrl+Shift+O do Eclipse/VSCode)
nnoremap <leader>oi :call CocActionAsync('runCommand', 'java.action.organizeImports')<CR>


" ------------------------------------------------------------
" MODO SILENCIOSO — desliga de uma vez tudo que o autocomplete/LSP
" pode colocar por cima ou ao redor do código.
"
" S-F11 / :Off = DESLIGA:
"   - popup de sugestões
"   - popup de assinatura
"   - hover/floating windows já abertas
"   - inlay hints / texto fantasma
"   - pares automáticos
"   - diagnósticos visuais (sinais, highlight e virtual text)
"   - highlight automático de parênteses
"
" É um toggle: apertar S-F11 ou :Off de novo restaura os estados que
" estavam configurados antes do modo silencioso.
" ------------------------------------------------------------
function! ToggleQuietMode() abort
    let g:icaro_quiet_mode = !get(g:, 'icaro_quiet_mode', 0)

    if g:icaro_quiet_mode
        " Guarda os estados atuais para restaurar exatamente como estavam.
        let g:icaro_quiet_saved_inlay = get(g:, 'my_inlay_hints_enabled', 1)
        let g:icaro_quiet_saved_pairs = get(g:, 'icaro_pairs_enabled', 1)
        let g:icaro_quiet_saved_matchparen = get(g:, 'icaro_matchparen_enabled', 1)
        let g:icaro_quiet_saved_ac = deepcopy(get(g:, 'icaro_ac_state', {}))

        " Fecha imediatamente qualquer popup aberto.
        silent! call coc#pum#cancel()
        silent! call coc#pum#close()
        silent! call coc#float#close_all()

        " Impede novos popups de sugestão em todos os buffers.
        for l:bufnr in range(1, bufnr('$'))
            if bufexists(l:bufnr)
                call setbufvar(l:bufnr, 'coc_suggest_disable', 1)
                call setbufvar(l:bufnr, 'coc_pairs_disabled', g:icaro_pairs_characters)
            endif
        endfor

        " Desliga os recursos visuais do coc/LSP.
        try
            call CocAction('updateConfig', 'suggest.enable', v:false)
            call CocAction('updateConfig', 'signature.enable', v:false)
            call CocAction('updateConfig', 'inlayHint.enable', v:false)
            call CocAction('updateConfig', 'java.inlayHints.parameterNames.enabled', 'none')
            call CocAction('updateConfig', 'diagnostic.enable', v:false)
            call CocAction('updateConfig', 'diagnostic.virtualText', v:false)
            call CocAction('updateConfig', 'diagnostic.signs', v:false)
            call CocAction('updateConfig', 'diagnostic.highlight', v:false)
        catch /.*/
        endtry

        " Limpa imediatamente inlay/diagnósticos que já estejam na tela.
        silent! call CocActionAsync('runCommand', 'document.disableInlayHint', bufnr('%'))
        silent! call CocActionAsync('diagnostic.clear')

        " Desliga também o matchparen, que é a marcação visual nativa
        " normalmente confundida com as marcações do autocomplete.
        silent! NoMatchParen

        echo 'Modo silencioso: POPUPS e MARCACOES do autocomplete/LSP DESLIGADOS'
    else
        " Restaura os estados anteriores.
        if exists('g:icaro_quiet_saved_ac')
            let g:icaro_ac_state = deepcopy(g:icaro_quiet_saved_ac)
        endif
        let g:my_inlay_hints_enabled = get(g:, 'icaro_quiet_saved_inlay', 1)
        let g:icaro_pairs_enabled = get(g:, 'icaro_quiet_saved_pairs', 1)
        let g:icaro_matchparen_enabled = get(g:, 'icaro_quiet_saved_matchparen', 1)

        try
            call CocAction('updateConfig', 'suggest.enable', v:true)
            call CocAction('updateConfig', 'signature.enable', g:icaro_pairs_enabled ? v:true : v:false)
            call CocAction('updateConfig', 'inlayHint.enable', g:my_inlay_hints_enabled ? v:true : v:false)
            call CocAction('updateConfig', 'java.inlayHints.parameterNames.enabled', g:my_inlay_hints_enabled ? 'all' : 'none')
            call CocAction('updateConfig', 'diagnostic.enable', v:true)
            call CocAction('updateConfig', 'diagnostic.virtualText', v:true)
            call CocAction('updateConfig', 'diagnostic.signs', v:true)
            call CocAction('updateConfig', 'diagnostic.highlight', v:true)
        catch /.*/
        endtry

        for l:bufnr in range(1, bufnr('$'))
            if bufexists(l:bufnr)
                let l:ft = getbufvar(l:bufnr, '&filetype')
                let l:ac = get(g:icaro_ac_state, l:ft, 1)
                call setbufvar(l:bufnr, 'coc_suggest_disable', l:ac ? 0 : 1)
                call setbufvar(l:bufnr, 'coc_pairs_disabled',
                            \ g:icaro_pairs_enabled ? [] : g:icaro_pairs_characters)
            endif
        endfor

        if g:icaro_matchparen_enabled
            silent! DoMatchParen
        endif

        echo 'Modo silencioso: recursos visuais RESTAURADOS'
    endif

    redraw!
endfunction

" ------------------------------------------------------------
" Grava o estado (0/1) num arquivinho, pra sobreviver a fechar/abrir
" o vim. A leitura de volta acontece bem cedo no ~/.vimrc.
" ------------------------------------------------------------
function! s:PersistState(file, value) abort
    try
        call writefile([a:value], a:file)
    catch /.*/
        " sem permissão de escrita, sem problema, só não persiste
    endtry
endfunction

" ------------------------------------------------------------
" Toggle: ligar/desligar o autocomplete (F4) — POR LINGUAGEM.
"
" F4 só mexe na linguagem do buffer onde você apertou: se você está
" num .cpp, só o C++ liga/desliga; Java e Python ficam exatamente como
" estavam. Persistente: o que você deixar aqui continua valendo da
" próxima vez que abrir o vim, até você apertar F4 de novo NAQUELA
" linguagem.
"
" IMPORTANTE: o toggle não mata o processo RPC do coc.nvim nem usa
" CocDisable/CocEnable (isso desligaria TODAS as linguagens de uma
" vez). Em vez disso, usamos b:coc_suggest_disable por buffer — o
" popup de sugestão para de aparecer só onde deve, e diagnóstico/"ir
" para definição"/hover continuam funcionando normalmente em todas as
" linguagens, ligadas ou não.
" ------------------------------------------------------------
function! ToggleAutocomplete() abort
    let l:ft = &filetype
    if index(g:icaro_ac_languages, l:ft) < 0
        echo 'F4 não tem toggle individual pra este filetype ("' . l:ft .
                    \ '"). Linguagens com toggle: ' . join(g:icaro_ac_languages, ', ')
        return
    endif

    let l:new_state = get(g:icaro_ac_state, l:ft, 1) ? 0 : 1
    let g:icaro_ac_state[l:ft] = l:new_state

    silent! call coc#pum#cancel()

    " Aplica na hora em TODOS os buffers já abertos dessa mesma
    " linguagem (não só no atual), pra não precisar trocar de janela
    " pra "ativar" a mudança.
    for l:bufnr in range(1, bufnr('$'))
        if bufexists(l:bufnr) && getbufvar(l:bufnr, '&filetype') ==# l:ft
            call setbufvar(l:bufnr, 'coc_suggest_disable', l:new_state ? 0 : 1)
        endif
    endfor

    if l:new_state
        echo 'Autocomplete (' . l:ft . '): LIGADO'
    else
        echo 'Autocomplete (' . l:ft .
                    \ '): DESLIGADO (continua desligado só para ' . l:ft .
                    \ ' até você apertar F4 de novo aqui — as outras linguagens não mudam)'
    endif

    call s:PersistAutocompleteState()
    redrawstatus!
endfunction

function! s:PersistAutocompleteState() abort
    let l:lines = []
    for l:lang in g:icaro_ac_languages
        call add(l:lines, l:lang . ' ' . get(g:icaro_ac_state, l:lang, 1))
    endfor
    try
        call writefile(l:lines, g:icaro_ac_state_file)
    catch /.*/
        " sem permissão de escrita, sem problema, só não persiste
    endtry
endfunction

" ------------------------------------------------------------
" Toggle: só as dicas de parâmetro dentro do código (aquele texto
" fantasma tipo "nome: valor" ao chamar um método/função) — F3.
" Usa o interruptor GERAL do coc.nvim (inlayHint.enable), que vale
" pra qualquer linguagem com LSP (Java, C++ com clangd, etc.), mais
" o comando nativo document.*InlayHint pra atualizar a tela na hora,
" sem precisar recarregar o arquivo. Também persistente, igual o F4.
" ------------------------------------------------------------
function! ToggleInlayHints() abort
    if g:my_inlay_hints_enabled
        let g:my_inlay_hints_enabled = 0
        call CocActionAsync('updateConfig', 'inlayHint.enable', v:false)
        call CocActionAsync('updateConfig', 'java.inlayHints.parameterNames.enabled', 'none')
        silent! call CocActionAsync('runCommand', 'document.disableInlayHint', bufnr('%'))
        echo 'Dicas de parâmetro (inline): DESLIGADAS'
    else
        let g:my_inlay_hints_enabled = 1
        call CocActionAsync('updateConfig', 'inlayHint.enable', v:true)
        call CocActionAsync('updateConfig', 'java.inlayHints.parameterNames.enabled', 'all')
        silent! call CocActionAsync('runCommand', 'document.enableInlayHint', bufnr('%'))
        echo 'Dicas de parâmetro (inline): LIGADAS'
    endif
    call s:PersistState(g:icaro_inlay_state_file, g:my_inlay_hints_enabled)
endfunction

" Aplica o estado salvo assim que o coc terminar de inicializar
" (antes disso, CocActionAsync ainda não tem efeito)
function! s:ApplyPersistedInlayState() abort
    if !g:my_inlay_hints_enabled
        call CocActionAsync('updateConfig', 'inlayHint.enable', v:false)
        call CocActionAsync('updateConfig', 'java.inlayHints.parameterNames.enabled', 'none')
    endif
endfunction
augroup icaro_coc_persisted_state
    autocmd!
    autocmd User CocNvimInit call s:ApplyPersistedInlayState()
augroup END

" Texto usado na statusline / airline / winbar: AutocompleteStatus()
" já é definida no topo do ~/.vimrc (precisa existir antes do airline
" carregar), aqui só reaproveitamos.

" ------------------------------------------------------------
" coc-java: aponta o JDK/JRE a usar, se necessário customizar,
" edite ~/.vim/coc-settings.json (abra com :CocConfig)
" ------------------------------------------------------------
