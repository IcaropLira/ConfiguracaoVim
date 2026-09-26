if exists('g:loaded_my_python')
    finish
endif
let g:loaded_my_python = 1

" ============================================================
" Python
" ============================================================
"
" Python é interpretado, não tem etapa de compilação — por isso só
" existe UM atalho aqui (F7): salva o arquivo, abre o terminal (igual
" F5-F8 de C++/Java, veja config/runner.vim) e executa com
" python3 (cai pra "python" se python3 não existir no PATH).
"
" F5/F6/F8 (compilar / rodar sem salvar de novo / testar com
" input.txt) e template automático de arquivo novo não foram pedidos
" ainda pra Python, então não existem por enquanto.

function! RunPython() abort
    write
    let l:file = expand('%:p')
    let l:py = executable('python3') ? 'python3' : 'python'
    let l:cmd = l:py . ' ' . shellescape(l:file)
    call IcaroRunInTerminal(l:cmd)
endfunction

" Atalho local só dentro de arquivos .py (não conflita com C++/Java)
augroup python_keymaps
    autocmd!
    autocmd FileType python nnoremap <buffer> <F7> :call RunPython()<CR>
    " Mesma tecla, funcionando também dentro do modo de inserção (sem
    " te tirar dele) — mesmo motivo do C++/Java, veja config/cpp.vim
    autocmd FileType python inoremap <silent><buffer> <F7> <C-o>:call RunPython()<CR>
augroup END
