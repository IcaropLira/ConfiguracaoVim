#!/usr/bin/env bash
#
#  install.sh — instala o tmux (se precisar) e a configuração Ícaro Lira.
#  Funciona COM ou SEM acesso a sudo: sem root, baixa um build estático
#  oficial (tmux/tmux-builds) pra ~/.local/bin, sem tocar em nada fora
#  da sua pasta pessoal.
#
#  Uso: ./install.sh [--user] [--system]
#
#  Se a variável de ambiente ICARO_MODE já vier definida como "user" ou
#  "system" (é o que o instalador combinado lá da raiz faz), a pergunta
#  sobre sudo não é repetida.
set -euo pipefail

CONFIG="$HOME/.tmux.conf"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

c_reset="\033[0m"; c_blue="\033[34m"; c_green="\033[32m"; c_yellow="\033[33m"; c_red="\033[31m"
info()  { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()    { echo -e "${c_green}[✓]${c_reset} $1"; }
warn()  { echo -e "${c_yellow}[!]${c_reset} $1"; }
err()   { echo -e "${c_red}[x]${c_reset} $1"; }

echo "╔══════════════════════════════════════════╗"
echo "║       TMUX ÍCARO LIRA — INSTALLER       ║"
echo "╚══════════════════════════════════════════╝"
echo

FORCE_MODE="${ICARO_MODE:-}"
for arg in "$@"; do
    case "$arg" in
        --user)   FORCE_MODE="user" ;;
        --system) FORCE_MODE="system" ;;
        -h|--help)
            echo "Uso: ./install.sh [--user] [--system]"
            echo "  --user    instala o tmux (se precisar) em \$HOME/.local, sem sudo"
            echo "  --system  usa o gerenciador de pacotes do sistema (precisa de sudo)"
            exit 0
            ;;
    esac
done

MODE=""
if [ -n "$FORCE_MODE" ]; then
    MODE="$FORCE_MODE"
elif ! command -v sudo >/dev/null 2>&1; then
    MODE="user"
else
    read -rp "Você TEM acesso a sudo nesta máquina? [s/N] " resp_sudo
    resp_sudo="${resp_sudo:-n}"
    if [[ "$resp_sudo" =~ ^[Ss]$ ]]; then MODE="system"; else MODE="user"; fi
fi

# ---------- instalar o tmux, se ainda não tiver ----------
if ! command -v tmux >/dev/null 2>&1; then
    info "tmux não encontrado, instalando..."

    if [ "$MODE" = "system" ]; then
        if command -v dnf >/dev/null 2>&1; then
            sudo dnf install -y tmux && ok "tmux instalado via dnf." || warn "Falha ao instalar via dnf."
        elif command -v apt >/dev/null 2>&1; then
            sudo apt update -y && sudo apt install -y tmux && ok "tmux instalado via apt." || warn "Falha ao instalar via apt."
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --needed --noconfirm tmux && ok "tmux instalado via pacman." || warn "Falha ao instalar via pacman."
        elif command -v zypper >/dev/null 2>&1; then
            sudo zypper install -y tmux && ok "tmux instalado via zypper." || warn "Falha ao instalar via zypper."
        elif command -v brew >/dev/null 2>&1; then
            brew install tmux && ok "tmux instalado via brew." || warn "Falha ao instalar via brew."
        else
            warn "Não reconheci o gerenciador de pacotes — tentando build estático sem sudo mesmo assim."
        fi
    fi

    # Sem sudo (ou o gerenciador de pacotes falhou): baixa o build
    # estático oficial do próprio projeto tmux (tmux/tmux-builds),
    # feito pra rodar em qualquer distro sem precisar compilar nada.
    if ! command -v tmux >/dev/null 2>&1; then
        mkdir -p "$BIN_DIR"
        arch_name=""
        case "$(uname -m)" in
            x86_64|amd64)  arch_name="x86_64" ;;
            aarch64|arm64) arch_name="arm64" ;;
        esac

        if [ -z "$arch_name" ]; then
            err "Arquitetura '$(uname -m)' sem build estático conhecido do tmux."
        elif ! command -v curl >/dev/null 2>&1; then
            err "Sem 'curl' disponível — não deu pra baixar o tmux automaticamente."
        else
            info "Baixando build estático oficial do tmux (tmux/tmux-builds), sem sudo..."
            # Descobre a tag da release mais recente pelo redirect de
            # /releases/latest (não usa a API do GitHub, que tem um
            # limite de 60 req/hora sem autenticação — fácil de bater
            # nele num laboratório com várias pessoas instalando ao
            # mesmo tempo pelo mesmo IP).
            tag="$(curl -sI "https://github.com/tmux/tmux-builds/releases/latest" 2>/dev/null \
                | grep -i '^location:' | sed -E 's#.*/tag/##; s/\r$//')"
            if [ -z "$tag" ]; then
                err "Não consegui descobrir a versão mais recente do tmux."
                err "Baixe manualmente em: https://github.com/tmux/tmux-builds/releases/latest"
            else
                ver="${tag#v}"
                dl_url="https://github.com/tmux/tmux-builds/releases/download/${tag}/tmux-${ver}-linux-${arch_name}.tar.gz"
                tmp="$(mktemp -d)"
                if curl -fsSL -o "$tmp/tmux.tar.gz" "$dl_url" 2>/dev/null \
                    && tar xzf "$tmp/tmux.tar.gz" -C "$tmp" 2>/dev/null; then
                    found="$(find "$tmp" -maxdepth 2 -type f -name tmux 2>/dev/null | head -n1)"
                    if [ -n "$found" ]; then
                        install -m 755 "$found" "$BIN_DIR/tmux"
                        ok "tmux instalado em $BIN_DIR (build estático, sem sudo)."
                    else
                        err "Não encontrei o binário 'tmux' dentro do pacote baixado."
                    fi
                else
                    err "Falha ao baixar/extrair $dl_url"
                    err "Baixe manualmente em: https://github.com/tmux/tmux-builds/releases/latest"
                fi
                rm -rf "$tmp"
            fi
        fi
    fi

    export PATH="$BIN_DIR:$PATH"
    if ! command -v tmux >/dev/null 2>&1; then
        err "tmux continua indisponível. Instale manualmente e rode este script de novo."
        exit 1
    fi
fi

ok "tmux disponível: $(command -v tmux) ($(tmux -V))"

if [ -f "$CONFIG" ]; then
    BACKUP="$HOME/.tmux.conf.backup.$(date +%Y%m%d-%H%M%S)"
    cp "$CONFIG" "$BACKUP"
    ok "Backup criado: $BACKUP"
fi

cp "$SCRIPT_DIR/tmux.conf" "$CONFIG"
ok "~/.tmux.conf instalado"

if tmux info >/dev/null 2>&1; then
    tmux source-file "$CONFIG"
    ok "Configuração recarregada"
else
    info "Abra uma sessão com: tmux"
fi

echo
echo "Prefixo: Ctrl+A"
echo "Ajuda:   Ctrl+A ?"
echo "Recarregar: Ctrl+A r"
echo
if [ "$MODE" = "user" ] && [[ "$(command -v tmux)" == "$BIN_DIR"/* ]]; then
    info "tmux foi instalado em $BIN_DIR — abra um novo terminal (ou rode 'source ~/.bashrc')"
    info "se o comando 'tmux' não for encontrado na primeira vez."
fi
ok "TMUX Ícaro Lira instalado."
