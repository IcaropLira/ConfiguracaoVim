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


# ---------- menus interativos ----------
# Menu puro em Bash/ANSI: setas para navegar, Enter para confirmar.
# Não depende de dialog/whiptail e funciona nos terminais dos laboratórios.
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
            if [ "$i" -eq "$idx" ]; then
                printf '  \033[1;7m ❯ %-54s \033[0m\n' "${options[$i]}"
            else
                printf '    %-56s\n' "${options[$i]}"
            fi
        done
        echo
        echo "  ↑ ↓  navegar     ENTER  confirmar     ESC  voltar"
        IFS= read -rsn1 key || true
        if [ "$key" = $'\033' ]; then
            IFS= read -rsn2 rest || true
            key="$key$rest"
        fi
        case "$key" in
            $'\033[A'|$'\033[D') idx=$(( (idx - 1 + ${#options[@]}) % ${#options[@]} )) ;;
            $'\033[B'|$'\033[C') idx=$(( (idx + 1) % ${#options[@]} )) ;;
            "") MENU_INDEX="$idx"; return 0 ;;
            $'\033') return 1 ;;
        esac
    done
}

# Preview simples de uma cor RGB.
color_preview() {
    local rgb="$1" name="$2"
    printf '  \033[48;2;%sm   \033[0m  \033[38;2;%sm%s\033[0m\n' "$rgb" "$rgb" "$name"
}

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
TERM_PALETTE="${ICARO_TERM_PALETTE:-}" # "" | id de uma paleta (veja kitty/palettes.sh)

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
            echo "  --palette=...   escolhe a paleta (navy, midnight, graphite, purple, pastel, pastel_blue, solarized_dark, solarized_light, wine, forest, cyan, amber, indigo, pink, dracula, nord, gruvbox, tokyo, catppuccin, onedark, rosepine, monokai, ayu, everforest, kanagawa, oled, github, sunset)"
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
    select_menu "MODO DE INSTALAÇÃO" \
        "Instalação no usuário — sem sudo (recomendado para laboratório)" \
        "Instalação do sistema — usando sudo"
    if [ "$MENU_INDEX" -eq 1 ]; then MODE="system"; else MODE="user"; fi
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

# ---------- visualizer de inicialização (Neofetch / Fastfetch) ----------
VIS_CFG_DIR="$CONFIG_DIR/icaro-visualizer"
VIS_CFG="$VIS_CFG_DIR/config.sh"

fetch_fastfetch() {
    [ -n "$ARCH" ] || return 1
    local asset="fastfetch-linux-${ARCH}.tar.gz"
    local url="https://github.com/fastfetch-cli/fastfetch/releases/latest/download/${asset}"
    local tmp found
    tmp="$(mktemp -d)"
    if ! curl -fsSL -o "$tmp/fastfetch.tar.gz" "$url" 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    if ! tar xzf "$tmp/fastfetch.tar.gz" -C "$tmp" 2>/dev/null; then rm -rf "$tmp"; return 1; fi
    found="$(find "$tmp" -type f \( -path '*/usr/bin/fastfetch' -o -name fastfetch \) 2>/dev/null | head -n1)"
    [ -n "$found" ] || { rm -rf "$tmp"; return 1; }
    install -m 755 "$found" "$BIN_DIR/fastfetch"
    rm -rf "$tmp"
}

fetch_neofetch() {
    local tmp="$BIN_DIR/neofetch"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch -o "$tmp" || return 1
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$tmp" https://raw.githubusercontent.com/dylanaraps/neofetch/master/neofetch || return 1
    else return 1; fi
    chmod 755 "$tmp"
}

# Menu com setas. Não depende de dialog/whiptail: funciona nos terminais dos labs.
visualizer_menu() {
    local title="$1"; shift
    local -a options=("$@")
    local idx=0 key rest
    while true; do
        printf '\033[2J\033[H'
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  $title"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo
        local i
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$idx" ]; then
                printf '  \033[7m  ❯ %s  \033[0m\n' "${options[$i]}"
            else
                printf '      %s\n' "${options[$i]}"
            fi
        done
        echo
        echo "  ↑ ↓  navegar    ENTER  confirmar    ESC  voltar"
        IFS= read -rsn1 key || true
        if [ "$key" = $'\033' ]; then
            IFS= read -rsn2 rest || true
            key="$key$rest"
        fi
        case "$key" in
            $'\033[A') idx=$(( (idx - 1 + ${#options[@]}) % ${#options[@]} )) ;;
            $'\033[B') idx=$(( (idx + 1) % ${#options[@]} )) ;;
            "") VIS_MENU_INDEX="$idx"; return 0 ;;
            $'\033') return 1 ;;
        esac
    done
}

visualizer_color_picker() {
    local -a names=("Vermelho" "Laranja" "Amarelo" "Verde" "Ciano" "Azul" "Índigo" "Roxo" "Rosa" "Branco" "Cinza" "Dourado")
    local -a codes=(196 208 226 46 51 33 63 129 213 15 250 220)
    local idx=0 key rest
    while true; do
        printf '\033[2J\033[H'
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  COR DO VISUALIZER"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo
        printf '  Cor atual: \033[38;5;%sm████████████████████████████████\033[0m  %s\n' "${codes[$idx]}" "${names[$idx]}"
        echo
        printf '  \033[38;5;%sm████████████████████████████████████████████████████████\033[0m\n' "${codes[$idx]}"
        echo
        printf '  \033[38;5;%smÍcaro Lira  •  Linux  •  Vim  •  C++  •  Java  •  Python\033[0m\n' "${codes[$idx]}"
        echo
        echo "  ┌────────────────────────────────────────────────────────┐"
        printf '  │  %2d/12  %-46s │\n' "$((idx+1))" "${names[$idx]}"
        echo "  └────────────────────────────────────────────────────────┘"
        echo
        echo "  ← →  ou  ↑ ↓  mudar cor       ENTER  confirmar"
        IFS= read -rsn1 key || true
        if [ "$key" = $'\033' ]; then
            IFS= read -rsn2 rest || true
            key="$key$rest"
        fi
        case "$key" in
            $'\033[C'|$'\033[B') idx=$(( (idx + 1) % ${#names[@]} )) ;;
            $'\033[D'|$'\033[A') idx=$(( (idx - 1 + ${#names[@]}) % ${#names[@]} )) ;;
            "") break ;;
        esac
    done
    VIS_COLOR_NAME="${names[$idx]}"
    VIS_COLOR_CODE="${codes[$idx]}"
    VIS_FASTCOLOR="@${codes[$idx]}"
    case "$VIS_COLOR_CODE" in
        196) VIS_NEOCOLOR=1 ;; 208|226|220) VIS_NEOCOLOR=3 ;;
        46) VIS_NEOCOLOR=2 ;; 51) VIS_NEOCOLOR=6 ;;
        33|63) VIS_NEOCOLOR=4 ;; 129|213) VIS_NEOCOLOR=5 ;;
        15) VIS_NEOCOLOR=7 ;; 250) VIS_NEOCOLOR=8 ;; *) VIS_NEOCOLOR=4 ;;
    esac
}

write_visualizer_disabled() {
    mkdir -p "$VIS_CFG_DIR"
    cat > "$VIS_CFG" <<'CFG'
# Configuração do visualizer Ícaro Lira — gerada pelo instalador.
ICARO_VISUALIZER_ENABLED=0
ICARO_VISUALIZER_TYPE=none
ICARO_VISUALIZER_IMAGE=
ICARO_VISUALIZER_COLOR=15
ICARO_VISUALIZER_COLOR_NAME=Off
CFG
}

choose_visualizer() {
    mkdir -p "$VIS_CFG_DIR"

    # Primeira pergunta: nenhum visualizer significa literalmente nenhum comando
    # de neofetch/fastfetch executado ao abrir o shell.
    visualizer_menu "MOSTRAR VISUALIZER AO ABRIR O TERMINAL?" \
        "Não — não iniciar Fastfetch/Neofetch" \
        "Sim — configurar visualizer"
    local enabled="$VIS_MENU_INDEX"
    if [ "$enabled" -eq 0 ]; then
        write_visualizer_disabled
        ok "Visualizer desativado. Nenhum Fastfetch/Neofetch será iniciado."
        return
    fi

    visualizer_menu "ESCOLHA O VISUALIZER" \
        "Fastfetch — moderno e rápido" \
        "Neofetch — clássico"
    local visual_type="fastfetch"
    [ "$VIS_MENU_INDEX" -eq 1 ] && visual_type="neofetch"

    visualizer_menu "LOGO DO VISUALIZER" \
        "Logo padrão do sistema" \
        "Foto personalizada"
    local image=""
    if [ "$VIS_MENU_INDEX" -eq 1 ]; then
        while true; do
            echo
            read -e -rp "  Caminho da foto (.png/.jpg/.jpeg/.webp): " image
            image="${image/#\~/$HOME}"
            if [ -f "$image" ]; then break; fi
            warn "Arquivo não encontrado: $image"
        done
    fi

    visualizer_color_picker

    if [ "$visual_type" = "fastfetch" ]; then
        if ! command -v fastfetch >/dev/null 2>&1 && [ ! -x "$BIN_DIR/fastfetch" ]; then
            info "Instalando Fastfetch..."
            if [ "$MODE" = "system" ]; then install_pkg fastfetch >/dev/null 2>&1 || true; fi
            if ! command -v fastfetch >/dev/null 2>&1; then fetch_fastfetch || true; fi
        fi
        if ! command -v fastfetch >/dev/null 2>&1 && [ ! -x "$BIN_DIR/fastfetch" ]; then
            warn "Não consegui instalar o Fastfetch. Visualizer desativado."
            write_visualizer_disabled
            return
        fi
    else
        if ! command -v neofetch >/dev/null 2>&1 && [ ! -x "$BIN_DIR/neofetch" ]; then
            info "Instalando Neofetch..."
            if [ "$MODE" = "system" ]; then install_pkg neofetch >/dev/null 2>&1 || true; fi
            if ! command -v neofetch >/dev/null 2>&1; then fetch_neofetch || true; fi
        fi
        if ! command -v neofetch >/dev/null 2>&1 && [ ! -x "$BIN_DIR/neofetch" ]; then
            warn "Não consegui instalar o Neofetch. Visualizer desativado."
            write_visualizer_disabled
            return
        fi
    fi

    cat > "$VIS_CFG" <<CFG
# Configuração do visualizer Ícaro Lira — gerada pelo instalador.
ICARO_VISUALIZER_ENABLED=1
ICARO_VISUALIZER_TYPE=$visual_type
ICARO_VISUALIZER_IMAGE=$(printf '%q' "$image")
ICARO_VISUALIZER_COLOR=$VIS_COLOR_CODE
ICARO_VISUALIZER_COLOR_NAME=$(printf '%q' "$VIS_COLOR_NAME")
ICARO_VISUALIZER_FASTCOLOR=$VIS_FASTCOLOR
ICARO_VISUALIZER_NEOCOLOR=$VIS_NEOCOLOR
CFG
    ok "Visualizer configurado: $visual_type | ${VIS_COLOR_NAME}$( [ -n "$image" ] && printf ' | foto personalizada' || printf ' | logo padrão' )"
}

# ---------- 1. kitty ----------
install_tool kitty kitty fetch_kitty

# Caminho real do binário do kitty (pode ser o do sistema ou o de $HOME/.local/kitty.app,
# usado mais abaixo pra montar o Exec= do .desktop e do default-terminal).
KITTY_BIN="$(command -v kitty 2>/dev/null || echo "$BIN_DIR/kitty")"

# ---------- 1b. ferramentas extras (starship, eza, bat, zoxide, fzf) ----------
if [ "$SKIP_EXTRAS" = false ]; then
    echo ""
    select_menu "FERRAMENTAS EXTRAS" \
        "Sim — Starship, eza, bat, zoxide e fzf" \
        "Não — instalar somente a configuração principal"
    if [ "$MENU_INDEX" -eq 0 ]; then
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

# ---------- 3b. aparência do terminal: opacidade + blur + paleta ----------
# Seletor interativo com 3 aspectos independentes. Cada um é ajustado separadamente:
#   ↑ ↓ (ou TAB)  escolhe QUAL aspecto está sendo editado (marcado com ▶)
#   ← →           muda o valor do aspecto selecionado
#   ENTER         confirma tudo
# O preview usa o próprio terminal: OSC 10/11 muda foreground/background na hora e,
# se o remote control do kitty estiver ativo, a opacidade da janela também.
# shellcheck disable=SC1091
source "$REPO_DIR/kitty/palettes.sh"

OPACITY_VALUES=(1.00 0.95 0.90 0.85 0.80 0.75 0.70 0.60 0.50)
BLUR_VALUES=(0 6 12 18 24 32 48)

# hex "#rrggbb" -> "r;g;b"
hex_to_rgb() { local h="${1#\#}"; printf '%d;%d;%d' "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"; }

# Barra de posição: ●○○○○○ — mostra onde você está no conjunto inteiro.
position_dots() {
    local cur="$1" total="$2" i out=""
    for ((i = 0; i < total; i++)); do
        if [ "$i" -eq "$cur" ]; then out+="●"; else out+="·"; fi
    done
    printf '%s' "$out"
}

draw_appearance_picker() {
    local focus="$1" oi="$2" bi="$3" pi="$4"
    local line IFS_OLD="$IFS" i
    local -a f
    IFS='|' read -ra f <<< "${ICARO_PALETTES[$pi]}"
    IFS="$IFS_OLD"
    local bg="${f[2]}" fg="${f[3]}" opacity="${OPACITY_VALUES[$oi]}" blur="${BLUR_VALUES[$bi]}"
    local fgrgb bgrgb
    fgrgb="$(hex_to_rgb "$fg")"; bgrgb="$(hex_to_rgb "$bg")"

    # aplica preview real no terminal
    printf '\033]10;%s\007\033]11;%s\007' "$fg" "$bg" 2>/dev/null || true
    if command -v kitten >/dev/null 2>&1; then
        kitten @ set-background-opacity "$opacity" >/dev/null 2>&1 || true
    fi

    printf '\033[2J\033[H\033[38;2;%sm\033[48;2;%sm' "$fgrgb" "$bgrgb"
    printf '\n  \033[1mAPARÊNCIA DO TERMINAL\033[22m — ajuste cada item separadamente\n\n'

    local -a labels=("Opacidade" "Blur" "Paleta")
    local -a values=("${opacity}  ($(awk -v o="$opacity" 'BEGIN{printf "%d", o*100}')%)" "$blur" "${f[1]}")
    local -a idxs=("$oi" "$bi" "$pi")
    local -a totals=("${#OPACITY_VALUES[@]}" "${#BLUR_VALUES[@]}" "${#ICARO_PALETTES[@]}")
    for i in 0 1 2; do
        if [ "$i" -eq "$focus" ]; then
            printf '  \033[1;7m ▶ %-10s ◀ %-26s %2d/%-2d \033[27;22m\n' "${labels[$i]}" "${values[$i]}" "$((idxs[i] + 1))" "${totals[$i]}"
        else
            printf '      %-10s   %-26s %2d/%-2d\n' "${labels[$i]}" "${values[$i]}" "$((idxs[i] + 1))" "${totals[$i]}"
        fi
    done

    # visão geral do item selecionado
    printf '\n  Posição em "%s": ' "${labels[$focus]}"
    position_dots "${idxs[$focus]}" "${totals[$focus]}"
    printf '\n'

    if [ "$focus" -eq 2 ]; then
        # lista de paletas ao redor da atual (janela de 9), com indicador ❯
        local start=$((pi - 4)) end=$((pi + 4)) n="${#ICARO_PALETTES[@]}"
        [ "$start" -lt 0 ] && { end=$((end - start)); start=0; }
        [ "$end" -ge "$n" ] && { start=$((start - (end - n + 1))); end=$((n - 1)); }
        [ "$start" -lt 0 ] && start=0
        printf '\n'
        for ((i = start; i <= end; i++)); do
            local -a g
            IFS='|' read -ra g <<< "${ICARO_PALETTES[$i]}"
            IFS="$IFS_OLD"
            if [ "$i" -eq "$pi" ]; then
                printf '   \033[1m❯ %2d. %-20s\033[22m' "$((i + 1))" "${g[1]}"
            else
                printf '     %2d. %-20s' "$((i + 1))" "${g[1]}"
            fi
            printf '\033[48;2;%sm  \033[48;2;%sm  \033[48;2;%sm  \033[48;2;%sm  \033[48;2;%sm  \033[48;2;%sm  \033[48;2;%sm\n' \
                "$(hex_to_rgb "${g[2]}")" "$(hex_to_rgb "${g[7]}")" "$(hex_to_rgb "${g[8]}")" "$(hex_to_rgb "${g[9]}")" \
                "$(hex_to_rgb "${g[10]}")" "$(hex_to_rgb "${g[11]}")" "$(hex_to_rgb "${g[12]}")"
            printf '\033[38;2;%sm\033[48;2;%sm' "$fgrgb" "$bgrgb"
        done
    fi

    printf '\n  Amostra: '
    local k
    for k in 7 8 9 10 11 12; do
        printf '\033[48;2;%sm   \033[48;2;%sm ' "$(hex_to_rgb "${f[$k]}")" "$bgrgb"
    done
    printf '\n  C++   Java   Python   Vim   tmux   —   Fundo: %s  Opacidade: %s  Blur: %s\n' "${f[1]}" "$opacity" "$blur"
    printf '\n  \033[2m↑ ↓ / TAB  trocar de item     ← →  mudar o valor     ENTER  confirmar\033[22m\n'
    printf '\033[0m'
}

appearance_picker() {
    local focus=2 oi="$1" bi="$2" pi="$3" key rest
    while true; do
        draw_appearance_picker "$focus" "$oi" "$bi" "$pi"
        IFS= read -rsn1 key || true
        if [ "$key" = $'\033' ]; then
            IFS= read -rsn2 -t 0.05 rest || true
            key="$key$rest"
        fi
        case "$key" in
            $'\033[A') focus=$(( (focus + 2) % 3 )) ;;
            $'\033[B'|$'\t') focus=$(( (focus + 1) % 3 )) ;;
            $'\033[C'|$'\033[D')
                local d=1; [ "$key" = $'\033[D' ] && d=-1
                case "$focus" in
                    0) oi=$(( (oi + d + ${#OPACITY_VALUES[@]}) % ${#OPACITY_VALUES[@]} )) ;;
                    1) bi=$(( (bi + d + ${#BLUR_VALUES[@]}) % ${#BLUR_VALUES[@]} )) ;;
                    2) pi=$(( (pi + d + ${#ICARO_PALETTES[@]}) % ${#ICARO_PALETTES[@]} )) ;;
                esac ;;
            "") break ;;
        esac
    done
    # devolve o terminal ao estado normal; o kitty recarrega as cores do arquivo ao abrir
    printf '\033]110\007\033]111\007\033[0m\033[2J\033[H'
    PICK_OI="$oi"; PICK_BI="$bi"; PICK_PI="$pi"
}

# índice de um valor dentro de um array (o mais próximo para números)
index_of_palette() {
    local want="$1" i
    for i in "${!ICARO_PALETTES[@]}"; do
        [ "${ICARO_PALETTES[$i]%%|*}" = "$want" ] && { echo "$i"; return; }
    done
    echo 0
}
nearest_index() { # $1=valor, resto=lista
    local v="$1"; shift
    local best=0 bestd=999999 i=0 x d
    for x in "$@"; do
        d=$(awk -v a="$v" -v b="$x" 'BEGIN{d=(a-b)*1000; if(d<0)d=-d; printf "%d", d}')
        if [ "$d" -lt "$bestd" ]; then bestd="$d"; best="$i"; fi
        i=$((i + 1))
    done
    echo "$best"
}

# valores iniciais a partir dos parâmetros (se vierem) ou padrão
case "$TERM_STYLE" in
    solid|black) start_op="1.00"; start_blur=0 ;;
    trans90)     start_op="0.90"; start_blur=12 ;;
    trans70)     start_op="0.70"; start_blur=24 ;;
    trans80|transparent|"") start_op="0.80"; start_blur=18 ;;
    *)           start_op="0.80"; start_blur=18 ;;
esac
start_oi="$(nearest_index "$start_op" "${OPACITY_VALUES[@]}")"
start_bi="$(nearest_index "$start_blur" "${BLUR_VALUES[@]}")"
start_pi=0
[ -n "$TERM_PALETTE" ] && start_pi="$(index_of_palette "$TERM_PALETTE")"

if [ -z "$TERM_STYLE" ] || [ -z "$TERM_PALETTE" ]; then
    appearance_picker "$start_oi" "$start_bi" "$start_pi"
    TERM_OPACITY="${OPACITY_VALUES[$PICK_OI]}"
    TERM_BLUR="${BLUR_VALUES[$PICK_BI]}"
    PALETTE_LINE="${ICARO_PALETTES[$PICK_PI]}"
else
    TERM_OPACITY="${OPACITY_VALUES[$start_oi]}"
    TERM_BLUR="${BLUR_VALUES[$start_bi]}"
    PALETTE_LINE="${ICARO_PALETTES[$start_pi]}"
    if [ "$(index_of_palette "$TERM_PALETTE")" -eq 0 ] && [ "$TERM_PALETTE" != "navy" ]; then
        warn "Paleta '$TERM_PALETTE' não reconhecida; usando Azul escuro."
    fi
fi
[ "$TERM_OPACITY" = "1.00" ] && TERM_OPACITY="1.0"
[ "$TERM_OPACITY" = "1.0" ] && TERM_STYLE="solid" || TERM_STYLE="translucent"
IFS='|' read -ra _pal <<< "$PALETTE_LINE"; IFS=$' \t\n'
PALETTE_NAME="${_pal[1]}"

PALETTE_FILE="$CONFIG_DIR/kitty/current-theme.conf"
icaro_write_palette "$PALETTE_LINE" "$PALETTE_FILE"

STYLE_FILE="$CONFIG_DIR/kitty/transparency.conf"
cat > "$STYLE_FILE" <<STYLE
# Gerado pelo install.sh — aparência escolhida no seletor.
background_opacity $TERM_OPACITY
background_blur $TERM_BLUR
dynamic_background_opacity yes
STYLE
if [ "$TERM_STYLE" = "solid" ]; then STYLE_NAME="Cor sólida"; else STYLE_NAME="Translúcido ${TERM_OPACITY} + blur ${TERM_BLUR}"; fi

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

# ---------- 5. escolher visualizer de inicialização ----------
# ---- manipulação segura de ~/.bashrc / ~/.zshrc ----
# Regras: (1) toda edição é feita num arquivo temporário, (2) só substitui o rc se o
# shell aceitar a sintaxe do resultado, (3) blocos nossos ficam entre marcadores
# BEGIN/END, então remover/atualizar nunca deixa um `fi` ou `done` solto pra trás.
ICARO_BEGIN="# >>> ícaro-lira >>>"
ICARO_END="# <<< ícaro-lira <<<"

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

# Remove: (a) blocos entre marcadores; (b) formato antigo = comentário + UMA linha de source.
clean_icaro_blocks() {
    rc_apply_awk "$1" '
        index($0, "# >>> ícaro-lira >>>") { skip=1; next }
        skip && index($0, "# <<< ícaro-lira <<<") { skip=0; next }
        skip { next }
        legacy { legacy=0; if ($0 ~ /icaro-visualizer\/visualizer\.sh|dotfiles-shell\/shellrc\.sh/) next }
        /^# Configuração Ícaro Lira — (visualizer opcional de inicialização|shellrc)[[:space:]]*$/ { legacy=1; next }
        { print }
    '
}

# Remove chamadas soltas de fastfetch/neofetch SÓ quando estão na coluna 0 (fora de if/for).
remove_old_fetch_commands() {
    rc_apply_awk "$1" '!/^(fastfetch|neofetch)([[:space:]]|$)/ { print }'
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

# Adiciona UM bloco com marcadores contendo as linhas passadas.
add_icaro_block() {
    local rc="$1"; shift
    [ -f "$rc" ] || touch "$rc"
    {
        echo ""
        echo "$ICARO_BEGIN"
        printf '%s\n' "$@"
        echo "$ICARO_END"
    } >> "$rc"
}

# Se um rc antigo já estava quebrado (ex.: `fi` órfão deixado por versões anteriores), conserta primeiro.
repair_rc_syntax "$HOME/.bashrc" bash
repair_rc_syntax "$HOME/.zshrc" zsh

choose_visualizer
if grep -q 'ICARO_VISUALIZER_ENABLED=0' "$VIS_CFG" 2>/dev/null; then
    remove_old_fetch_commands "$HOME/.bashrc"
    remove_old_fetch_commands "$HOME/.zshrc"
fi

# Limpa blocos antigos antes de reescrever (evita duplicações e restos de versões anteriores).
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    clean_icaro_blocks "$rc"
done

mkdir -p "$CONFIG_DIR/icaro-visualizer"
link_config "$REPO_DIR/shell/visualizer.sh" "$CONFIG_DIR/icaro-visualizer/visualizer.sh"
if [ "$SKIP_EXTRAS" = false ]; then
    link_config "$REPO_DIR/shell" "$CONFIG_DIR/dotfiles-shell"
fi

for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    lines=("[ -f \"$CONFIG_DIR/icaro-visualizer/visualizer.sh\" ] && source \"$CONFIG_DIR/icaro-visualizer/visualizer.sh\"")
    if [ "$SKIP_EXTRAS" = false ]; then
        lines+=("[ -f \"$CONFIG_DIR/dotfiles-shell/shellrc.sh\" ] && source \"$CONFIG_DIR/dotfiles-shell/shellrc.sh\"")
    fi
    add_icaro_block "$rc" "${lines[@]}"
done

# Confere o resultado final; se algo ainda estiver quebrado, repara (com backup).
repair_rc_syntax "$HOME/.bashrc" bash
repair_rc_syntax "$HOME/.zshrc" zsh


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
