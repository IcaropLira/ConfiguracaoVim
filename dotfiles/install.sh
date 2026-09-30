#!/usr/bin/env bash
#
#   _____ _____ _____ _____ _____ _____ _____ _____ _____
#  |   __|  _  |   __|_   _|   __|   __|_   _|     |  |  |
#  |   __|     |__   | | | |   __|   __| | | |   --|     |
#  |__|  |__|__|_____| |_| |__|  |_____| |_| |_____|__|__|
#
#  install.sh — instala e configura o kitty (+ starship/eza/bat/zoxide/fzf),
#  deixa ele como terminal padrão do sistema e cria um atalho na barra de
#  tarefas.
#  Funciona COM ou SEM acesso a sudo: sem root, tudo vai pra ~/.local
#  (binários pré-compilados baixados do GitHub), sem tocar em nada
#  fora da sua pasta pessoal.
#
#  Uso: ./install.sh [--user] [--system] [--no-font] [--no-extras] [--copy]
#                    [--transparent | --solid] [--palette=<nome>]
#    --transparent  terminal translúcido (com blur)
#    --solid        terminal de cor sólida, sem transparência
#    --black        alias legado de --solid
#    --palette      escolhe a paleta sem perguntar interativamente
#    (sem esses parâmetros, o instalador pergunta)
#
#  Se a variável de ambiente ICARO_MODE já vier definida como "user" ou
#  "system" (é o que o instalador combinado lá da raiz faz), a pergunta
#  sobre sudo não é repetida — reaproveita a escolha feita uma vez só.
set -euo pipefail

# ---------- cores pro output ----------
c_reset="\033[0m"
c_blue="\033[34m"
c_green="\033[32m"
c_yellow="\033[33m"
c_red="\033[31m"

info()  { echo -e "${c_blue}[*]${c_reset} $1"; }
ok()    { echo -e "${c_green}[✓]${c_reset} $1"; }
warn()  { echo -e "${c_yellow}[!]${c_reset} $1"; }
err()   { echo -e "${c_red}[x]${c_reset} $1"; }

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="$HOME/.local/bin"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

mkdir -p "$BIN_DIR"

# ---------- flags ----------
SKIP_FONT=false
NO_SYMLINK=false
SKIP_EXTRAS=false
FORCE_MODE="${ICARO_MODE:-}"   # "" | user | system — herdado do instalador combinado, se veio de lá
TERM_STYLE="${ICARO_TERM_STYLE:-}"   # "" | transparent | solid — idem
TERM_PALETTE="${ICARO_TERM_PALETTE:-}" # "" | navy | midnight | graphite | purple | pastel | pastel_blue | solarized_dark | solarized_light

for arg in "$@"; do
    case "$arg" in
        --user)         FORCE_MODE="user" ;;
        --system)       FORCE_MODE="system" ;;
        --no-packages)  FORCE_MODE="user" ;;  # compatibilidade com versões antigas
        --no-font)      SKIP_FONT=true ;;
        --no-extras)    SKIP_EXTRAS=true ;;
        --copy)         NO_SYMLINK=true ;;
        --transparent)  TERM_STYLE="transparent" ;;
        --solid|--black) TERM_STYLE="solid" ;;
        --palette=*)    TERM_PALETTE="${arg#--palette=}" ;;
        -h|--help)
            echo "Uso: ./install.sh [--user] [--system] [--no-font] [--no-extras] [--copy]"
            echo "  --user          instala tudo em \$HOME/.local, sem sudo (ideal pra PCs de laboratório)"
            echo "  --system        usa o gerenciador de pacotes do sistema (precisa de sudo)"
            echo "  --no-font       não instala a JetBrainsMono Nerd Font"
            echo "  --no-extras     não instala starship/eza/bat/zoxide/fzf"
            echo "  --copy          copia os arquivos de config em vez de criar symlinks"
            echo "  --transparent   terminal translúcido (com blur)"
            echo "  --solid         terminal de cor sólida, sem transparência"
            echo "  --black         alias legado de --solid"
            echo "  --palette=...   escolhe a paleta (navy, midnight, graphite, purple, pastel, pastel_blue, solarized_dark, solarized_light)"
            exit 0
            ;;
    esac
done

echo ""
info "Instalando dotfiles a partir de: $REPO_DIR"
echo ""

# ---------- 0. decidir o modo de instalação (com ou sem sudo) ----------
MODE=""
if [ -n "$FORCE_MODE" ]; then
    MODE="$FORCE_MODE"
elif ! command -v sudo >/dev/null 2>&1; then
    MODE="user"
    info "'sudo' não encontrado neste sistema."
else
    echo "Esta máquina tem 'sudo' instalado, mas em muitos laboratórios (ex: labs da UFCG) o"
    echo "usuário não tem permissão de usá-lo."
    read -rp "Você TEM acesso a sudo nesta máquina (consegue instalar pacotes com privilégio de root)? [s/N] " resp_sudo
    resp_sudo="${resp_sudo:-n}"
    if [[ "$resp_sudo" =~ ^[Ss]$ ]]; then MODE="system"; else MODE="user"; fi
