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

if ! command -v vim >/dev/null 2>&1; then
    echo "ERRO: Vim não encontrado."
    echo "Instale o Vim (de preferência 8.2+) antes de continuar."
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERRO: Git não encontrado."
    echo "Instale o Git antes de continuar."
    exit 1
fi

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

# g:icaro_use_nerd_font só é perguntado da primeira vez — depois disso
# o arquivo é seu, o install.sh nunca mais mexe nele.
if [ ! -f "$VIM_DIR/config/local.vim" ]; then
    NERD_FONT_ANSWER="n"
    if [ -t 0 ]; then
        echo
        echo "Você já tem uma Nerd Font instalada e configurada no seu"
        echo "terminal? (ex: FiraCode Nerd Font, JetBrainsMono Nerd Font)"
        echo "Isso ativa ícones no NERDTree e setinhas 'powerline' na"
        echo "statusline. Se não tiver certeza, responda 'n' — dá pra"
        echo "mudar depois editando ~/.vim/config/local.vim."
        read -r -p "Nerd Font instalada? [s/N]: " NERD_FONT_ANSWER || true
    else
        echo "(sem terminal interativo, presumindo que você NÃO tem uma"
        echo "Nerd Font — dá pra mudar depois em ~/.vim/config/local.vim)"
    fi
    if [[ "$NERD_FONT_ANSWER" =~ ^[sSyY] ]]; then
        sed 's/g:icaro_use_nerd_font = 0/g:icaro_use_nerd_font = 1/' \
            "$ROOT/config/local.vim.example" > "$VIM_DIR/config/local.vim"
        echo "Ok, ícones e setinhas 'powerline' ativados."
    else
        cp "$ROOT/config/local.vim.example" "$VIM_DIR/config/local.vim"
        echo "Ok, usando ícones/separadores simples (sem depender de fonte especial)."
    fi
else
    echo "config/local.vim já existe, mantendo sua preferência de fonte."
fi

clone_plugin () {
    local name="$1"
    local url="$2"
    local branch="${3:-}"
    if [ ! -d "$PACK_DIR/$name" ]; then
        echo "Instalando $name..."
        if [ -n "$branch" ]; then
            git clone --branch "$branch" --depth 1 "$url" "$PACK_DIR/$name"
        else
            git clone --depth 1 "$url" "$PACK_DIR/$name"
        fi
    else
        echo "$name já instalado (pulando)."
    fi
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

echo "[6/6] Verificando ambiente..."
echo

echo -n "Vim: "
vim --version | head -n 1

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
    if timeout 180 vim -es -u "$HOME/.vimrc" -c "CocInstall -sync coc-java" -c "qa!" \
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
