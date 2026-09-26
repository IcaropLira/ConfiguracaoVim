#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$HOME/.vim"
PACK_DIR="$VIM_DIR/pack/plugins/opt"
BACKUP="$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)"

echo "=========================================="
echo "   Vim Codeforces / Java IDE - Instalação"
echo "          Configuração Ícaro Lira"
echo "=========================================="
echo

if ! command -v vim >/dev/null 2>&1 && [ ! -x /usr/bin/vim ] && [ ! -x /usr/local/bin/vim ]; then
    echo "ERRO: Vim não encontrado."
    echo "Instale o Vim (de preferência 8.2+) antes de continuar."
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERRO: Git não encontrado."
    echo "Instale o Git antes de continuar."
    exit 1
fi

# Guarda SEMPRE o Vim real. Nunca guarda ~/.local/bin/vim, porque esse
# arquivo é o nosso wrapper e chamar o wrapper a partir dele causaria
# recursão infinita na segunda instalação.
ICARO_VIM_REAL_FILE="$HOME/.local/share/icaro-vim/real-vim"
mkdir -p "$(dirname "$ICARO_VIM_REAL_FILE")"
ICARO_VIM_REAL=""
if [ -f "$ICARO_VIM_REAL_FILE" ] && [ -x "$(cat "$ICARO_VIM_REAL_FILE" 2>/dev/null)" ]; then
    candidate="$(cat "$ICARO_VIM_REAL_FILE")"
    case "$candidate" in
        "$HOME/.local/bin/vim") ;;
        *) ICARO_VIM_REAL="$candidate" ;;
    esac
fi

if [ -z "$ICARO_VIM_REAL" ]; then
    for candidate in /usr/bin/vim /usr/local/bin/vim /usr/bin/vim.basic /usr/bin/vim.nox; do
        if [ -x "$candidate" ]; then
            ICARO_VIM_REAL="$candidate"
            break
        fi
    done
fi

if [ -z "$ICARO_VIM_REAL" ]; then
    ICARO_VIM_REAL="$(command -v vim)"
fi

printf '%s\n' "$ICARO_VIM_REAL" > "$ICARO_VIM_REAL_FILE"

echo "[1/6] Criando diretórios..."
mkdir -p "$VIM_DIR/templates"
mkdir -p "$VIM_DIR/config"
mkdir -p "$PACK_DIR"