fi

if [ "$MODE" = "user" ]; then
    ok "Modo escolhido: instalação 100%% em \$HOME/.local — nenhum comando precisa de root."
else
    ok "Modo escolhido: instalação via gerenciador de pacotes do sistema (com sudo)."
fi
echo ""

# ---------- detectar gerenciador de pacotes (só é usado no modo 'system') ----------
PKG_MANAGER=""
if [ "$MODE" = "system" ]; then
    if command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
    elif command -v apt >/dev/null 2>&1; then
        PKG_MANAGER="apt"
    elif command -v dnf >/dev/null 2>&1; then
        PKG_MANAGER="dnf"
    elif command -v zypper >/dev/null 2>&1; then
        PKG_MANAGER="zypper"
    elif command -v brew >/dev/null 2>&1; then
        PKG_MANAGER="brew"
    else
        warn "Não consegui detectar um gerenciador de pacotes suportado."
        warn "Vou instalar tudo em modo usuário (sem sudo) mesmo assim."
        MODE="user"
    fi
fi

install_pkg() {
    local pkg="$1"
    info "Instalando '$pkg' via $PKG_MANAGER..."
    case "$PKG_MANAGER" in
        pacman) sudo pacman -S --needed --noconfirm "$pkg" ;;
        apt)    sudo apt update -y && sudo apt install -y "$pkg" ;;
        dnf)    sudo dnf install -y "$pkg" ;;
        zypper) sudo zypper install -y "$pkg" ;;
        brew)   brew install "$pkg" ;;
        *)      return 1 ;;
    esac
}

# ---------- detectar arquitetura (pra baixar o binário certo em modo usuário) ----------
ARCH=""
case "$(uname -m)" in
    x86_64|amd64)  ARCH="amd64" ;;
    aarch64|arm64) ARCH="aarch64" ;;
    *) warn "Arquitetura '$(uname -m)' sem binário pré-compilado conhecido — alguns extras podem falhar." ;;
esac

# ---------- helpers de download em modo usuário ----------
# Baixa um .tar.gz, procura por um binário com nome exato dentro dele e instala em $BIN_DIR
fetch_targz_bin() {
    local url="$1" bin_name="$2" dest_name="${3:-$2}"
    local tmp archive found
    tmp="$(mktemp -d)"
    archive="$tmp/pkg.tar.gz"
    if ! curl -fsSL -o "$archive" "$url" 2>/dev/null; then
        warn "Falha ao baixar: $url"
        rm -rf "$tmp"
        return 1
    fi
    if ! tar xzf "$archive" -C "$tmp" 2>/dev/null; then
        warn "Falha ao extrair o pacote baixado de $url"
        rm -rf "$tmp"
        return 1
    fi
    # Prioriza o binário de verdade: primeiro dentro de um diretório bin/, depois
    # perto da raiz, e só por último qualquer arquivo com esse nome (pra não pegar
    # scripts de autocomplete ou outros arquivos com o mesmo nome por acaso).
    found="$(find "$tmp" -type f -path "*/bin/$bin_name" 2>/dev/null | head -n1)"
    if [ -z "$found" ]; then
        found="$(find "$tmp" -maxdepth 2 -type f -name "$bin_name" 2>/dev/null | head -n1)"
    fi
    if [ -z "$found" ]; then
        found="$(find "$tmp" -type f -name "$bin_name" \
            ! -path "*/share/*" ! -path "*/completions/*" ! -path "*/man/*" 2>/dev/null | head -n1)"
    fi
    if [ -z "$found" ]; then
        warn "Não encontrei o binário '$bin_name' dentro do pacote baixado."
        rm -rf "$tmp"
        return 1
    fi
    install -m 755 "$found" "$BIN_DIR/$dest_name"
    rm -rf "$tmp"
    ok "'$dest_name' instalado em $BIN_DIR (binário pré-compilado, sem sudo)."
}

# Descobre a tag da última release de um repo do GitHub (ex: sharkdp/bat -> v0.26.1)
get_gh_tag() {
    curl -sI "https://github.com/$1/releases/latest" 2>/dev/null \
        | grep -i '^location:' | sed -E 's#.*/tag/##; s/\r$//'
}

fetch_eza() {
    [ -n "$ARCH" ] || return 1
    local triple
    [ "$ARCH" = "amd64" ] && triple="x86_64-unknown-linux-musl" || triple="aarch64-unknown-linux-gnu"
    fetch_targz_bin "https://github.com/eza-community/eza/releases/latest/download/eza_${triple}.tar.gz" "eza"
}

fetch_bat() {
    [ -n "$ARCH" ] || return 1
    local tag triple
    tag="$(get_gh_tag sharkdp/bat)"
    [ -n "$tag" ] || { warn "Não consegui descobrir a versão mais recente do bat."; return 1; }
    [ "$ARCH" = "amd64" ] && triple="x86_64-unknown-linux-musl" || triple="aarch64-unknown-linux-musl"
    fetch_targz_bin "https://github.com/sharkdp/bat/releases/download/${tag}/bat-${tag}-${triple}.tar.gz" "bat"
}

