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

" F5-F8 (compilar/executar/testar) são definidos por linguagem,
" veja config/cpp.vim e config/java.vim (mapeamentos locais por filetype)

" Terminal
nnoremap <F9> :terminal<CR>

" Navegação entre janelas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Explorer (NERDTree)
nnoremap <F2> :NERDTreeToggle<CR>

" Autocomplete: liga/desliga rápido (ver config/coc.vim)
nnoremap <F4> :call ToggleAutocomplete()<CR>

" Busca
nnoremap <leader>h :nohlsearch<CR>

" Tab navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
