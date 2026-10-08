#!/usr/bin/env bash
# install.sh — instala o Neovim (se faltar), liga a config e baixa plugins/parsers/LSP.
# Uso: ./install.sh [--copy] [--no-bootstrap]
#   --copy          copia a config em vez de criar um symlink para esta pasta
#   --no-bootstrap  não baixa plugins/parsers/LSP agora (o Neovim faz no 1º uso)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(dirname "$ROOT")"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
BIN="$HOME/.local/bin"
STAMP="$(date +%Y%m%d_%H%M%S)"
COPY=false; BOOTSTRAP=true
for a in "$@"; do
    case "$a" in
        --copy) COPY=true ;;
        --no-bootstrap) BOOTSTRAP=false ;;
        -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    esac
done

c_reset="\033[0m"; c_blue="\033[34m"; c_green="\033[32m"; c_yellow="\033[33m"
info() { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()   { echo -e "${c_green}[✓]${c_reset} $1"; }
warn() { echo -e "${c_yellow}[!]${c_reset} $1"; }

mkdir -p "$BIN"
export PATH="$BIN:$PATH"


# Node.js portátil (para o pyright / Python LSP) e JDK portátil (jdtls / Java), sem sudo.
# Mesmos diretórios que o instalador do Vim usa, então os dois compartilham.
fetch_node_portable() {
    local node_arch tmp filename
    case "$(uname -m)" in
        x86_64|amd64)  node_arch="x64" ;;
        aarch64|arm64) node_arch="arm64" ;;
        *) return 1 ;;
    esac
    command -v curl >/dev/null 2>&1 || return 1
    info "Baixando um Node.js portátil (LTS oficial) para \$HOME/.local, sem sudo..."
    filename="$(curl -fsSL https://nodejs.org/dist/latest-lts/ 2>/dev/null \
        | grep -oE "node-v[0-9.]+-linux-${node_arch}\.tar\.xz" | head -n1)"
    [ -n "$filename" ] || return 1
    tmp="$(mktemp -d)"
    if ! curl -fsSL -o "$tmp/node.tar.xz" "https://nodejs.org/dist/latest-lts/${filename}" 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    mkdir -p "$HOME/.local/node-icaro"
    if ! tar xJf "$tmp/node.tar.xz" -C "$HOME/.local/node-icaro" --strip-components=1 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    rm -rf "$tmp"
    for b in node npm npx; do ln -sf "$HOME/.local/node-icaro/bin/$b" "$BIN/$b"; done
    return 0
}

fetch_jdk_portable() {
    local jdk_arch tmp
    case "$(uname -m)" in
        x86_64|amd64)  jdk_arch="x64" ;;
        aarch64|arm64) jdk_arch="aarch64" ;;
        *) return 1 ;;
    esac
    command -v curl >/dev/null 2>&1 || return 1
    info "Baixando um JDK portátil (Eclipse Temurin 21) para \$HOME/.local, sem sudo..."
    tmp="$(mktemp -d)"
    if ! curl -fsSL -o "$tmp/jdk.tar.gz" "https://api.adoptium.net/v3/binary/latest/21/ga/linux/${jdk_arch}/jdk/hotspot/normal/eclipse" 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    mkdir -p "$HOME/.local/jdk-icaro"
    if ! tar xzf "$tmp/jdk.tar.gz" -C "$HOME/.local/jdk-icaro" --strip-components=1 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    rm -rf "$tmp"
    ln -sf "$HOME/.local/jdk-icaro/bin/java" "$BIN/java"
    ln -sf "$HOME/.local/jdk-icaro/bin/javac" "$BIN/javac"
    return 0
}

# ---------- 1. Neovim >= 0.10 ----------
nvim_ok() {
    command -v nvim >/dev/null 2>&1 || return 1
    nvim --headless +'lua io.stdout:write(vim.fn.has("nvim-0.10") == 1 and "yes" or "no")' +qa 2>/dev/null | grep -q yes
}

