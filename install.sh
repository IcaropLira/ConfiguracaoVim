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
#  Também pergunta UMA VEZ se o terminal (kitty) deve ser translúcido ou
#  de cor sólida, e qual paleta de cores usar.
#
#  Uso: ./install.sh [--user | --system] [--no-font] [--no-extras] [--copy]
#                    [--transparent | --solid] [--palette=<nome>]
#    --transparent terminal translúcido (pula a pergunta)
#    --solid      terminal de cor sólida (pula a pergunta)
#    --black      alias legado de --solid
#    --palette    escolhe a paleta sem perguntar
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


select_menu() {
    local title="$1"; shift
    local -a options=("$@")
    local idx=0 key rest i
    while true; do
        printf '\033[2J\033[H'
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  $title"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$idx" ]; then printf '  \033[1;7m ❯ %-54s \033[0m\n' "${options[$i]}"; else printf '    %-56s\n' "${options[$i]}"; fi
        done
        echo
        echo "  ↑ ↓  navegar     ENTER  confirmar"
        IFS= read -rsn1 key || true
        if [ "$key" = $'\033' ]; then IFS= read -rsn2 rest || true; key="$key$rest"; fi
        case "$key" in
            $'\033[A'|$'\033[D') idx=$(( (idx - 1 + ${#options[@]}) % ${#options[@]} )) ;;
            $'\033[B'|$'\033[C') idx=$(( (idx + 1) % ${#options[@]} )) ;;
            "") MENU_INDEX="$idx"; return 0 ;;
        esac
    done
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KITTY_ARGS=()
FORCE_MODE=""
TERM_STYLE=""
TERM_PALETTE=""

for arg in "$@"; do
    case "$arg" in
        --user)   FORCE_MODE="user" ;;
        --system) FORCE_MODE="system" ;;
        --no-font|--no-extras|--copy) KITTY_ARGS+=("$arg") ;;
        --transparent) TERM_STYLE="transparent" ;;
        --solid|--black) TERM_STYLE="solid" ;;
        --palette=*) TERM_PALETTE="${arg#--palette=}" ;;
        -h|--help)
            echo "Uso: ./install.sh [--user | --system] [--no-font] [--no-extras] [--copy] [--transparent | --solid] [--palette=<nome>]"
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
    select_menu "MODO DE INSTALAÇÃO" \
        "Instalação no usuário — sem sudo (recomendado para laboratório)" \
        "Instalação do sistema — usando sudo"
    if [ "$MENU_INDEX" -eq 1 ]; then ICARO_MODE="system"; else ICARO_MODE="user"; fi
fi
export ICARO_MODE

if [ "$ICARO_MODE" = "user" ]; then
    ok "Modo: instalação 100%% em \$HOME/.local, sem sudo em lugar nenhum."
else
    ok "Modo: instalação via gerenciador de pacotes do sistema, com sudo."
fi

# ---------- aparência do terminal (kitty) ----------
# A seleção interativa detalhada acontece no instalador do kitty, com preview real.
export ICARO_TERM_STYLE="$TERM_STYLE"
export ICARO_TERM_PALETTE="$TERM_PALETTE"
ok "Terminal: $TERM_STYLE + paleta $TERM_PALETTE."

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