fetch_fzf() {
    [ -n "$ARCH" ] || return 1
    local tag ver suffix
    tag="$(get_gh_tag junegunn/fzf)"
    [ -n "$tag" ] || { warn "Não consegui descobrir a versão mais recente do fzf."; return 1; }
    ver="${tag#v}"
    [ "$ARCH" = "amd64" ] && suffix="linux_amd64" || suffix="linux_arm64"
    fetch_targz_bin "https://github.com/junegunn/fzf/releases/download/${tag}/fzf-${ver}-${suffix}.tar.gz" "fzf"
}

fetch_kitty() {
    info "Baixando o kitty pra \$HOME/.local/kitty.app (instalação própria da kovidgoyal, sem sudo)..."
    local tmp_installer
    tmp_installer="$(mktemp /tmp/kitty-installer-XXXX.sh)"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL -o "$tmp_installer" https://sw.kovidgoyal.net/kitty/installer.sh || { warn "Falha ao baixar o instalador do kitty."; return 1; }
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$tmp_installer" https://sw.kovidgoyal.net/kitty/installer.sh || { warn "Falha ao baixar o instalador do kitty."; return 1; }
    else
        warn "Sem curl/wget disponível — não deu pra instalar o kitty."
        return 1
    fi
    sh "$tmp_installer" dest="$HOME/.local/kitty.app" launch=n || { warn "Falha ao instalar o kitty."; rm -f "$tmp_installer"; return 1; }
    rm -f "$tmp_installer"
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$BIN_DIR/kitty"
    ln -sf "$HOME/.local/kitty.app/bin/kitten" "$BIN_DIR/kitten"
    # integra o kitty ao menu de aplicativos (funciona sem root, ~/.local/share é do usuário)
    if [ -d "$HOME/.local/kitty.app/share/applications" ]; then
        mkdir -p "$HOME/.local/share/applications"
        cp "$HOME/.local/kitty.app/share/applications/kitty.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true
        cp "$HOME/.local/kitty.app/share/applications/kitty-open.desktop" "$HOME/.local/share/applications/" 2>/dev/null || true
        sed -i "s|Icon=kitty|Icon=$HOME/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" \
            "$HOME/.local/share/applications/kitty.desktop" 2>/dev/null || true
        sed -i "s|Exec=kitty|Exec=$HOME/.local/kitty.app/bin/kitty|g" \
            "$HOME/.local/share/applications/kitty.desktop" 2>/dev/null || true
    fi
    ok "kitty instalado. Link criado em $BIN_DIR/kitty."
}

# starship e zoxide: os instaladores oficiais deles já não precisam de sudo quando
# apontamos pra uma pasta que o usuário pode escrever, então usamos sempre esse caminho.
fetch_starship() {
    info "Instalando starship em $BIN_DIR (script oficial, sem sudo)..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$BIN_DIR" >/dev/null || { warn "Falha ao instalar o starship."; return 1; }
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://starship.rs/install.sh | sh -s -- -y -b "$BIN_DIR" >/dev/null || { warn "Falha ao instalar o starship."; return 1; }
    else
        warn "Sem curl/wget disponível — não deu pra instalar o starship."
        return 1
    fi
    ok "starship instalado em $BIN_DIR."
}

fetch_zoxide() {
    info "Instalando zoxide em $BIN_DIR (script oficial, sem sudo)..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null || { warn "Falha ao instalar o zoxide."; return 1; }
    elif command -v wget >/dev/null 2>&1; then
        wget -qO- https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh >/dev/null || { warn "Falha ao instalar o zoxide."; return 1; }
    else
        warn "Sem curl/wget disponível — não deu pra instalar o zoxide."
        return 1
    fi
    ok "zoxide instalado em $BIN_DIR."
}

# ---------- instalador genérico: tenta o gerenciador de pacotes, senão baixa o binário ----------
install_tool() {
    local cmd_check="$1" pkg_name="$2" fetch_fn="$3"
    if command -v "$cmd_check" >/dev/null 2>&1; then
        ok "'$cmd_check' já está instalado."
        return
    fi
    if [ "$MODE" = "system" ]; then
        if install_pkg "$pkg_name" && command -v "$cmd_check" >/dev/null 2>&1; then
            ok "'$cmd_check' instalado via $PKG_MANAGER."
            return
        fi
        warn "Não consegui instalar '$pkg_name' com $PKG_MANAGER — baixando binário direto do GitHub..."
    fi
    "$fetch_fn" || err "Não consegui instalar '$cmd_check' automaticamente. Baixe manualmente depois."
}

# ---------- 1. kitty ----------
install_tool kitty kitty fetch_kitty

