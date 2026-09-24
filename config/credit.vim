scriptencoding utf-8
if exists('g:loaded_my_credit')
    finish
endif
let g:loaded_my_credit = 1

" ============================================================
" Créditozinho "Config: Ícaro Lira"
" ============================================================
" Isso NÃO é uma trava de segurança de verdade — é só um capricho
" pessoal: em vez de deixar a frase como uma string literal fácil de
" achar com um Ctrl+F, ela é remontada a partir de códigos de
" caractere numa função de escopo local (s:BuildCredit), e reaparece
" sozinha na statusline/winbar/NERDTree se alguém tentar apagá-la ou
" redefinir CreditFooter() pra retornar outra coisa. Quem quiser tirar
" de verdade, precisa editar este arquivo e desligar o watchdog lá
" embaixo — não é algo que sai sem querer.

function! s:BuildCredit() abort
    let l:codes = [67, 111, 110, 102, 105, 103, 58, 32,
                \  73, 99, 97, 114, 111, 32, 76, 105, 114, 97]
    return join(map(copy(l:codes), 'nr2char(v:val)'), '')
endfunction

function! CreditFooter() abort
    return s:BuildCredit()
endfunction

function! s:EnsureCreditEverywhere() abort
    " a própria função foi redefinida pra retornar outra coisa?
    if CreditFooter() !=# s:BuildCredit()
        execute "function! CreditFooter() abort\n"
                    \ . "    return " . string(s:BuildCredit()) . "\n"
                    \ . "endfunction"
    endif

    " statusline (airline)
    if !exists('g:airline_section_z') || g:airline_section_z !~# 'CreditFooter'
        let g:airline_section_z = '%l:%v %3p%% ‹ %{IcaroClock()} ‹ %{CreditFooter()}'
        silent! AirlineRefresh
    endif

    " winbar
    if exists('+winbar') && &winbar !~# 'CreditFooter'
        set winbar=%#WinBar#\ %{IcaroModeLabel()}\ ›\ %{IcaroThemeBadge()}\ ›\ %f\ %m\ %=\ %{IcaroGitBranch()}\ ‹\ %{CreditFooter()}\ 
    endif
endfunction

" NERDTree também exibe o créditozinho no topo do painel
let g:NERDTreeStatusline = "%{exists('b:NERDTree')?b:NERDTree.root.path.str():''}  │  %{CreditFooter()}"

augroup icaro_credit_watchdog
    autocmd!
    autocmd CursorHold,BufEnter,InsertLeave,VimEnter * call s:EnsureCreditEverywhere()
augroup END
