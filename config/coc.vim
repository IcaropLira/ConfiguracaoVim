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
"   - Extensão coc-java instalada: dentro do vim, rode :CocInstall coc-java
"
" Se o coc.nvim não estiver instalado, este arquivo não faz nada
" (o resto da configuração continua funcionando normalmente).

if !exists('g:coc_config_home')
    let g:coc_config_home = expand('~/.vim')
endif

if !isdirectory(expand('~/.vim/pack/plugins/opt/coc.nvim'))
    finish
endif

" Estado global do toggle (começa ligado)
let g:my_autocomplete_enabled = 1

" Menor tempo de atualização = sugestões mais rápidas
set updatetime=300
set shortmess+=c
set signcolumn=yes

" Tab / Shift-Tab para navegar nas sugestões
inoremap <silent><expr> <TAB>
            \ coc#pum#visible() ? coc#pum#next(1) :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Enter confirma a sugestão selecionada
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>"

function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1] =~# '\s'
endfunction

" Ctrl+Space força a sugestão manualmente
inoremap <silent><expr> <C-space> coc#refresh()

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

" Renomear símbolo
nnoremap <leader>rn <Plug>(coc-rename)

" ------------------------------------------------------------
" Toggle: ligar/desligar o autocomplete (F4)
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

" Texto usado na statusline / airline / winbar
function! AutocompleteStatus() abort
    return get(g:, 'my_autocomplete_enabled', 1) ? '● AC ON' : '○ AC OFF'
endfunction

" Integração com o airline (mostra o status na barra inferior)
if exists('g:loaded_airline')
    call airline#parts#define_function('coc_ac', 'AutocompleteStatus')
endif

" ------------------------------------------------------------
" coc-java: aponta o JDK/JRE a usar, se necessário customizar,
" edite ~/.vim/coc-settings.json (abra com :CocConfig)
" ------------------------------------------------------------