# Caminho real do binário do kitty (pode ser o do sistema ou o de $HOME/.local/kitty.app,
# usado mais abaixo pra montar o Exec= do .desktop e do default-terminal).
KITTY_BIN="$(command -v kitty 2>/dev/null || echo "$BIN_DIR/kitty")"

# ---------- 1b. ferramentas extras (starship, eza, bat, zoxide, fzf) ----------
if [ "$SKIP_EXTRAS" = false ]; then
    echo ""
    read -rp "Instalar também starship, eza, bat, zoxide e fzf (prompt + CLIs modernas)? [S/n] " resp_extras
    resp_extras="${resp_extras:-s}"
    if [[ "$resp_extras" =~ ^[Ss]$ ]]; then
        if command -v starship >/dev/null 2>&1; then ok "'starship' já está instalado."; else fetch_starship || true; fi
        install_tool eza eza fetch_eza
        if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
            ok "'bat' já está instalado."
        else
            [ "$MODE" = "system" ] && { install_pkg bat || true; }
            if ! command -v bat >/dev/null 2>&1 && ! command -v batcat >/dev/null 2>&1; then
                fetch_bat || err "Não consegui instalar 'bat'."
            fi
        fi
        if command -v zoxide >/dev/null 2>&1; then ok "'zoxide' já está instalado."; else fetch_zoxide || true; fi
        install_tool fzf fzf fetch_fzf
    else
        SKIP_EXTRAS=true
    fi
else
    info "Pulando instalação das ferramentas extras (--no-extras)."
fi

# ---------- 2. Nerd Font (JetBrains Mono) — sempre em modo usuário, nunca precisa de sudo ----------
if [ "$SKIP_FONT" = false ]; then
    FONT_DIR="$HOME/.local/share/fonts"
    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
        ok "JetBrainsMono Nerd Font já instalada."
    else
        info "Instalando JetBrainsMono Nerd Font..."
        mkdir -p "$FONT_DIR"
        TMP_ZIP="$(mktemp /tmp/jbmono-XXXX.zip)"
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL -o "$TMP_ZIP" \
                "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        elif command -v wget >/dev/null 2>&1; then
            wget -q -O "$TMP_ZIP" \
                "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
        fi
        if [ -s "$TMP_ZIP" ]; then
            unzip -oq "$TMP_ZIP" -d "$FONT_DIR/JetBrainsMonoNerdFont"
            rm -f "$TMP_ZIP"
            fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
            ok "Fonte instalada em $FONT_DIR/JetBrainsMonoNerdFont"
        else
            warn "Não consegui baixar a fonte automaticamente. Baixe manualmente em:"
            warn "https://www.nerdfonts.com/font-downloads (JetBrainsMono Nerd Font)"
        fi
    fi
else
    info "Pulando instalação de fonte (--no-font)."
fi

# ---------- 3. link/copia das configs ----------
link_config() {
    local src="$1" dest="$2"

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ] && [ "$(readlink -f "$dest")" = "$(readlink -f "$src")" ]; then
            ok "$dest já aponta para o dotfiles."
            return
        fi
        local backup="${dest}.bak-${TIMESTAMP}"
        warn "Já existe $dest — fazendo backup em $backup"
        mv "$dest" "$backup"
    fi

    if [ "$NO_SYMLINK" = true ]; then
        cp -r "$src" "$dest"
        ok "Copiado: $src -> $dest"
    else
        ln -s "$src" "$dest"
        ok "Symlink criado: $dest -> $src"
    fi
}

link_config "$REPO_DIR/kitty" "$CONFIG_DIR/kitty"
if [ "$SKIP_EXTRAS" = false ]; then
    link_config "$REPO_DIR/starship/starship.toml" "$CONFIG_DIR/starship.toml"
fi

# ---------- 3b. estilo + paleta do terminal ----------
# O estilo (translúcido ou cor sólida) e a paleta são independentes:
# qualquer uma das paletas pode ser usada nos dois estilos.
if [ -z "$TERM_STYLE" ]; then
    echo ""
    echo "Como você quer o terminal?"
    echo "  1) Cor translúcida (blur atrás)"
    echo "  2) Cor sólida (sem transparência)"
    read -rp "Escolha [1/2] (padrão: 1) " resp_style || resp_style=""
    case "${resp_style:-1}" in
        2|s|S) TERM_STYLE="solid" ;;
        *)     TERM_STYLE="transparent" ;;
    esac
fi

case "$TERM_STYLE" in
    solid|transparent) ;;
    black) TERM_STYLE="solid" ;;
    *) warn "Estilo de terminal inválido '$TERM_STYLE'; usando translúcido."; TERM_STYLE="transparent" ;;
esac

