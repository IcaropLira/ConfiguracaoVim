if exists('g:loaded_my_java')
    finish
endif
let g:loaded_my_java = 1

" ============================================================
" Java
" ============================================================
"
" Regra de template:
"   NomeQualquer.java      -> template "IDE" (public class com o nome do arquivo)
"   NomeQualquer_cp.java   -> template de programação competitiva (classe Main, IO rápida)
"
" O sufixo pode ser trocado abaixo.
let g:java_cp_suffix = '_cp'

function! s:IsCpFile(basename) abort
    let l:suffix = g:java_cp_suffix
    let l:len = len(l:suffix)
    return a:basename[-l:len :] ==? l:suffix
endfunction

function! InsertJavaTemplate() abort
    let l:basename = expand('%:t:r')

    if s:IsCpFile(l:basename)
        let l:template = expand('~/.vim/templates/java_cp.java')
        if filereadable(l:template)
            execute '0r ' . l:template
        endif
    else
        let l:template = expand('~/.vim/templates/java_main.java')
        if filereadable(l:template)
            execute '0r ' . l:template
            " Substitui o placeholder pelo nome real da classe (igual ao arquivo)
            silent! execute '%s/__CLASSNAME__/' . escape(l:basename, '/&') . '/g'
        endif
    endif

    " remove a linha em branco deixada pelo :r no topo
    silent! execute '$'
    normal! gg
endfunction

augroup java_template
    autocmd!
    autocmd BufNewFile *.java call InsertJavaTemplate()
augroup END

" Nome da classe "pública" a executar
function! s:JavaMainClass() abort
    let l:basename = expand('%:t:r')
    if s:IsCpFile(l:basename)
        return 'Main'
    endif
    return l:basename
endfunction

function! CompileJava() abort
    write
    let l:file = expand('%:p')
    let l:dir = expand('%:p:h')
    let l:cmd = 'javac -d ' . shellescape(l:dir) . ' ' . shellescape(l:file)
    call IcaroRunInTerminal(l:cmd)
endfunction

function! RunJava() abort
    write
    let l:dir = expand('%:p:h')
    let l:class = s:JavaMainClass()
    let l:cmd = 'java -cp ' . shellescape(l:dir) . ' ' . l:class
    call IcaroRunInTerminal(l:cmd)
endfunction

function! BuildRunJava() abort
    write
    let l:file = expand('%:p')
    let l:dir = expand('%:p:h')
    let l:class = s:JavaMainClass()
    let l:cmd = 'javac -d ' . shellescape(l:dir) . ' ' . shellescape(l:file) .
                \ ' && java -cp ' . shellescape(l:dir) . ' ' . l:class
    call IcaroRunInTerminal(l:cmd)
endfunction

function! TestJava() abort
    write

    if !filereadable('input.txt')
        echoerr 'input.txt não encontrado'
        return
    endif

    let l:file = expand('%:p')
    let l:dir = expand('%:p:h')
    let l:class = s:JavaMainClass()
    let l:cmd = 'javac -d ' . shellescape(l:dir) . ' ' . shellescape(l:file) .
                \ ' && java -cp ' . shellescape(l:dir) . ' ' . l:class . ' < input.txt'
    call IcaroRunInTerminal(l:cmd)
endfunction

" Atalhos locais só dentro de arquivos .java (não conflita com C++)
augroup java_keymaps
    autocmd!
    autocmd FileType java nnoremap <buffer> <F5> :call CompileJava()<CR>
    autocmd FileType java nnoremap <buffer> <F6> :call RunJava()<CR>
    autocmd FileType java nnoremap <buffer> <F7> :call BuildRunJava()<CR>
    autocmd FileType java nnoremap <buffer> <F8> :call TestJava()<CR>
    autocmd FileType java inoremap <silent><buffer> <F5> <C-o>:call CompileJava()<CR>
    autocmd FileType java inoremap <silent><buffer> <F6> <C-o>:call RunJava()<CR>
    autocmd FileType java inoremap <silent><buffer> <F7> <C-o>:call BuildRunJava()<CR>
    autocmd FileType java inoremap <silent><buffer> <F8> <C-o>:call TestJava()<CR>
augroup END