echo "[2/6] Fazendo backup da configuração atual..."
if [ -f "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$BACKUP"
    echo "Backup criado em:"
    echo "  $BACKUP"
fi

echo "[3/6] Copiando configuração e templates..."
cp "$ROOT/vimrc" "$HOME/.vimrc"
cp "$ROOT/config/"*.vim "$VIM_DIR/config/"
cp "$ROOT/templates/cpp.cpp" "$VIM_DIR/templates/cpp.cpp"
cp "$ROOT/templates/java_main.java" "$VIM_DIR/templates/java_main.java"
cp "$ROOT/templates/java_cp.java" "$VIM_DIR/templates/java_cp.java"

# coc-settings.json controla o comportamento do autocomplete (estilo
# Eclipse/VSCode). Só copia se você ainda não tiver um, pra não
# sobrescrever customizações suas em reinstalações.
if [ ! -f "$VIM_DIR/coc-settings.json" ]; then
    cp "$ROOT/templates/coc-settings.json" "$VIM_DIR/coc-settings.json"
else
    echo "coc-settings.json já existe, mantendo o seu."
fi

# A instalação é propositalmente "SIM por padrão": no laboratório você
# não precisa ficar respondendo perguntas. A Nerd Font é instalada no
# espaço do próprio usuário, então não precisa de sudo.
install_nerd_font () {
    local font_dir="$HOME/.local/share/fonts/JetBrainsMonoNerdFont"
    local marker="$font_dir/.icaro_installed"
    local tmp="${TMPDIR:-/tmp}/icaro_jetbrains_nerd_font.zip"

    if [ -f "$marker" ]; then
        echo "Nerd Font já instalada (JetBrainsMono Nerd Font)."
        return 0
    fi

    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        echo "AVISO: curl/wget não encontrado; não foi possível baixar a Nerd Font."
        return 1
    fi
    if ! command -v unzip >/dev/null 2>&1; then
        echo "AVISO: unzip não encontrado; não foi possível instalar a Nerd Font."
        return 1
    fi

    echo "Instalando JetBrainsMono Nerd Font no usuário (sem sudo)..."
    mkdir -p "$font_dir"
    if command -v curl >/dev/null 2>&1; then
        if ! curl -L --fail --silent --show-error \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
            -o "$tmp"; then
            rm -f "$tmp"
            return 1
        fi
    else
        if ! wget -q --show-progress \
            "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" \
            -O "$tmp"; then
            rm -f "$tmp"
            return 1
        fi
    fi
    if ! unzip -oq "$tmp" -d "$font_dir"; then
        rm -f "$tmp"
        return 1
    fi
    rm -f "$tmp"
    touch "$marker"

    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f "$font_dir" >/dev/null 2>&1 || true
    fi

    # Se for GNOME Terminal, já seleciona a fonte automaticamente.
    # Em outros terminais a fonte fica instalada e o Vim usa os glifos
    # normalmente quando o terminal escolher uma Nerd Font.
    if command -v gsettings >/dev/null 2>&1 && \
       gsettings writable org.gnome.Terminal.Legacy.ProfilesList default >/dev/null 2>&1; then
        local profile
        profile="$(gsettings get org.gnome.Terminal.Legacy.ProfilesList default 2>/dev/null | tr -d "'")"
        if [ -n "$profile" ] && [ "$profile" != "@as []" ]; then
            local schema="org.gnome.Terminal.Legacy.Profile:$profile"
            gsettings set "$schema" use-system-font false >/dev/null 2>&1 || true
            gsettings set "$schema" font 'JetBrainsMono Nerd Font 11' >/dev/null 2>&1 || true
        fi
    fi

    echo "Nerd Font instalada."
    return 0
}

if install_nerd_font; then
    NERD_FONT_ENABLED=1
else
    NERD_FONT_ENABLED=0
    echo "Usando fallback sem Nerd Font nesta instalação."
fi

# Sempre tenta deixar a configuração pronta para Powerline. Se o download
# da fonte falhar, o Vim cai automaticamente para os símbolos CTERM.
sed -e "s/g:icaro_use_nerd_font = 1/g:icaro_use_nerd_font = $NERD_FONT_ENABLED/" \
    -e "s/g:icaro_powerline = 1/g:icaro_powerline = $NERD_FONT_ENABLED/" \
    "$ROOT/config/local.vim.example" > "$VIM_DIR/config/local.vim"


clone_plugin () {
    local name="$1"
    local url="$2"
    local branch="${3:-}"
    if [ -d "$PACK_DIR/$name" ]; then
        echo "$name já instalado (pulando)."
        return 0
    fi

    echo "Instalando $name..."
    if [ -n "$branch" ]; then
        if git clone --branch "$branch" --depth 1 "$url" "$PACK_DIR/$name"; then
            return 0
        fi
    else
        if git clone --depth 1 "$url" "$PACK_DIR/$name"; then
            return 0
        fi
    fi

    echo "AVISO: não consegui instalar $name."
    echo "       O Vim continuará funcionando com os recursos disponíveis."
    rm -rf "$PACK_DIR/$name"
    return 0
}

echo "[4/6] Instalando tema (preto + vermelho) e plugins de UI..."
if [ ! -d "$PACK_DIR/icaro-theme" ]; then
    echo "Instalando icaro-theme..."
    cp -r "$ROOT/theme/icaro-theme" "$PACK_DIR/icaro-theme"
else
    echo "icaro-theme já instalado (atualizando)..."
    rm -rf "$PACK_DIR/icaro-theme"
    cp -r "$ROOT/theme/icaro-theme" "$PACK_DIR/icaro-theme"
fi
clone_plugin vim-airline           https://github.com/vim-airline/vim-airline.git
clone_plugin vim-airline-themes    https://github.com/vim-airline/vim-airline-themes.git
clone_plugin nerdtree               https://github.com/preservim/nerdtree.git
clone_plugin nerdtree-git-plugin    https://github.com/Xuyuanp/nerdtree-git-plugin.git
clone_plugin vim-fugitive           https://github.com/tpope/vim-fugitive.git
clone_plugin vim-devicons           https://github.com/ryanoasis/vim-devicons.git

echo "[5/6] Instalando motor de autocomplete (coc.nvim)..."
clone_plugin coc.nvim https://github.com/neoclide/coc.nvim.git release

echo "[6/7] Instalando proteção do terminal..."

# Wrapper seguro para o laboratório. Ele NÃO chama "stty sane" (que pode
# destruir configurações personalizadas do terminal) e guarda/restaura o
# estado original do TTY. Depois que o Vim termina, reseta foreground e
# background do terminal e limpa a tela. O reset OSC acontece DEPOIS do Vim,
# não durante VimLeavePre, evitando o bug do retângulo preto.
ICARO_BIN="$HOME/.local/bin"
mkdir -p "$ICARO_BIN"
ICARO_WRAPPER="$ICARO_BIN/vim"

cat > "$ICARO_WRAPPER" <<EOF
#!/bin/sh
# ICARO_VIM_WRAPPER
REAL_VIM="$ICARO_VIM_REAL"

TTY_STATE=""
if [ -t 0 ]; then
    TTY_STATE="\$(stty -g 2>/dev/null || true)"
fi

"\$REAL_VIM" "\$@"
status=\$?

if [ -n "\$TTY_STATE" ]; then
    stty "\$TTY_STATE" 2>/dev/null || true
fi

# Restaura cores padrão do terminal e limpa a tela inteira.
printf '\033]110\a\033]111\a\033[0m\033[?25h\033[2J\033[H' 2>/dev/null || true

exit \$status
EOF
chmod +x "$ICARO_WRAPPER"

for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] || [ "$(basename "$rc")" = ".bashrc" ]; then
        if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$rc" 2>/dev/null; then
            printf '\n# Configuração Ícaro Lira — wrappers locais\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$rc"
        fi
    fi