if [ -z "$TERM_PALETTE" ]; then
    echo ""
    echo "Escolha a cor do terminal:"
    echo "  1) Azul escuro"
    echo "  2) Noite"
    echo "  3) Grafite"
    echo "  4) Roxo escuro"
    echo "  5) Pastel"
    echo "  6) Pastel azul"
    echo "  7) Solarized escuro"
    echo "  8) Solarized claro"
    read -rp "Escolha [1-8] (padrão: 1) " resp_palette || resp_palette=""
    case "${resp_palette:-1}" in
        1) TERM_PALETTE="navy" ;;
        2) TERM_PALETTE="midnight" ;;
        3) TERM_PALETTE="graphite" ;;
        4) TERM_PALETTE="purple" ;;
        5) TERM_PALETTE="pastel" ;;
        6) TERM_PALETTE="pastel_blue" ;;
        7) TERM_PALETTE="solarized_dark" ;;
        8) TERM_PALETTE="solarized_light" ;;
        *) warn "Opção de paleta inválida; usando Azul escuro."; TERM_PALETTE="navy" ;;
    esac
fi

PALETTE_FILE="$CONFIG_DIR/kitty/current-theme.conf"
case "$TERM_PALETTE" in
    navy)
        PALETTE_NAME="Azul escuro"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Azul escuro
background                #0b1220
foreground                #dbeafe
selection_background      #1e3a5f
selection_foreground      #eff6ff
url_color                 #60a5fa
cursor                    #93c5fd
cursor_text_color         #0b1220
active_border_color       #2563eb
inactive_border_color     #172554
bell_border_color         #f87171
visual_bell_color         none
active_tab_background     #172554
active_tab_foreground     #eff6ff
inactive_tab_background   #0f1b31
inactive_tab_foreground   #93a4bd
tab_bar_background        none
tab_bar_margin_color      none
color0                    #0b1220
color1                    #ef4444
color2                    #22c55e
color3                    #f59e0b
color4                    #3b82f6
color5                    #a855f7
color6                    #06b6d4
color7                    #dbeafe
color8                    #475569
color9                    #f87171
color10                   #4ade80
color11                   #fbbf24
color12                   #60a5fa
color13                   #c084fc
color14                   #22d3ee
color15                   #f8fafc
PALETTE
        ;;
    midnight)
        PALETTE_NAME="Noite"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Noite
background                #070b12
foreground                #e5e7eb
selection_background      #1f2937
selection_foreground      #f9fafb
url_color                 #38bdf8
cursor                    #e5e7eb
cursor_text_color         #070b12
active_border_color       #334155
inactive_border_color     #111827
bell_border_color         #fb7185
visual_bell_color         none
active_tab_background     #111827
active_tab_foreground     #f9fafb
inactive_tab_background   #0b1220
inactive_tab_foreground   #9ca3af
tab_bar_background        none
tab_bar_margin_color      none
color0                    #070b12
color1                    #fb7185
color2                    #4ade80
color3                    #facc15
color4                    #38bdf8
color5                    #c084fc
color6                    #2dd4bf
color7                    #e5e7eb
color8                    #475569
color9                    #fda4af
color10                   #86efac
color11                   #fde047
color12                   #7dd3fc
color13                   #d8b4fe
color14                   #5eead4
color15                   #f8fafc
PALETTE
        ;;
    graphite)
        PALETTE_NAME="Grafite"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Grafite
background                #15171a
foreground                #e6e6e6
selection_background      #34383f
selection_foreground      #ffffff
url_color                 #7aa2f7
cursor                    #ffffff
cursor_text_color         #15171a
active_border_color       #4b5563
inactive_border_color     #25282d
bell_border_color         #f7768e
visual_bell_color         none
active_tab_background     #2a2d33
active_tab_foreground     #ffffff
inactive_tab_background   #1c1f24
inactive_tab_foreground   #9ca3af
tab_bar_background        none
tab_bar_margin_color      none
color0                    #15171a
color1                    #f7768e
color2                    #9ece6a
color3                    #e0af68
color4                    #7aa2f7
color5                    #bb9af7
color6                    #73daca
color7                    #c0caf5
color8                    #414868
color9                    #ff899d
color10                   #a9dc76
color11                   #e9c46a
color12                   #8db0ff
color13                   #c7a0ff
color14                   #7fe8d2
color15                   #ffffff
PALETTE
        ;;
    purple)
        PALETTE_NAME="Roxo escuro"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Roxo escuro
background                #17111f
foreground                #eee7f7
selection_background      #3b2850
selection_foreground      #fff7ff
url_color                 #c4b5fd
cursor                    #e9d5ff
cursor_text_color         #17111f
active_border_color       #7c3aed
inactive_border_color     #2e1f3b
bell_border_color         #fb7185
visual_bell_color         none
active_tab_background     #2e1f3b
active_tab_foreground     #ffffff
inactive_tab_background   #21172b
inactive_tab_foreground   #b9a9c9
tab_bar_background        none
tab_bar_margin_color      none
color0                    #17111f
color1                    #fb7185
color2                    #86efac
color3                    #fcd34d
color4                    #a78bfa
color5                    #d8b4fe
color6                    #67e8f9
color7                    #eee7f7
color8                    #6b5a78
color9                    #fda4af
color10                   #bbf7d0
color11                   #fde68a
color12                   #c4b5fd
color13                   #e9d5ff
color14                   #a5f3fc
color15                   #ffffff
PALETTE
        ;;
    pastel)
        PALETTE_NAME="Pastel"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Pastel
