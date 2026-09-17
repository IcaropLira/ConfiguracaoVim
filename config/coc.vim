if exists('g:loaded_my_coc')
    finish
endif
let g:loaded_my_coc = 1

" ============================================================
" Autocomplete semântico — coc.nvim
" ============================================================
"
" Motores:
"   C/C++ -> clangd via coc-clangd
"   Java  -> Eclipse JDT Language Server via coc-java
"   Snippets -> coc-snippets
"   Auto-fechamento -> coc-pairs
"
" O ponto importante é que o autocomplete NÃO é só textual:
" o LSP analisa o código, descobre o tipo da variável e fornece
" membros, métodos, construtores, parâmetros, definições etc.

if !exists('g:coc_config_home')
    let g:coc_config_home = expand('~/.vim')
endif

if !isdirectory(expand('~/.vim/pack/plugins/opt/coc.nvim'))
    finish
endif

" Extensões instaladas automaticamente pelo install.sh / coc.nvim.
let g:coc_global_extensions = ['coc-clangd', 'coc-java', 'coc-snippets', 'coc-pairs']

set updatetime=300
set shortmess+=c
set signcolumn=yes
set cmdheight=1

" ------------------------------------------------------------
" Completion popup
" ------------------------------------------------------------
inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1) :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"
inoremap <silent><expr> <C-space> coc#refresh()

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Snippet placeholders: Ctrl-J/K navega pelos campos.
imap <silent> <C-j> <Plug>(coc-snippets-expand-jump)
imap <silent> <C-k> <Plug>(coc-snippets-jump-prev)

" ------------------------------------------------------------
" LSP navigation
" ------------------------------------------------------------
nnoremap <silent> gd <Plug>(coc-definition)
nnoremap <silent> gy <Plug>(coc-type-definition)
nnoremap <silent> gi <Plug>(coc-implementation)
nnoremap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation() abort
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        execute '!' . &keywordprg . ' ' . expand('<cword>')
    endif
endfunction

" Assinatura de método: aparece ao digitar '('.
function! ShowSignatureHelp() abort
    call CocActionAsync('showSignatureHelp')
endfunction
nnoremap <silent> <leader>s :call ShowSignatureHelp()<CR>
inoremap <silent> <C-y> <C-o>:call ShowSignatureHelp()<CR>

" Refatoração / imports.
nnoremap <leader>rn <Plug>(coc-rename)
nnoremap <leader>oi :call CocActionAsync('runCommand', 'java.action.organizeImports')<CR>

" ------------------------------------------------------------
" Toggle autocomplete (F4)
" ------------------------------------------------------------
function! ToggleAutocomplete() abort
    if g:my_autocomplete_enabled
        let g:my_autocomplete_enabled = 0
        silent! CocDisable
        echo 'Autocomplete: DESLIGADO'
    else
        let g:my_autocomplete_enabled = 1
        silent! CocEnable
        echo 'Autocomplete: LIGADO'
    endif
    redrawstatus!
endfunction

" Diagnóstico rápido: :LspHealth
command! LspHealth execute 'CocInfo'

" Java diagnostics
command! JavaLog execute 'CocCommand java.open.serverLog'
command! JavaClientLog execute 'CocCommand java.open.clientLog'
command! JavaLogs execute 'CocCommand java.open.logs'
command! JavaCleanWorkspace execute 'CocCommand java.clean.workspace'
command! JavaReloadProjects execute 'CocCommand java.projectConfiguration.update'

" For standalone Java files, coc-java requires the file to exist on disk.
" The Java template handler creates new Java files immediately. For an
" existing buffer, saving once then reloading makes the LSP attach reliably.
function! ReloadJavaAfterSave(timer) abort
    if &filetype ==# 'java' && !&modified && bufname('%') !=# '' && filereadable(expand('%:p'))
        silent! edit
    endif
endfunction

augroup java_coc_attach
    autocmd!
    autocmd BufWritePost *.java call timer_start(150, 'ReloadJavaAfterSave')
augroup END
