#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Ícaro Vim Codeforces IDE — instalação 100% user-space
# ============================================================
# ESTE SCRIPT NUNCA USA sudo, su, doas, pkexec, dnf, apt ou
# qualquer gerenciador de pacotes do sistema.
# Tudo que ele instalar vai para o HOME do usuário.
# ============================================================

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$HOME/.vim"
PACK_DIR="$VIM_DIR/pack/plugins/opt"
ICARO_HOME="$HOME/.local/share/icaro-vim"
BIN_DIR="$HOME/.local/bin"
TOOLS_DIR="$ICARO_HOME/tools"
DOWNLOAD_DIR="$ICARO_HOME/downloads"
BACKUP="$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)"

NODE_VERSION="22.23.2"
CLANGD_VERSION="23.1.0"
JDK_MAJOR="21"

mkdir -p "$ICARO_HOME" "$BIN_DIR" "$TOOLS_DIR" "$DOWNLOAD_DIR"

say() { printf '\n\033[1;31m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mAVISO:\033[0m %s\n' "$*"; }
die() { printf '\033[1;31mERRO:\033[0m %s\n' "$*" >&2; exit 1; }

# Segurança: recusa explicitamente qualquer tentativa de elevação.
# Não existe chamada a sudo/su/doas/pkexec neste instalador.
if [ "$(id -u)" -eq 0 ]; then
    die "Não execute este instalador como root. Ele foi projetado para o seu usuário normal."
fi

# ------------------------------------------------------------
# Ferramentas auxiliares de download/extracao — todas user-space
# ------------------------------------------------------------
DOWNLOAD_CMD=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_CMD="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_CMD="wget"
elif command -v python3 >/dev/null 2>&1; then
    DOWNLOAD_CMD="python3"
else
    die "Preciso de curl, wget ou python3 para baixar dependências. Nenhum deles foi encontrado."
fi

have_cmd() { command -v "$1" >/dev/null 2>&1; }

fetch() {
    local url="$1"
    local out="$2"
    echo "Baixando: $url"
    case "$DOWNLOAD_CMD" in
        curl) curl -fL --retry 3 --retry-delay 2 -o "$out" "$url" ;;
        wget) wget -q --show-progress -O "$out" "$url" ;;
        python3)
            python3 - "$url" "$out" <<'PY'
import sys, urllib.request
url, out = sys.argv[1], sys.argv[2]
req = urllib.request.Request(url, headers={'User-Agent': 'Icaro-Vim-Installer/1.0'})
with urllib.request.urlopen(req, timeout=60) as r, open(out, 'wb') as f:
    while True:
        chunk = r.read(1024 * 1024)
        if not chunk: break
        f.write(chunk)
PY
            ;;
    esac
}

extract_tar_xz() {
    local archive="$1"
    local dest="$2"
    mkdir -p "$dest"
    if tar -xJf "$archive" -C "$dest" 2>/dev/null; then
        return 0
    fi
    have_cmd python3 || die "Não consegui extrair $archive e python3 não está disponível."
    python3 - "$archive" "$dest" <<'PY'
import sys, tarfile
with tarfile.open(sys.argv[1], 'r:xz') as t:
    t.extractall(sys.argv[2])
PY
}

extract_tar_gz() {
    local archive="$1"
    local dest="$2"
    mkdir -p "$dest"
    if tar -xzf "$archive" -C "$dest" 2>/dev/null; then
        return 0
    fi
    have_cmd python3 || die "Não consegui extrair $archive e python3 não está disponível."
    python3 - "$archive" "$dest" <<'PY'
import sys, tarfile
with tarfile.open(sys.argv[1], 'r:gz') as t:
    t.extractall(sys.argv[2])
PY
}

extract_zip() {
    local archive="$1"
    local dest="$2"
    mkdir -p "$dest"
    if have_cmd unzip; then
        unzip -q -o "$archive" -d "$dest"
    elif have_cmd python3; then
        python3 - "$archive" "$dest" <<'PY'
import sys, zipfile
with zipfile.ZipFile(sys.argv[1]) as z:
    z.extractall(sys.argv[2])
PY
    else
        die "Preciso de unzip ou python3 para extrair $archive."
    fi
}

