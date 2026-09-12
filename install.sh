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

echo "[4/6] Instalando plugins de tema/UI..."
clone_plugin catppuccin      https://github.com/catppuccin/vim.git
clone_plugin vim-airline           https://github.com/vim-airline/vim-airline.git
clone_plugin vim-airline-themes    https://github.com/vim-airline/vim-airline-themes.git
clone_plugin nerdtree               https://github.com/preservim/nerdtree.git
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
    echo "Tentando instalar a extensão coc-java automaticamente"
    echo "(isso pode demorar um pouco na primeira vez)..."
    if vim -es -u "$HOME/.vimrc" -c "try | call coc#add_extension('coc-java') | catch | endtry" \
        -c "sleep 15" -c "qa!" >/tmp/coc-java-install.log 2>&1; then
        echo "Feito (verifique com :CocList extensions dentro do vim)."
    else
        echo "Não deu pra confirmar a instalação automática."
        echo "Abra o vim e rode ':CocInstall coc-java' manualmente."
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
echo "  F4       Liga/desliga autocomplete"
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
echo "Se os ícones do NERDTree aparecerem como caixinhas, instale uma"
echo "Nerd Font (https://www.nerdfonts.com) e configure seu terminal."
echo
echo "Backup: ${BACKUP:-nenhum backup necessário}"
