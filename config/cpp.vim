if exists('g:loaded_my_cpp')
    finish
endif
let g:loaded_my_cpp = 1

" ============================================================
" C++
" ============================================================

augroup cpp_template
    autocmd!
    autocmd BufNewFile *.cpp execute '0r ' . expand('~/.vim/templates/cpp.cpp')
augroup END

function! CompileCpp() abort
    write
    let l:file = expand('%:p')
    let l:output = expand('%:p:r')
    let l:cmd = 'g++ -std=c++17 -O2 -Wall -Wextra ' .
                \ shellescape(l:file) . ' -o ' . shellescape(l:output)
    call IcaroRunInTerminal(l:cmd)
endfunction

function! RunCpp() abort
    write
    let l:output = expand('%:p:r')

    if !filereadable(l:output)
        echoerr 'Executável não encontrado. Use F5 ou F7 primeiro.'
        return
    endif

    let l:cmd = shellescape(l:output)
    call IcaroRunInTerminal(l:cmd)
endfunction

function! BuildRunCpp() abort
    write
    let l:file = expand('%:p')
    let l:output = expand('%:p:r')
    let l:cmd = 'g++ -std=c++17 -O2 -Wall -Wextra ' .
                \ shellescape(l:file) . ' -o ' . shellescape(l:output) .
                \ ' && ' . shellescape(l:output)
    call IcaroRunInTerminal(l:cmd)
endfunction

function! TestCpp() abort
    write

    if !filereadable('input.txt')
        echoerr 'input.txt não encontrado'
        return
    endif

    let l:file = expand('%:p')
    let l:output = expand('%:p:r')
    let l:cmd = 'g++ -std=c++17 -O2 -Wall -Wextra ' .
                \ shellescape(l:file) . ' -o ' . shellescape(l:output) .
                \ ' && ' . shellescape(l:output) . ' < input.txt'
    call IcaroRunInTerminal(l:cmd)
endfunction

" Atalhos locais só dentro de arquivos .cpp (não conflita com Java)
augroup cpp_keymaps
    autocmd!
    autocmd FileType cpp nnoremap <buffer> <F5> :call CompileCpp()<CR>
    autocmd FileType cpp nnoremap <buffer> <F6> :call RunCpp()<CR>
    autocmd FileType cpp nnoremap <buffer> <F7> :call BuildRunCpp()<CR>
    autocmd FileType cpp nnoremap <buffer> <F8> :call TestCpp()<CR>
    " Mesmas teclas, funcionando também dentro do modo de inserção
    " (sem te tirar dele) — evita o Vim se confundir com a sequência
    " de escape da tecla no meio de uma digitação
    autocmd FileType cpp inoremap <silent><buffer> <F5> <C-o>:call CompileCpp()<CR>
    autocmd FileType cpp inoremap <silent><buffer> <F6> <C-o>:call RunCpp()<CR>
    autocmd FileType cpp inoremap <silent><buffer> <F7> <C-o>:call BuildRunCpp()<CR>
    autocmd FileType cpp inoremap <silent><buffer> <F8> <C-o>:call TestCpp()<CR>
augroup END