done

export PATH="$HOME/.local/bin:$PATH"

echo "Wrapper instalado: $ICARO_WRAPPER"
echo "O Vim abre direto e restaura o terminal automaticamente ao sair."
echo

echo "[7/7] Verificando ambiente..."
echo

echo -n "Vim: "
"$ICARO_VIM_REAL" --version | head -n 1

echo -n "Git: "
git --version

if command -v g++ >/dev/null 2>&1; then
    echo -n "g++: "
    g++ --version | head -n 1
else
    echo "AVISO: g++ não encontrado. Os atalhos de C++ só funcionarão"
    echo "       depois que o compilador for instalado."
fi

if command -v javac >/dev/null 2>&1; then
    echo -n "javac: "
    javac --version
else
    echo "AVISO: JDK não encontrado. Instale um JDK (17+) para usar Java."
fi

NODE_OK=0
if command -v node >/dev/null 2>&1; then
    echo -n "node: "
    node --version
    NODE_OK=1
else
    echo "AVISO: Node.js não encontrado. O coc.nvim (autocomplete) NÃO vai"
    echo "       funcionar sem o Node.js instalado. Instale-o e rode este"
    echo "       script de novo, ou apenas abra o vim depois de instalar."
fi

if [ "$NODE_OK" -eq 1 ]; then
    echo
    echo "Pré-instalando a extensão coc-java (pode demorar bastante na"
    echo "primeira vez, pois baixa o Eclipse JDT Language Server)..."
    if timeout 180 "$ICARO_VIM_REAL" -es -u "$HOME/.vimrc" -c "CocInstall -sync coc-java" -c "qa!" \
        >/tmp/coc-java-install.log 2>&1; then
        echo "coc-java instalado."
    else
        echo "Não deu tempo de terminar aqui, sem problema: a configuração"
        echo "já está com 'g:coc_global_extensions' ativo, então o coc.nvim"
        echo "termina a instalação sozinho automaticamente na primeira vez"
        echo "que você abrir o vim de verdade (log em /tmp/coc-java-install.log)."
    fi
fi

echo
echo "=========================================="
echo "       Instalação concluída!"
echo "=========================================="
echo
echo "Abra:"
echo "  vim"
echo
echo "Atalhos principais:"
echo "  F2       Explorer (NERDTree)"
echo "  F3       Liga/desliga só as dicas de parâmetro inline"
echo "  F4       Liga/desliga o autocomplete (persistente)"
echo "  F5       Compilar"
echo "  F6       Executar"
echo "  F7       Compilar + executar"
echo "  F8       Testar com input.txt"
echo "  F9       Terminal"
echo "  Ctrl+S   Salvar"
echo "  Ctrl+H/J/K/L   Navegar entre janelas"
echo "  Tab / Shift+Tab   Próximo/anterior buffer"
echo "  Esc      Limpar highlight da busca"
echo
echo "Java: crie um arquivo Nome.java para o template padrão, ou"
echo "      Nome_cp.java para o template de programação competitiva."
echo
echo "Mudou de ideia sobre a Nerd Font depois? Edite:"
echo "  ~/.vim/config/local.vim"
echo
echo "Se você usa tmux e as cores ficarem estranhas/lavadas, adicione"
echo "ao seu ~/.tmux.conf e reinicie o tmux:"
echo '  set -g default-terminal "tmux-256color"'
echo '  set -ga terminal-overrides ",*:RGB"'
echo
echo "Backup: ${BACKUP:-nenhum backup necessário}"
