if exists('g:loaded_my_cpp')
    finish
endif
let g:loaded_my_cpp = 1

augroup cpp_template
    autocmd!
    autocmd BufNewFile *.cpp execute '0r ' . expand('~/.vim/templates/cpp.cpp')
augroup END

function! CompileCpp() abort
    write
    let l:file = expand('%:p')
    let l:output = expand('%:p:r')
    execute '!g++ -std=c++17 -O2 -Wall -Wextra ' .
                \ shellescape(l:file) . ' -o ' . shellescape(l:output)
endfunction

function! RunCpp() abort
    write
    let l:output = expand('%:p:r')
    execute '!'.shellescape(l:output)
endfunction

function! BuildRunCpp() abort
    write
    let l:file = expand('%:p')
    let l:output = expand('%:p:r')
    execute '!g++ -std=c++17 -O2 -Wall -Wextra ' .
                \ shellescape(l:file) . ' -o ' . shellescape(l:output) .
                \ ' && ' . shellescape(l:output)
endfunction

function! TestCpp() abort
    write
    if !filereadable('input.txt')
        echoerr 'input.txt não encontrado'
        return
    endif
    let l:file = expand('%:p')
    let l:output = expand('%:p:r')
    execute '!g++ -std=c++17 -O2 -Wall -Wextra ' .
                \ shellescape(l:file) . ' -o ' . shellescape(l:output) .
                \ ' && ' . shellescape(l:output) . ' < input.txt'
endfunction
