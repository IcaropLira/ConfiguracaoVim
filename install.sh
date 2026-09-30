#!/usr/bin/env bash
#
#   _____ _____ _____ _____ _____ _____ _____ _____ _____
#  |   __|  _  |   __|_   _|   __|   __|_   _|     |  |  |
#  |   __|     |__   | | | |   __|   __| | | |   --|     |
#  |__|  |__|__|_____| |_| |__|  |_____| |_| |_____|__|__|
#
#  install.sh — instalador combinado: kitty (+ terminal padrão do
#  sistema + atalho na barra de tarefas), tmux e Vim, tudo de uma vez.
#
#  Pergunta UMA VEZ se você tem acesso a sudo (o normal em laboratórios
#  tipo os da UFCG é não ter) e repassa essa escolha pros três
#  instaladores — nenhum deles pergunta de novo. Sem sudo, tudo é
#  instalado em $HOME/.local, sem tocar em nada fora da sua pasta
#  pessoal (exceto pelo ~/.bashrc/~/.zshrc/~/.vimrc/~/.tmux.conf, que
#  são arquivos de configuração seus, sempre com backup automático).
#
#  Também pergunta UMA VEZ se o terminal (kitty) deve ser transparente ou
#  preto total, sem transparência.
#
#  Uso: ./install.sh [--user | --system] [--no-font] [--no-extras] [--copy]
#                    [--transparent | --black]
#    --transparent terminal translúcido (pula a pergunta)
#    --black       terminal preto total, sem transparência (pula a pergunta)
#    --user      força instalação sem sudo (pula a pergunta)
#    --system    força instalação com sudo (pula a pergunta)
#    --no-font   não instala a JetBrainsMono Nerd Font (kitty)
#    --no-extras não instala starship/eza/bat/zoxide/fzf (kitty)
#    --copy      copia as configs do kitty em vez de criar symlinks
#
set -euo pipefail

c_reset="\033[0m"; c_blue="\033[34m"; c_green="\033[32m"; c_yellow="\033[33m"; c_bold="\033[1m"
info()  { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()    { echo -e "${c_green}[✓]${c_reset} $1"; }
warn()  { echo -e "${c_yellow}[!]${c_reset} $1"; }
title() { echo -e "\n${c_bold}$1${c_reset}\n"; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KITTY_ARGS=()
FORCE_MODE=""
TERM_STYLE=""

for arg in "$@"; do
    case "$arg" in
        --user)   FORCE_MODE="user" ;;
        --system) FORCE_MODE="system" ;;
        --no-font|--no-extras|--copy) KITTY_ARGS+=("$arg") ;;
        --transparent) TERM_STYLE="transparent" ;;
        --black)       TERM_STYLE="black" ;;
        -h|--help)
            echo "Uso: ./install.sh [--user | --system] [--no-font] [--no-extras] [--copy] [--transparent | --black]"
            exit 0
            ;;
    esac
done

cat <<'BANNER'
==========================================================
  Ícaro Lira — kitty + tmux + Vim, tudo de uma vez
==========================================================
BANNER
echo

# ---------- pergunta UMA VEZ sobre sudo, pros três instaladores ----------
if [ -n "$FORCE_MODE" ]; then
    ICARO_MODE="$FORCE_MODE"
elif ! command -v sudo >/dev/null 2>&1; then
    ICARO_MODE="user"
    info "'sudo' não encontrado neste sistema — instalando tudo em \$HOME/.local."
else
    echo "Em muitos laboratórios (ex: labs da UFCG) você tem 'sudo' instalado no"
    echo "sistema, mas SEM permissão de usar de verdade."
    read -rp "Você TEM acesso a sudo nesta máquina (root de verdade)? [s/N] " resp_sudo
    resp_sudo="${resp_sudo:-n}"
    if [[ "$resp_sudo" =~ ^[Ss]$ ]]; then ICARO_MODE="system"; else ICARO_MODE="user"; fi
fi
export ICARO_MODE

if [ "$ICARO_MODE" = "user" ]; then
    ok "Modo: instalação 100%% em \$HOME/.local, sem sudo em lugar nenhum."
else
    ok "Modo: instalação via gerenciador de pacotes do sistema, com sudo."
fi

# ---------- pergunta UMA VEZ o estilo do terminal (kitty) ----------
if [ -z "$TERM_STYLE" ]; then
    echo
    echo "Como você quer o terminal (kitty)?"
    echo "  1) Transparente (translúcido, com blur atrás)"
    echo "  2) Preto total, sem transparência"
    read -rp "Escolha [1/2] (padrão: 1) " resp_style || resp_style=""
    case "${resp_style:-1}" in
        2|p|P|b|B) TERM_STYLE="black" ;;
        *)         TERM_STYLE="transparent" ;;
    esac
fi
export ICARO_TERM_STYLE="$TERM_STYLE"
if [ "$TERM_STYLE" = "black" ]; then
    ok "Terminal: preto total, sem transparência."
else
    ok "Terminal: transparente."
fi

SUMMARY=()

# ---------- 1. kitty (+ terminal padrão + barra de tarefas) ----------
title "1/3 — kitty (terminal)"
if [ -f "$ROOT/dotfiles/install.sh" ]; then
    if (cd "$ROOT/dotfiles" && bash install.sh "${KITTY_ARGS[@]}"); then
        SUMMARY+=("✓ kitty instalado e definido como terminal padrão")
    else
        warn "O instalador do kitty terminou com erro — veja o log acima."
        SUMMARY+=("x kitty: terminou com erro, veja o log acima")
    fi
else
    warn "Não achei dotfiles/install.sh — pulando o kitty."
    SUMMARY+=("- kitty: pulado (dotfiles/install.sh não encontrado)")
fi

# ---------- 2. tmux ----------
title "2/3 — tmux"
if [ -f "$ROOT/tmux/install.sh" ]; then
    if (cd "$ROOT/tmux" && bash install.sh); then
        SUMMARY+=("✓ tmux instalado e configurado")
    else
        warn "O instalador do tmux terminou com erro — veja o log acima."
        SUMMARY+=("x tmux: terminou com erro, veja o log acima")
    fi
else
    warn "Não achei tmux/install.sh — pulando o tmux."
    SUMMARY+=("- tmux: pulado (tmux/install.sh não encontrado)")
fi

# ---------- 3. Vim ----------
title "3/3 — Vim (C++/Java/Python)"
if [ -f "$ROOT/vim/install.sh" ]; then
    if (cd "$ROOT/vim" && bash install.sh); then
        SUMMARY+=("✓ Vim instalado e configurado")
    else
        warn "O instalador do Vim terminou com erro — veja o log acima."
        SUMMARY+=("x Vim: terminou com erro, veja o log acima")
    fi
else
    warn "Não achei vim/install.sh — pulando o Vim."
    SUMMARY+=("- Vim: pulado (vim/install.sh não encontrado)")
fi

title "Resumo"
for line in "${SUMMARY[@]}"; do
    echo "  $line"
done
echo
if [ "$ICARO_MODE" = "user" ]; then
    info "Tudo foi instalado em \$HOME/.local — abra um NOVO terminal (ou rode"
    info "'source ~/.bashrc') pra os comandos novos (kitty, tmux, node, java, se"
    info "algum deles precisou ser baixado) aparecerem no PATH."
fi
info "Procure o kitty no menu de aplicativos ou na barra de tarefas — ele já"
info "deve estar lá fixado. Dentro dele: 'tmux' abre o multiplexador, 'vim'"
info "abre o editor."
echo
