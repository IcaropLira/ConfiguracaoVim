if exists('g:loaded_my_keymaps')
    finish
endif
let g:loaded_my_keymaps = 1

" ============================================================
" Atalhos
" ============================================================

" Salvar
nnoremap <C-s> :write<CR>
inoremap <C-s> <Esc>:write<CR>a

" C++ / Codeforces
nnoremap <F5> :call CompileCpp()<CR>
nnoremap <F6> :call RunCpp()<CR>
nnoremap <F7> :call BuildRunCpp()<CR>
nnoremap <F8> :call TestCpp()<CR>

" Terminal
nnoremap <F9> :terminal<CR>

" Navegação entre janelas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Explorer
nnoremap <F2> :Explore<CR>

" Busca
nnoremap <leader>h :nohlsearch<CR>

" Tab navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