# ------------------------------------------------------------
# Node.js — se faltar, instala o binário oficial no HOME.
# ------------------------------------------------------------
setup_node() {
    if have_cmd node && have_cmd npm; then
        NODE_BIN="$(command -v node)"
        NPM_BIN="$(command -v npm)"
        echo "Node já disponível: $($NODE_BIN --version)"
        return
    fi

    say "Node.js não encontrado (ou npm ausente). Instalando Node.js $NODE_VERSION no HOME..."
    local arch node_arch archive url target extracted
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) node_arch="x64" ;;
        aarch64|arm64) node_arch="arm64" ;;
        armv7l|armv7) node_arch="armv7l" ;;
        ppc64le) node_arch="ppc64le" ;;
        s390x) node_arch="s390x" ;;
        *) die "Arquitetura não suportada para o Node portátil: $arch" ;;
    esac

    archive="$DOWNLOAD_DIR/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz"
    url="https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-${node_arch}.tar.xz"
    [ -s "$archive" ] || fetch "$url" "$archive"

    rm -rf "$TOOLS_DIR/node-v${NODE_VERSION}-linux-${node_arch}"
    extract_tar_xz "$archive" "$TOOLS_DIR"
    target="$TOOLS_DIR/node-v${NODE_VERSION}-linux-${node_arch}"
    [ -x "$target/bin/node" ] || die "O Node foi baixado, mas o binário esperado não foi encontrado."

    ln -sfn "$target" "$ICARO_HOME/node"
    ln -sfn "$target/bin/node" "$BIN_DIR/node"
    ln -sfn "$target/bin/npm" "$BIN_DIR/npm"
    ln -sfn "$target/bin/npx" "$BIN_DIR/npx"
    NODE_BIN="$BIN_DIR/node"
    NPM_BIN="$BIN_DIR/npm"
    echo "Node portátil instalado: $($NODE_BIN --version)"
}

# ------------------------------------------------------------
# JDK — usa o sistema se houver javac; caso contrário baixa
# Eclipse Temurin via API oficial da Adoptium, sem instalar no OS.
# ------------------------------------------------------------
setup_jdk() {
    if have_cmd javac && have_cmd java; then
        JAVA_BIN="$(command -v java)"
        JAVAC_BIN="$(command -v javac)"
        JAVA_HOME_DETECTED=""
        if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/javac" ]; then
            JAVA_HOME_DETECTED="$JAVA_HOME"
        else
            JAVA_HOME_DETECTED="$(dirname "$(dirname "$(readlink -f "$JAVAC_BIN")")")"
        fi
        if "$JAVAC_BIN" -version 2>&1 | awk '{print $2}' | grep -Eq '^(17|18|19|20|21|22|23|24|25|26|27)'; then
            JAVA_HOME_LOCAL="$JAVA_HOME_DETECTED"
            echo "JDK já disponível: $($JAVAC_BIN -version 2>&1)"
            return
        fi
    fi

    say "JDK 17+ não encontrado. Instalando Eclipse Temurin $JDK_MAJOR no HOME..."
    local arch api archive extracted_dir
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) arch="x64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *) die "Arquitetura não suportada pelo JDK portátil: $(uname -m)" ;;
    esac

    archive="$DOWNLOAD_DIR/temurin-${JDK_MAJOR}-linux-${arch}.tar.gz"
    api="https://api.adoptium.net/v3/binary/latest/${JDK_MAJOR}/ga/linux/${arch}/jdk/hotspot/normal/eclipse"
    [ -s "$archive" ] || fetch "$api" "$archive"

    rm -rf "$TOOLS_DIR/jdk-extract"
    mkdir -p "$TOOLS_DIR/jdk-extract"
    extract_tar_gz "$archive" "$TOOLS_DIR/jdk-extract"
    extracted_dir="$(find "$TOOLS_DIR/jdk-extract" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
    [ -n "$extracted_dir" ] || die "Não consegui localizar o JDK extraído."

    rm -rf "$TOOLS_DIR/jdk"
    mv "$extracted_dir" "$TOOLS_DIR/jdk"
    rm -rf "$TOOLS_DIR/jdk-extract"
    ln -sfn "$TOOLS_DIR/jdk" "$ICARO_HOME/jdk"
    JAVA_HOME_LOCAL="$ICARO_HOME/jdk"
    JAVA_BIN="$JAVA_HOME_LOCAL/bin/java"
    JAVAC_BIN="$JAVA_HOME_LOCAL/bin/javac"
    echo "JDK portátil instalado: $($JAVAC_BIN -version 2>&1)"
}