background                #2b2633
foreground                #f5edf7
selection_background      #574b61
selection_foreground      #fffaff
url_color                 #a8c7fa
cursor                    #f9d5e5
cursor_text_color         #2b2633
active_border_color       #c4a7e7
inactive_border_color     #403847
bell_border_color         #eb6f92
visual_bell_color         none
active_tab_background     #4a4052
active_tab_foreground     #fffaff
inactive_tab_background   #352f3d
inactive_tab_foreground   #cfc4d7
tab_bar_background        none
tab_bar_margin_color      none
color0                    #2b2633
color1                    #eb6f92
color2                    #9ccfd8
color3                    #f6c177
color4                    #a8c7fa
color5                    #c4a7e7
color6                    #b7e4c7
color7                    #f5edf7
color8                    #6f6575
color9                    #f5a9bc
color10                   #b8e3e8
color11                   #f8d39a
color12                   #c5dbff
color13                   #d8c4f1
color14                   #c8edd5
color15                   #fffaff
PALETTE
        ;;
    pastel_blue)
        PALETTE_NAME="Pastel azul"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Pastel azul
background                #17212b
foreground                #e8f1f8
selection_background      #31536b
selection_foreground      #ffffff
url_color                 #8bd5ff
cursor                    #b7e3ff
cursor_text_color         #17212b
active_border_color       #6cb6e6
inactive_border_color     #243746
bell_border_color         #ff9fb3
visual_bell_color         none
active_tab_background     #294356
active_tab_foreground     #ffffff
inactive_tab_background   #1e2d39
inactive_tab_foreground   #afc3d2
tab_bar_background        none
tab_bar_margin_color      none
color0                    #17212b
color1                    #ff9fb3
color2                    #a9dfbf
color3                    #f5d69a
color4                    #8bd5ff
color5                    #d3b7f5
color6                    #9ee7e5
color7                    #e8f1f8
color8                    #536a79
color9                    #ffb9c8
color10                   #bdebd0
color11                   #f9e3b4
color12                   #b7e3ff
color13                   #e4d0fb
color14                   #b9f0ee
color15                   #ffffff
PALETTE
        ;;
    solarized_dark)
        PALETTE_NAME="Solarized escuro"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Solarized escuro
background                #002b36
foreground                #839496
selection_background      #073642
selection_foreground      #93a1a1
url_color                 #268bd2
cursor                    #93a1a1
cursor_text_color         #002b36
active_border_color       #586e75
inactive_border_color     #073642
bell_border_color         #dc322f
visual_bell_color         none
active_tab_background     #073642
active_tab_foreground     #eee8d5
inactive_tab_background   #002b36
inactive_tab_foreground   #657b83
tab_bar_background        none
tab_bar_margin_color      none
color0                    #073642
color1                    #dc322f
color2                    #859900
color3                    #b58900
color4                    #268bd2
color5                    #d33682
color6                    #2aa198
color7                    #eee8d5
color8                    #586e75
color9                    #cb4b16
color10                   #b4c342
color11                   #cb8b00
color12                   #4aa3df
color13                   #d55f9a
color14                   #35bdb1
color15                   #fdf6e3
PALETTE
        ;;
    solarized_light)
        PALETTE_NAME="Solarized claro"
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Solarized claro
background                #fdf6e3
foreground                #657b83
selection_background      #eee8d5
selection_foreground      #586e75
url_color                 #268bd2
cursor                    #586e75
cursor_text_color         #fdf6e3
active_border_color       #93a1a1
inactive_border_color     #eee8d5
bell_border_color         #dc322f
visual_bell_color         none
active_tab_background     #eee8d5
active_tab_foreground     #073642
inactive_tab_background   #fdf6e3
inactive_tab_foreground   #839496
tab_bar_background        none
tab_bar_margin_color      none
color0                    #073642
color1                    #dc322f
color2                    #859900
color3                    #b58900
color4                    #268bd2
color5                    #d33682
color6                    #2aa198
color7                    #eee8d5
color8                    #002b36
color9                    #cb4b16
color10                   #586e75
color11                   #657b83
color12                   #839496
color13                   #6c71c4
color14                   #93a1a1
color15                   #fdf6e3
PALETTE
        ;;
    *)
        warn "Paleta '$TERM_PALETTE' não reconhecida; usando Azul escuro."
        TERM_PALETTE="navy"
        PALETTE_NAME="Azul escuro"
        sed 's/paleta: .*/paleta: Azul escuro/' "$PALETTE_FILE" 2>/dev/null || true
        # Reentra na opção padrão sem recursão.
        cat > "$PALETTE_FILE" <<'PALETTE'
