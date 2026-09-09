if exists('g:loaded_my_keymaps')
    finish
endif
let g:loaded_my_keymaps = 1

" Save
nnoremap <C-s> :write<CR>
inoremap <C-s> <Esc>:write<CR>a

" Search
nnoremap <C-h> :nohlsearch<CR>

" C++ workflow
nnoremap <F5> :call CompileCpp()<CR>
nnoremap <F6> :call RunCpp()<CR>
nnoremap <F7> :call BuildRunCpp()<CR>
nnoremap <F8> :call TestCpp()<CR>

" Terminal
nnoremap <F9> :terminal<CR>

" Better window navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