# ------------------------------------------------------------
# clangd — usa o sistema se houver. Caso contrário baixa o
# binário oficial do projeto clangd, que é autocontido e foi
# publicado para Linux. O pacote Linux oficial requer glibc 2.18+.
# ------------------------------------------------------------
setup_clangd() {
    if have_cmd clangd; then
        CLANGD_BIN="$(command -v clangd)"
        echo "clangd já disponível: $($CLANGD_BIN --version | head -n 1)"
        return
    fi

    say "clangd não encontrado. Instalando clangd $CLANGD_VERSION no HOME..."
    local arch clang_arch archive url extract_root clang_path
    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) clang_arch="linux" ;;
        *) die "O instalador portátil inclui clangd oficial para Linux x86_64. Arquitetura detectada: $arch. Use o clangd do laboratório ou peça a versão correspondente." ;;
    esac

    if have_cmd getconf && getconf GNU_LIBC_VERSION >/dev/null 2>&1; then
        local glibc
        glibc="$(getconf GNU_LIBC_VERSION | awk '{print $2}')"
        if [ "$(printf '%s\n' "$glibc" '2.18' | sort -V | head -n1)" != '2.18' ]; then
            die "A glibc deste computador ($glibc) é antiga demais para o clangd portátil oficial (mínimo 2.18)."
        fi
    fi

    archive="$DOWNLOAD_DIR/clangd-linux-${CLANGD_VERSION}.zip"
    url="https://github.com/clangd/clangd/releases/download/${CLANGD_VERSION}/clangd-linux-${CLANGD_VERSION}.zip"
    [ -s "$archive" ] || fetch "$url" "$archive"

    rm -rf "$TOOLS_DIR/clangd-extract"
    mkdir -p "$TOOLS_DIR/clangd-extract"
    extract_zip "$archive" "$TOOLS_DIR/clangd-extract"
    clang_path="$(find "$TOOLS_DIR/clangd-extract" -type f -name clangd -perm -u+x | head -n 1)"
    [ -n "$clang_path" ] || die "O pacote do clangd foi baixado, mas o executável não foi localizado."

    rm -rf "$TOOLS_DIR/clangd"
    mv "$(dirname "$(dirname "$clang_path")")" "$TOOLS_DIR/clangd"
    ln -sfn "$TOOLS_DIR/clangd/bin/clangd" "$BIN_DIR/clangd"
    CLANGD_BIN="$BIN_DIR/clangd"
    echo "clangd portátil instalado: $($CLANGD_BIN --version | head -n 1)"
}

# ------------------------------------------------------------
# Plugins Vim: Git se existir; codeload HTTP se não existir.
# ------------------------------------------------------------
install_repo() {
    local name="${1:-}" url="${2:-}" branch="${3:-}" dest="$PACK_DIR/${1:-}"
    if [ -d "$dest" ]; then
        echo "$name já instalado."
        return
    fi

    mkdir -p "$PACK_DIR"
    if have_cmd git; then
        echo "Instalando $name via Git..."
        if [ -n "$branch" ]; then
            git clone --depth 1 --branch "$branch" "$url" "$dest"
        else
            git clone --depth 1 "$url" "$dest"
        fi
    else
        echo "Git não encontrado; usando download direto do GitHub para $name..."
        local repo archive extract_url temp_dir top
        repo="${url#https://github.com/}"
        repo="${repo%.git}"
        archive="$DOWNLOAD_DIR/${name}.tar.gz"
        if [ -n "$branch" ]; then
            extract_url="https://codeload.github.com/${repo}/tar.gz/refs/heads/${branch}"
        else
            extract_url="https://codeload.github.com/${repo}/tar.gz/HEAD"
        fi
        [ -s "$archive" ] || fetch "$extract_url" "$archive"
        temp_dir="$ICARO_HOME/plugin-extract-$name"
        rm -rf "$temp_dir"
        mkdir -p "$temp_dir"
        extract_tar_gz "$archive" "$temp_dir"
        top="$(find "$temp_dir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
        [ -n "$top" ] || die "Falha ao extrair $name."
        mv "$top" "$dest"
        rm -rf "$temp_dir"
    fi
}

say "Vim Codeforces IDE — instalação sem privilégios"

echo "HOME: $HOME"
echo "Tudo será instalado somente em: $HOME/.vim, $HOME/.local"
echo

if ! have_cmd vim; then
    die "Vim não está instalado. Por segurança, este instalador não altera o sistema nem instala pacotes do sistema. Use uma conta/ambiente que já tenha Vim."
