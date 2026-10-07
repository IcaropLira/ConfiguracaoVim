scriptencoding utf-8
if exists('g:loaded_my_functionkeys')
    finish
endif
let g:loaded_my_functionkeys = 1

" ============================================================
" Compatibilidade de teclas de função
"
" Alguns terminais/DEs Linux enviam códigos diferentes para F1-F12 e
" principalmente para Shift+F*. O Vim normalmente traduz isso via
" terminfo, mas terminais dentro de tmux/SSH, Linux console e versões
" diferentes de xterm/kitty podem expor sequências alternativas.
"
" A ideia aqui é simples: aceitar os códigos mais comuns e encaminhar
" todos para a mesma ação. Os atalhos normais (<F3>, <S-F10>, etc.)
" continuam sendo a API principal; estas entradas são apenas aliases.
" ============================================================

function! IcaroDispatchFunctionKey(n) abort
    let l:ft = &filetype
    if a:n == 1
        call CycleTheme()
    elseif a:n == 2
        silent! NERDTreeToggle
    elseif a:n == 3
        call ToggleInlayHints()
    elseif a:n == 4
        call ToggleAutocomplete()
    elseif a:n == 5
        if l:ft ==# 'cpp' && exists('*CompileCpp')
            call CompileCpp()
        elseif l:ft ==# 'java' && exists('*CompileJava')
            call CompileJava()
        endif
    elseif a:n == 6
        if l:ft ==# 'cpp' && exists('*RunCpp')
            call RunCpp()
        elseif l:ft ==# 'java' && exists('*RunJava')
            call RunJava()
        endif
    elseif a:n == 7
        if l:ft ==# 'cpp' && exists('*BuildRunCpp')
            call BuildRunCpp()
        elseif l:ft ==# 'java' && exists('*BuildRunJava')
            call BuildRunJava()
        elseif l:ft ==# 'python' && exists('*RunPython')
            call RunPython()
        endif
    elseif a:n == 8
        if l:ft ==# 'cpp' && exists('*TestCpp')
            call TestCpp()
        elseif l:ft ==# 'java' && exists('*TestJava')
            call TestJava()
        endif
    elseif a:n == 9
        execute 'terminal'
    elseif a:n == 10
        call ToggleAutoPairs()
    elseif a:n == 12
        call ToggleCheatsheet()
    endif
endfunction

function! IcaroDispatchShiftFunctionKey(n) abort
    if a:n == 1
        call PreviousTheme()
    elseif a:n == 10
        call ToggleMatchParen()
    elseif a:n == 11
        call ToggleQuietMode()
    elseif a:n == 12
        call ToggleHeader()
    endif
endfunction

" Mapeia uma sequência alternativa diretamente para a ação. Isso evita
" depender de um único terminfo e funciona também quando o terminal
" não anuncia corretamente a tecla ao Vim.
function! s:Alias(lhs, rhs) abort
    execute 'nnoremap <silent> ' . a:lhs . ' ' . a:rhs
    execute 'inoremap <silent> ' . a:lhs . ' <C-o>' . a:rhs
endfunction

" xterm/VT100: F1-F4 também podem vir como ESC O P/Q/R/S.
call s:Alias("\<Esc>OP", ':call IcaroDispatchFunctionKey(1)<CR>')
call s:Alias("\<Esc>OQ", ':call IcaroDispatchFunctionKey(2)<CR>')
call s:Alias("\<Esc>OR", ':call IcaroDispatchFunctionKey(3)<CR>')
call s:Alias("\<Esc>OS", ':call IcaroDispatchFunctionKey(4)<CR>')

" VT/xterm CSI sem modifier. Também cobre terminais que ignoram o
" terminfo e entregam a sequência literal.
let s:fkeys = {1: 11, 2: 12, 3: 13, 4: 14, 5: 15, 6: 17, 7: 18, 8: 19, 9: 20, 10: 21, 11: 23, 12: 24}
for s:n in keys(s:fkeys)
    call s:Alias("\<Esc>[" . s:fkeys[s:n] . "~", ':call IcaroDispatchFunctionKey(' . s:n . ')<CR>')
endfor

" Linux console: F1-F5 são ESC[[A ... ESC[[E.
call s:Alias("\<Esc>[[A", ':call IcaroDispatchFunctionKey(1)<CR>')
call s:Alias("\<Esc>[[B", ':call IcaroDispatchFunctionKey(2)<CR>')
call s:Alias("\<Esc>[[C", ':call IcaroDispatchFunctionKey(3)<CR>')
call s:Alias("\<Esc>[[D", ':call IcaroDispatchFunctionKey(4)<CR>')
call s:Alias("\<Esc>[[E", ':call IcaroDispatchFunctionKey(5)<CR>')

" Shift+F1..F12: CSI com modificador 2. F5-F12 usam os códigos
" estendidos 15,17,18,19,20,21,23,24.
call s:Alias("\<Esc>[1;2P", ':call IcaroDispatchShiftFunctionKey(1)<CR>')
call s:Alias("\<Esc>[1;2Q", ':call IcaroDispatchShiftFunctionKey(2)<CR>')
call s:Alias("\<Esc>[1;2R", ':call IcaroDispatchShiftFunctionKey(3)<CR>')
call s:Alias("\<Esc>[1;2S", ':call IcaroDispatchShiftFunctionKey(4)<CR>')
call s:Alias("\<Esc>[15;2~", ':call IcaroDispatchShiftFunctionKey(5)<CR>')
call s:Alias("\<Esc>[17;2~", ':call IcaroDispatchShiftFunctionKey(6)<CR>')
call s:Alias("\<Esc>[18;2~", ':call IcaroDispatchShiftFunctionKey(7)<CR>')
call s:Alias("\<Esc>[19;2~", ':call IcaroDispatchShiftFunctionKey(8)<CR>')
call s:Alias("\<Esc>[20;2~", ':call IcaroDispatchShiftFunctionKey(9)<CR>')
call s:Alias("\<Esc>[21;2~", ':call IcaroDispatchShiftFunctionKey(10)<CR>')
call s:Alias("\<Esc>[23;2~", ':call IcaroDispatchShiftFunctionKey(11)<CR>')
call s:Alias("\<Esc>[24;2~", ':call IcaroDispatchShiftFunctionKey(12)<CR>')

" Algumas versões de terminal/terminfo entregam Shift+F10 como uma
" variante modificada da sequência base. Aceitamos também a forma
" ;2~ já usada pelo xterm moderno.

" F24 é usado como fallback para Shift+F12 em alguns ambientes.
call s:Alias("\<Esc>[24;3~", ':call ToggleHeader()<CR>')
