#!/usr/bin/env bash
# shellrc.sh — aliases e inicialização de starship / eza / bat / zoxide / fzf
# Sourceado a partir do .bashrc / .zshrc pelo install.sh. Funciona em bash e zsh.

# ---------- detectar o shell atual ----------
if [ -n "${ZSH_VERSION:-}" ]; then
    _dotfiles_shell="zsh"
elif [ -n "${BASH_VERSION:-}" ]; then
    _dotfiles_shell="bash"
else
    _dotfiles_shell=""
fi

# ---------- eza (substituto do ls) ----------
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first -l'
    alias la='eza --icons --group-directories-first -la'
    alias lt='eza --icons --group-directories-first --tree --level=2'
fi

# ---------- bat (substituto do cat) ----------
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --paging=never'
elif command -v batcat >/dev/null 2>&1; then
    # No Debian/Ubuntu o binário se chama 'batcat'
    alias cat='batcat --paging=never'
    alias bat='batcat'
fi

# ---------- zoxide (cd mais esperto) ----------
if command -v zoxide >/dev/null 2>&1 && [ -n "$_dotfiles_shell" ]; then
    eval "$(zoxide init "$_dotfiles_shell")"
    alias cd='z'
fi

# ---------- fzf (busca fuzzy) ----------
if command -v fzf >/dev/null 2>&1 && [ -n "$_dotfiles_shell" ]; then
    eval "$(fzf --"$_dotfiles_shell" 2>/dev/null)"
fi

# ---------- starship (prompt) ----------
if command -v starship >/dev/null 2>&1 && [ -n "$_dotfiles_shell" ]; then
    eval "$(starship init "$_dotfiles_shell")"
fi

unset _dotfiles_shell