fi

say "1/8 — preparando diretórios"
mkdir -p "$VIM_DIR/templates" "$VIM_DIR/config" "$PACK_DIR"

say "2/8 — backup da configuração"
if [ -f "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$BACKUP"
    echo "Backup: $BACKUP"
fi

say "3/8 — instalando dependências portáteis"
setup_node
setup_jdk
setup_clangd

say "4/8 — copiando configuração"
cp "$ROOT/vimrc" "$HOME/.vimrc"
cp "$ROOT/config/"*.vim "$VIM_DIR/config/"
cp "$ROOT/templates/cpp.cpp" "$VIM_DIR/templates/cpp.cpp"
cp "$ROOT/templates/java_main.java" "$VIM_DIR/templates/java_main.java"
cp "$ROOT/templates/java_cp.java" "$VIM_DIR/templates/java_cp.java"

# Gera settings com caminhos absolutos somente para as ferramentas locais.
# Se o usuário já tem ferramentas do sistema, apontamos para elas.
"$NODE_BIN" - "$ROOT/templates/coc-settings.json" "$VIM_DIR/coc-settings.json" "$CLANGD_BIN" "$JAVA_HOME_LOCAL" <<'NODEJS'
const fs = require('fs')
const [src, dst, clangd, javaHome] = process.argv.slice(2)
const data = JSON.parse(fs.readFileSync(src, 'utf8'))
data['clangd.path'] = clangd
data['java.jdt.ls.java.home'] = javaHome
fs.writeFileSync(dst, JSON.stringify(data, null, 2) + '\n')
NODEJS

say "5/8 — instalando plugins de interface"
if [ -d "$PACK_DIR/icaro-theme" ]; then rm -rf "$PACK_DIR/icaro-theme"; fi
cp -r "$ROOT/theme/icaro-theme" "$PACK_DIR/icaro-theme"
install_repo vim-airline https://github.com/vim-airline/vim-airline.git
install_repo vim-airline-themes https://github.com/vim-airline/vim-airline-themes.git
install_repo nerdtree https://github.com/preservim/nerdtree.git
install_repo vim-devicons https://github.com/ryanoasis/vim-devicons.git

say "6/8 — instalando coc.nvim"
install_repo coc.nvim https://github.com/neoclide/coc.nvim.git release

# O Vim deve encontrar Node/JDK/clangd mesmo quando o shell do laboratório
# não tiver essas ferramentas no PATH.
cat > "$VIM_DIR/config/portable-env.vim" <<'VIMENV'
" Gerado pelo instalador portátil — não requer privilégios.
let s:icaro_node = expand('~/.local/share/icaro-vim/node/bin')
let s:icaro_jdk = expand('~/.local/share/icaro-vim/jdk/bin')
let s:icaro_bin = expand('~/.local/bin')
if isdirectory(s:icaro_node)
  let $PATH = s:icaro_node . ':' . $PATH
endif
if isdirectory(s:icaro_jdk)
  let $PATH = s:icaro_jdk . ':' . $PATH
  let $JAVA_HOME = expand('~/.local/share/icaro-vim/jdk')
endif
if isdirectory(s:icaro_bin)
  let $PATH = s:icaro_bin . ':' . $PATH
endif
VIMENV

"$NODE_BIN" - "$HOME/.vimrc" <<'NODEJS'
const fs = require('fs')
const p = process.argv[2]
let s = fs.readFileSync(p, 'utf8')
const needle = '" Plugins (pacotes nativos do Vim, carregados em ordem controlada)'
if (!s.includes('source ~/.vim/config/portable-env.vim')) {
  s = s.replace(needle, 'source ~/.vim/config/portable-env.vim\n\n' + needle)
}
fs.writeFileSync(p, s)
NODEJS

say "7/8 — instalando extensões semânticas do coc"
export PATH="$BIN_DIR:$PATH"
export JAVA_HOME="$JAVA_HOME_LOCAL"
export PATH="$JAVA_HOME_LOCAL/bin:$PATH"

INSTALL_LOG="$ICARO_HOME/coc-install.log"
if timeout 600 vim -es -u "$HOME/.vimrc" \
    -c "CocInstall -sync coc-clangd coc-java coc-snippets coc-pairs" \
    -c "CocUpdateSync" -c "qa!" >"$INSTALL_LOG" 2>&1; then
    echo "Extensões coc instaladas/atualizadas."
else
    warn "A instalação automática das extensões encontrou um erro."
    warn "Log: $INSTALL_LOG"
    warn "Depois de abrir o Vim, rode: :CocInstall coc-clangd coc-java coc-snippets coc-pairs"
fi

say "8/8 — verificação final"
echo "Vim:    $(vim --version | head -n 1)"
echo "Node:   $($NODE_BIN --version)"
echo "npm:    $($NPM_BIN --version)"
echo "Java:   $($JAVA_BIN -version 2>&1 | head -n 1)"
echo "javac:  $($JAVAC_BIN -version 2>&1)"
echo "clangd: $($CLANGD_BIN --version | head -n 1)"

if have_cmd g++; then
    echo "g++:    $(g++ --version | head -n 1)"
else
    warn "g++ não encontrado. O IDE e o autocomplete funcionam, mas compilar C++ exige um g++ disponível no ambiente."
fi

cat > "$ICARO_HOME/environment.sh" <<'ENV'
# Ambiente local da Ícaro Vim Codeforces IDE.
export ICARO_VIM_HOME="$HOME/.local/share/icaro-vim"
export PATH="$HOME/.local/bin:$HOME/.local/share/icaro-vim/node/bin:$HOME/.local/share/icaro-vim/jdk/bin:$PATH"
export JAVA_HOME="$HOME/.local/share/icaro-vim/jdk"
ENV

cat > "$BIN_DIR/icaro-vim" <<'WRAPPER'
#!/usr/bin/env bash
export ICARO_VIM_HOME="$HOME/.local/share/icaro-vim"
if [ -d "$HOME/.local/share/icaro-vim/jdk" ]; then
  export JAVA_HOME="$HOME/.local/share/icaro-vim/jdk"
  export PATH="$HOME/.local/share/icaro-vim/jdk/bin:$PATH"
fi
if [ -d "$HOME/.local/share/icaro-vim/node/bin" ]; then
  export PATH="$HOME/.local/share/icaro-vim/node/bin:$PATH"
fi
export PATH="$HOME/.local/bin:$PATH"
exec vim "$@"
WRAPPER
chmod +x "$BIN_DIR/icaro-vim"

cat > "$ICARO_HOME/doctor.sh" <<'DOCTOR'
#!/usr/bin/env bash
set -u
BASE="$HOME/.local/share/icaro-vim"
BIN="$HOME/.local/bin"
echo "=== Ícaro Vim Doctor ==="
echo "Vim:    $(command -v vim || echo AUSENTE)"
echo "Node:   $([ -x "$BIN/node" ] && "$BIN/node" --version || command -v node || echo AUSENTE)"
echo "npm:    $([ -x "$BIN/npm" ] && "$BIN/npm" --version || command -v npm || echo AUSENTE)"
echo "Java:   $([ -x "$BASE/jdk/bin/java" ] && "$BASE/jdk/bin/java" -version 2>&1 | head -1 || command -v java || echo AUSENTE)"
echo "javac:  $([ -x "$BASE/jdk/bin/javac" ] && "$BASE/jdk/bin/javac" -version 2>&1 || command -v javac || echo AUSENTE)"
echo "clangd: $([ -x "$BIN/clangd" ] && "$BIN/clangd" --version | head -1 || command -v clangd || echo AUSENTE)"
echo "g++:    $(command -v g++ || echo AUSENTE)"
echo
printf 'Config: %s\n' "$HOME/.vimrc"
printf 'Coc:    %s\n' "$HOME/.vim/pack/plugins/opt/coc.nvim"
printf 'Logs:   %s\n' "$BASE/coc-install.log"
DOCTOR
chmod +x "$ICARO_HOME/doctor.sh"

say "Instalação concluída — sem privilégios"
echo
echo "Para abrir a IDE nesta máquina, use:"
echo "  $BIN_DIR/icaro-vim"
echo
echo "Se ~/.local/bin já estiver no PATH, também pode usar:"
echo "  icaro-vim"
echo
echo "Diagnóstico:"
echo "  $ICARO_HOME/doctor.sh"
echo
echo "Dentro do Vim:"
echo "  :CocInfo"
echo "  :JavaLogs"
echo "  :CocCommand clangd.symbolInfo"
echo
echo "Nenhum arquivo fora do seu HOME foi alterado pelo instalador."
echo "Nenhuma elevação de privilégio foi usada."
echo
echo "Backup: ${BACKUP:-nenhum backup necessário}"
