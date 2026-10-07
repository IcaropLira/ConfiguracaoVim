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


" ------------------------------------------------------------
" Comandos rápidos equivalentes aos F-keys.
" Vim exige que comandos definidos pelo usuário comecem com maiúscula;
" por isso os aliases são curtos e fáceis de decorar:
"   :Th :Pv :Nt :Ih :Ac :Cp :Rn :Br :Ti :Te :Pa :Mh :Of :Hd :Cs
" ------------------------------------------------------------
command! Th  call CycleTheme()
command! Pv  call PreviousTheme()
command! Nt  silent! NERDTreeToggle
command! Ih  call ToggleInlayHints()
command! Ac  call ToggleAutocomplete()
command! Cp  call IcaroDispatchFunctionKey(5)
command! Rn  call IcaroDispatchFunctionKey(6)
command! Br  call IcaroDispatchFunctionKey(7)
command! Ti  call IcaroDispatchFunctionKey(8)
command! Te  execute 'terminal'
command! Pa  call ToggleAutoPairs()
command! Mh  call ToggleMatchParen()
command! Of  call ToggleQuietMode()
command! Hd  call ToggleHeader()
command! Cs  call ToggleCheatsheet()

" F5-F8 (compilar/executar/testar) são definidos por linguagem,
" veja config/cpp.vim e config/java.vim (mapeamentos locais por filetype)

" Terminal
nnoremap <F9> :terminal<CR>

" Folha de atalhos (aperta de novo, ou qualquer tecla, pra fechar)
nnoremap <F12> :call ToggleCheatsheet()<CR>

" Navegação entre janelas
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Explorer (NERDTree)
nnoremap <F2> :NERDTreeToggle<CR>

" Autocomplete: liga/desliga rápido (ver config/coc.vim)
nnoremap <F4> :call ToggleAutocomplete()<CR>

" Só as dicas de parâmetro (texto fantasma tipo "nome: valor" ao
" chamar um método) — liga/desliga sem mexer no autocomplete inteiro
nnoremap <F3> :call ToggleInlayHints()<CR>

" PA: fechamento automático de parênteses/aspas/colchetes/<> e o
" popup de "ajuda de assinatura" — recurso separado do autocomplete,
" tem liga/desliga próprio (ver config/coc.vim)
nnoremap <F10> :call ToggleAutoPairs()<CR>

" Shift+F10: highlight do par de parênteses/colchetes/chaves
" correspondente ao cursor (:h matchparen) — outro recurso separado
" do PA/AC (ver config/appearance.vim)
nnoremap <S-F10> :call ToggleMatchParen()<CR>

" Shift+F12: mostra/esconde o header (winbar) no topo da janela
" (ver config/appearance.vim e o watchdog em config/credit.vim)
nnoremap <S-F11> :call ToggleQuietMode()<CR>
nnoremap <S-F12> :call ToggleHeader()<CR>
nnoremap <F24> :call ToggleHeader()<CR>

" Trocar de tema (mostra popup com o nome por ~1,6s) — ver config/themes.vim
nnoremap <F1> :call CycleTheme()<CR>
nnoremap <S-F1> :call PreviousTheme()<CR>

" ------------------------------------------------------------
" As mesmas teclas de função, mas funcionando também DENTRO do modo
" de inserção, sem te tirar dele. Isso é importante: como o F4 (por
" exemplo) não tinha mapeamento nenhum no insert mode antes, apertar
" ele no meio de uma digitação podia deixar o Vim confuso com a
" sequência de escape da tecla — daí parecia que "o teclado parou de
" funcionar" (backspace, parênteses etc.), quando na real o Vim tinha
" caído sozinho pro modo normal sem avisar. <C-o> executa UM comando
" de modo normal e volta pro insert automaticamente, sem esse risco.
" ------------------------------------------------------------
inoremap <silent> <F1> <C-o>:call CycleTheme()<CR>
inoremap <silent> <S-F1> <C-o>:call PreviousTheme()<CR>
inoremap <silent> <F2> <C-o>:NERDTreeToggle<CR>
inoremap <silent> <F3> <C-o>:call ToggleInlayHints()<CR>
inoremap <silent> <F4> <C-o>:call ToggleAutocomplete()<CR>
inoremap <silent> <F10> <C-o>:call ToggleAutoPairs()<CR>
inoremap <silent> <S-F10> <C-o>:call ToggleMatchParen()<CR>
inoremap <silent> <F9> <C-o>:terminal<CR>
inoremap <silent> <F12> <C-o>:call ToggleCheatsheet()<CR>
inoremap <silent> <S-F11> <C-o>:call ToggleQuietMode()<CR>
inoremap <silent> <S-F12> <C-o>:call ToggleHeader()<CR>
inoremap <silent> <F24> <C-o>:call ToggleHeader()<CR>

" ------------------------------------------------------------
" Shift+Backspace (ou Ctrl+Backspace, dependendo do terminal) apaga
" os dois lados de um parêntese/chave/colchete/aspas vazios de uma
" vez, se o cursor estiver bem no meio deles. Backspace normal
" continua apagando só um caractere, como sempre.
" ------------------------------------------------------------
function! s:SmartPairBackspace() abort
    let l:col = col('.')
    let l:line = getline('.')
    let l:before = l:col > 1 ? l:line[l:col - 2] : ''
    let l:after = l:line[l:col - 1]
    let l:pairs = {'(': ')', '[': ']', '{': '}', '"': '"', "'": "'", '`': '`'}
    if has_key(l:pairs, l:before) && l:after ==# l:pairs[l:before]
        return "\<BS>\<Del>"
    endif
    return "\<BS>"
endfunction
inoremap <silent><expr> <S-BS> <SID>SmartPairBackspace()
inoremap <silent><expr> <C-BS> <SID>SmartPairBackspace()

" Busca
nnoremap <leader>h :nohlsearch<CR>

" Tab navigation
nnoremap <Tab> :bnext<CR>
nnoremap <S-Tab> :bprevious<CR>
