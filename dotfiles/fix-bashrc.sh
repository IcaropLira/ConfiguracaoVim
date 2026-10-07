#!/usr/bin/env bash
# fix-bashrc.sh — conserta "syntax error near unexpected token `fi'" no ~/.bashrc (e ~/.zshrc)
# sem reinstalar nada. Faz backup antes e só aceita a correção se o shell aprovar.
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
ok()   { echo -e "\033[32m[✓]\033[0m $1"; }
warn() { echo -e "\033[33m[!]\033[0m $1"; }
rc_syntax_ok() { # $1=arquivo $2=bash|zsh
    case "$2" in
        bash) bash -n "$1" >/dev/null 2>&1 ;;
        zsh)  command -v zsh >/dev/null 2>&1 || return 0; zsh -n "$1" >/dev/null 2>&1 ;;
    esac
}

rc_err_line() { # $1=arquivo $2=shell -> número da 1ª linha com erro (999999 se não há erro)
    local out
    case "$2" in
        zsh) out="$(zsh -n "$1" 2>&1 | head -n1)" ;;
        *)   out="$(bash -n "$1" 2>&1 | head -n1)" ;;
    esac
    [ -n "$out" ] || { echo 999999; return; }
    echo "$out" | grep -oE 'line [0-9]+' | head -n1 | grep -oE '[0-9]+' || echo 0
}

rc_shell_of() { case "$1" in *zshrc) echo zsh ;; *) echo bash ;; esac; }

# Aplica um filtro awk (programa em $2) ao rc; só aceita se não piorar a sintaxe.
rc_apply_awk() {
    local rc="$1" prog="$2" tmp sh
    [ -f "$rc" ] || return 0
    sh="$(rc_shell_of "$rc")"
    tmp="${rc}.icaro-tmp.$$"
    awk "$prog" "$rc" > "$tmp"
    if rc_syntax_ok "$rc" "$sh" && ! rc_syntax_ok "$tmp" "$sh"; then
        warn "Mudança em $(basename "$rc") quebraria a sintaxe — descartada."
        rm -f "$tmp"; return 0
    fi
    cat "$tmp" > "$rc"; rm -f "$tmp"
}

# Repara `fi`/`done`/`esac` órfão ou bloco vazio (`then` seguido de `fi`), que dá
# "syntax error near unexpected token `fi'". Backup sempre; só aceita o que passar no -n.
repair_rc_syntax() {
    local rc="$1" shell="$2" n tmp backup attempt=0
    [ -f "$rc" ] || return 0
    rc_syntax_ok "$rc" "$shell" && return 0
    backup="${rc}.icaro-syntax-backup.$TIMESTAMP"
    cp -a "$rc" "$backup"
    while ! rc_syntax_ok "$rc" "$shell" && [ "$attempt" -lt 10 ]; do
        attempt=$((attempt + 1))
        n="$(rc_err_line "$rc" "$shell")"
        [ "$n" -gt 0 ] && [ "$n" -lt 999999 ] || break
        tmp="${rc}.icaro-repair.$$"
        # 1ª tentativa: bloco vazio (`then`/`else`/`do` direto no `fi`/`done`) -> insere ':' antes da linha
        awk -v n="$n" 'NR == n {print "  :"} {print}' "$rc" > "$tmp"
        if rc_syntax_ok "$tmp" "$shell"; then mv "$tmp" "$rc"; continue; fi
        if [ "$(rc_err_line "$tmp" "$shell")" -gt "$((n + 1))" ] && ! grep -q 'end of file' <("$shell" -n "$tmp" 2>&1); then
            mv "$tmp" "$rc"; continue   # resolveu este bloco; ainda há outro problema adiante
        fi
        # 2ª tentativa: fechamento órfão (`fi` sem `if`) -> apaga a linha
        awk -v n="$n" 'NR != n {print}' "$rc" > "$tmp"
        if rc_syntax_ok "$tmp" "$shell"; then mv "$tmp" "$rc"; continue; fi
        # 3ª tentativa: apagar só ajuda se o erro andar pra frente (vários problemas no arquivo)
        if [ "$(rc_err_line "$tmp" "$shell")" -gt "$n" ] && ! grep -q 'end of file' <("$shell" -n "$tmp" 2>&1); then
            mv "$tmp" "$rc"; continue
        fi
        rm -f "$tmp"; break
    done
    if rc_syntax_ok "$rc" "$shell"; then
        ok "Corrigi o erro de sintaxe de $(basename "$rc"). Backup: $backup"
    else
        cp -a "$backup" "$rc"
        warn "Não consegui reparar $(basename "$rc") sozinho (original preservado). Backup: $backup"
        warn "Rode:  bash -n $rc   e apague/ajuste a linha apontada."
    fi
}

repair_rc_syntax "$HOME/.bashrc" bash
[ -f "$HOME/.zshrc" ] && repair_rc_syntax "$HOME/.zshrc" zsh
bash -n "$HOME/.bashrc" && ok "~/.bashrc está sem erros de sintaxe."
