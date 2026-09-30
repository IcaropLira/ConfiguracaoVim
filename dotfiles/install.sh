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
#                    [--transparent | --black]
#    --transparent  terminal translúcido (com blur)
#    --black        terminal preto total, sem transparência
#    (sem nenhum dos dois, o instalador pergunta)
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
TERM_STYLE="${ICARO_TERM_STYLE:-}"   # "" | transparent | black — idem

for arg in "$@"; do
    case "$arg" in
        --user)         FORCE_MODE="user" ;;
        --system)       FORCE_MODE="system" ;;
        --no-packages)  FORCE_MODE="user" ;;  # compatibilidade com versões antigas
        --no-font)      SKIP_FONT=true ;;
        --no-extras)    SKIP_EXTRAS=true ;;
        --copy)         NO_SYMLINK=true ;;
        --transparent)  TERM_STYLE="transparent" ;;
        --black)        TERM_STYLE="black" ;;
        -h|--help)
            echo "Uso: ./install.sh [--user] [--system] [--no-font] [--no-extras] [--copy]"
            echo "  --user          instala tudo em \$HOME/.local, sem sudo (ideal pra PCs de laboratório)"
            echo "  --system        usa o gerenciador de pacotes do sistema (precisa de sudo)"
            echo "  --no-font       não instala a JetBrainsMono Nerd Font"
            echo "  --no-extras     não instala starship/eza/bat/zoxide/fzf"
            echo "  --copy          copia os arquivos de config em vez de criar symlinks"
            echo "  --transparent   terminal transparente (com blur)"
            echo "  --black         terminal preto total, sem transparência"
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

# ---------- 3b. estilo do terminal: transparente ou preto total ----------
if [ -z "$TERM_STYLE" ]; then
    echo ""
    echo "Como você quer o terminal?"
    echo "  1) Transparente (translúcido, com blur atrás)"
    echo "  2) Preto total, sem transparência"
    read -rp "Escolha [1/2] (padrão: 1) " resp_style || resp_style=""
    case "${resp_style:-1}" in
        2|p|P|b|B) TERM_STYLE="black" ;;
        *)         TERM_STYLE="transparent" ;;
    esac
fi

STYLE_FILE="$CONFIG_DIR/kitty/transparency.conf"
if [ "$TERM_STYLE" = "black" ]; then
    cat > "$STYLE_FILE" <<'STYLE'
# Gerado pelo install.sh — estilo do terminal: preto total, sem transparência
# (pra trocar: rode o install.sh de novo, ou edite os valores abaixo)
background #000000
background_opacity 1.0
background_blur 0
STYLE
    ok "Terminal configurado: preto total, sem transparência."
else
    cat > "$STYLE_FILE" <<'STYLE'
# Gerado pelo install.sh — estilo do terminal: transparente
# (pra trocar: rode o install.sh de novo, ou edite os valores abaixo)
background_opacity 0.78
background_blur 20
STYLE
    ok "Terminal configurado: transparente (opacidade 0.78 + blur)."
fi

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