# Gerado pelo install.sh — paleta: Azul escuro
background                #0b1220
foreground                #dbeafe
selection_background      #1e3a5f
selection_foreground      #eff6ff
url_color                 #60a5fa
cursor                    #93c5fd
cursor_text_color         #0b1220
active_border_color       #2563eb
inactive_border_color     #172554
bell_border_color         #f87171
visual_bell_color         none
active_tab_background     #172554
active_tab_foreground     #eff6ff
inactive_tab_background   #0f1b31
inactive_tab_foreground   #93a4bd
tab_bar_background        none
tab_bar_margin_color      none
color0                    #0b1220
color1                    #ef4444
color2                    #22c55e
color3                    #f59e0b
color4                    #3b82f6
color5                    #a855f7
color6                    #06b6d4
color7                    #dbeafe
color8                    #475569
color9                    #f87171
color10                   #4ade80
color11                   #fbbf24
color12                   #60a5fa
color13                   #c084fc
color14                   #22d3ee
color15                   #f8fafc
PALETTE
        ;;
esac

STYLE_FILE="$CONFIG_DIR/kitty/transparency.conf"
if [ "$TERM_STYLE" = "solid" ]; then
    cat > "$STYLE_FILE" <<'STYLE'
# Gerado pelo install.sh — estilo: cor sólida
background_opacity 1.0
background_blur 0
dynamic_background_opacity no
STYLE
    STYLE_NAME="Cor sólida"
else
    cat > "$STYLE_FILE" <<'STYLE'
# Gerado pelo install.sh — estilo: cor translúcida
background_opacity 0.80
background_blur 18
dynamic_background_opacity yes
STYLE
    STYLE_NAME="Cor translúcida"
fi

ok "Terminal configurado: $STYLE_NAME + paleta $PALETTE_NAME."

# ---------- 4. garantir que $HOME/.local/bin está no PATH ----------
add_path_to_rc() {
    local rc="$1"
    [ -f "$rc" ] || return 0
    if grep -q '\.local/bin' "$rc" 2>/dev/null; then
        ok "\$HOME/.local/bin já está no PATH em $(basename "$rc")."
    else
        {
            echo ""
            echo "# adicionado pelo install.sh dos dotfiles"
            echo 'export PATH="$HOME/.local/bin:$PATH"'
        } >> "$rc"
        ok "\$HOME/.local/bin adicionado ao PATH em $(basename "$rc")."
    fi
}
add_path_to_rc "$HOME/.bashrc"
add_path_to_rc "$HOME/.zshrc"
export PATH="$BIN_DIR:$PATH"

# ---------- 5. carregar aliases + starship/zoxide/fzf no shell ----------
add_shellrc_source() {
    local rc="$1"
    [ -f "$rc" ] || return 0
    local line="[ -f \"$CONFIG_DIR/dotfiles-shell/shellrc.sh\" ] && source \"$CONFIG_DIR/dotfiles-shell/shellrc.sh\""
    if grep -q "dotfiles-shell/shellrc.sh" "$rc" 2>/dev/null; then
        ok "shellrc já está configurado em $(basename "$rc")."
    else
        {
            echo ""
            echo "# adicionado pelo install.sh dos dotfiles (aliases + starship/eza/bat/zoxide/fzf)"
            echo "$line"
        } >> "$rc"
        ok "shellrc adicionado ao $(basename "$rc")."
    fi
}

if [ "$SKIP_EXTRAS" = false ]; then
    link_config "$REPO_DIR/shell" "$CONFIG_DIR/dotfiles-shell"
    add_shellrc_source "$HOME/.bashrc"
    add_shellrc_source "$HOME/.zshrc"
fi