install_nvim() {
    local arch asset url tmp
    case "$(uname -m)" in
        x86_64|amd64)  arch="x86_64" ;;
        aarch64|arm64) arch="arm64" ;;
        *) warn "Arquitetura $(uname -m) sem build pronto do Neovim."; return 1 ;;
    esac
    command -v curl >/dev/null 2>&1 || { warn "curl não encontrado — não consigo baixar o Neovim."; return 1; }
    asset="nvim-linux-${arch}.tar.gz"
    url="https://github.com/neovim/neovim/releases/latest/download/${asset}"
    info "Baixando o Neovim (build oficial) para \$HOME/.local — sem sudo..."
    tmp="$(mktemp -d)"
    if ! curl -fsSL -o "$tmp/nvim.tgz" "$url"; then rm -rf "$tmp"; return 1; fi
    rm -rf "$HOME/.local/nvim-icaro"; mkdir -p "$HOME/.local/nvim-icaro"
    if ! tar xzf "$tmp/nvim.tgz" -C "$HOME/.local/nvim-icaro" --strip-components=1; then rm -rf "$tmp"; return 1; fi
    rm -rf "$tmp"
    ln -sf "$HOME/.local/nvim-icaro/bin/nvim" "$BIN/nvim"
    return 0
}

if nvim_ok; then
    ok "Neovim já instalado ($(nvim --version | head -1))."
else
    if install_nvim && nvim_ok; then
        ok "Neovim instalado: $(nvim --version | head -1)"
    else
        warn "Não consegui instalar o Neovim 0.10+ automaticamente."
        warn "Instale manualmente (https://github.com/neovim/neovim/releases) e rode este script de novo."
        exit 1
    fi
fi

# ---------- 2. dependências (só avisa; nada aqui é obrigatório pra abrir o nvim) ----------
need() { command -v "$1" >/dev/null 2>&1; }
need git || warn "git não encontrado — NECESSÁRIO para baixar os plugins."
{ need gcc || need cc; } || warn "compilador C (gcc) não encontrado — o Treesitter precisa dele para os parsers."
need make || warn "make não encontrado — o Telescope usa o fzf nativo (opcional, mais rápido)."
need rg || warn "ripgrep (rg) não encontrado — a busca de texto <leader>fg precisa dele."
need unzip || warn "unzip não encontrado — o Mason precisa dele para alguns servidores."
if ! need npm; then
    fetch_node_portable && ok "Node.js portátil instalado (para o pyright)." \
        || warn "npm não encontrado e não consegui baixar o Node — o pyright (Python LSP) será pulado."
fi
if ! need javac; then
    fetch_jdk_portable && ok "JDK portátil instalado (para Java: F5–F8 e jdtls)." \
        || warn "javac não encontrado e não consegui baixar o JDK — Java ficará sem compilar/LSP até existir um JDK."
fi

# ---------- 3. ligar a config ----------
if [ -e "$CFG" ] || [ -L "$CFG" ]; then
    if [ -L "$CFG" ] && [ "$(readlink -f "$CFG")" = "$(readlink -f "$ROOT")" ]; then
        info "A config já aponta para $ROOT."
    else
        mv "$CFG" "${CFG}.backup.${STAMP}"
        ok "Config antiga salva em ${CFG}.backup.${STAMP}"
    fi
fi
mkdir -p "$(dirname "$CFG")"
if $COPY; then
    mkdir -p "$CFG"
    cp -r "$ROOT/." "$CFG/"
    if [ -d "$REPO/vim/theme/icaro-theme" ]; then
        mkdir -p "$CFG/theme"; rm -rf "$CFG/theme/icaro-theme"
        cp -r "$REPO/vim/theme/icaro-theme" "$CFG/theme/icaro-theme"
    fi
    ok "Config copiada para $CFG (com os temas)."
elif [ ! -e "$CFG" ]; then
    ln -sfn "$ROOT" "$CFG"
    ok "Config ligada: $CFG → $ROOT"
fi

# ---------- 4. plugins, parsers e LSP ----------
if $BOOTSTRAP; then
    info "Baixando plugins (primeira vez demora um pouco)..."
    nvim --headless "+Lazy! restore" +qa 2>&1 | tail -3 || true
    nvim --headless "+Lazy! sync" +qa 2>&1 | tail -3 || true
    nvim --headless -c "lua require('icaro.bootstrap').run()" -c "qa!" 2>&1 | grep -v '^$' || true
    ok "Plugins prontos."
else
    info "Pulei o download de plugins; o Neovim baixa tudo na primeira abertura."
fi

echo
ok "Neovim configurado! Abra com: nvim"
info "Dentro dele: F1 troca o tema, F12 mostra todos os atalhos, :IcaroDoctor confere a instalação."