# ---------- 6. kitty como terminal padrão do sistema ----------
# Isso cobre três coisas separadas, cada uma checando se o mecanismo
# existe antes de mexer (nunca falha a instalação por causa disso):
#   a) xdg-terminal-exec — o jeito moderno/portável de dizer "abra um
#      terminal aqui", usado cada vez mais por gerenciadores de
#      arquivos e lançadores (freedesktop/xdg-terminal-exec spec)
#   b) update-alternatives (x-terminal-emulator) — Debian/Ubuntu e
#      derivados, só roda com sudo (modo "system")
#   c) gsettings do GNOME — a chave legada que o Nautilus/"Abrir
#      terminal aqui" ainda consulta em algumas versões
set_kitty_as_default_terminal() {
    echo ""
    info "Configurando o kitty como terminal padrão do sistema..."

    # a) xdg-terminal-exec: lista de preferência do usuário
    mkdir -p "$CONFIG_DIR"
    local xdg_list="$CONFIG_DIR/xdg-terminals.list"
    if [ -f "$xdg_list" ] && [ "$(head -n1 "$xdg_list" 2>/dev/null)" = "kitty.desktop" ]; then
        ok "kitty já é o primeiro da lista em xdg-terminals.list."
    else
        {
            echo "kitty.desktop"
            [ -f "$xdg_list" ] && grep -vx "kitty.desktop" "$xdg_list" 2>/dev/null || true
        } > "${xdg_list}.tmp"
        mv "${xdg_list}.tmp" "$xdg_list"
        ok "kitty definido como terminal preferido em $xdg_list (padrão xdg-terminal-exec)."
    fi

    # b) update-alternatives, só faz sentido com sudo de verdade
    if [ "$MODE" = "system" ] && command -v update-alternatives >/dev/null 2>&1; then
        if sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$KITTY_BIN" 50 2>/dev/null \
            && sudo update-alternatives --set x-terminal-emulator "$KITTY_BIN" 2>/dev/null; then
            ok "kitty definido como x-terminal-emulator (update-alternatives)."
        else
            warn "Não consegui registrar o kitty em update-alternatives (seguindo mesmo assim)."
        fi
    fi

    # c) GNOME: chave legada de terminal padrão, quando o schema existe
    if command -v gsettings >/dev/null 2>&1 \
        && gsettings list-schemas 2>/dev/null | grep -q '^org.gnome.desktop.default-applications.terminal$'; then
        gsettings set org.gnome.desktop.default-applications.terminal exec "$KITTY_BIN" 2>/dev/null || true
        gsettings set org.gnome.desktop.default-applications.terminal exec-arg '-e' 2>/dev/null || true
        ok "kitty definido como terminal padrão do GNOME (gsettings)."
    else
        info "Não encontrei a chave clássica de terminal do GNOME nesta versão/DE — normal em"
        info "GNOME recente e em outras área de trabalho (KDE, XFCE etc). O xdg-terminals.list"
        info "acima já cobre a maioria dos gerenciadores de arquivos modernos; se o 'Abrir"
        info "Terminal Aqui' do seu gerenciador de arquivos continuar abrindo outro terminal,"
        info "procure a opção equivalente nas configurações dele."
    fi
}
set_kitty_as_default_terminal

# ---------- 7. atalho do kitty na barra de tarefas (favoritos) ----------
pin_kitty_to_taskbar() {
    echo ""
    info "Fixando o kitty na barra de tarefas..."

    local desktop_id=""
    for candidate in \
        "$HOME/.local/share/applications/kitty.desktop" \
        "/usr/share/applications/kitty.desktop" \
        "/var/lib/flatpak/exports/share/applications/org.kovidgoyal.kitty.desktop"; do
        if [ -f "$candidate" ]; then
            desktop_id="$(basename "$candidate")"
            break
        fi
    done
    if [ -z "$desktop_id" ]; then
        warn "Não achei o arquivo .desktop do kitty — pulando o atalho na barra de tarefas."
        warn "(a barra ainda deve listar o kitty pelo menu de aplicativos normalmente)"
        return
    fi

    # GNOME Shell (o mais comum em labs Fedora/UFCG): favoritos ficam
    # numa lista só, em org.gnome.shell favorite-apps — adiciona o
    # kitty sem duplicar e sem apagar o que já tinha
    if command -v gsettings >/dev/null 2>&1 \
        && gsettings list-schemas 2>/dev/null | grep -q '^org.gnome.shell$'; then
        local current
        current="$(gsettings get org.gnome.shell favorite-apps 2>/dev/null || echo "[]")"
        if echo "$current" | grep -q "$desktop_id"; then
            ok "kitty já está fixado na barra de tarefas (GNOME favorites)."
        else
            local new
            if [ "$current" = "@as []" ] || [ "$current" = "[]" ]; then
                new="['$desktop_id']"
            else
                new="$(echo "$current" | sed "s/]$/, '$desktop_id']/")"
            fi
            if gsettings set org.gnome.shell favorite-apps "$new" 2>/dev/null; then
                ok "kitty fixado na barra de tarefas (GNOME favorites)."
            else
                warn "Não consegui fixar o kitty automaticamente na barra do GNOME."
            fi
        fi
        return
    fi

    warn "Não detectei o GNOME Shell (ou a chave favorite-apps) — pulando o passo automático."
    warn "Pra fixar na mão: abra o kitty uma vez, clique com o botão direito no ícone dele"
    warn "na barra de tarefas / dock e escolha \"Adicionar aos favoritos\" (ou equivalente"
    warn "no seu ambiente gráfico)."
}
pin_kitty_to_taskbar

echo ""
ok "Tudo pronto!"
if [ "$MODE" = "user" ]; then
    info "Tudo foi instalado em \$HOME/.local — nada fora da sua pasta pessoal foi tocado"
    info "(o passo de barra de tarefas/terminal padrão usa só configuração do seu usuário,"
    info "menos o update-alternatives, que só roda se você tiver sudo de verdade)."
    info "Abra um NOVO terminal (ou rode 'source ~/.bashrc') pra o PATH atualizado valer."
fi
info "Abra o kitty pelo menu de aplicativos, pela barra de tarefas ou rodando 'kitty'."
if [ "$SKIP_EXTRAS" = false ]; then
    info "Prompt (starship) e aliases (eza/bat/zoxide/fzf) já configurados — abra um novo shell."
fi
echo ""
