#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$HOME/.vim"
BACKUP="$HOME/.vimrc.backup.$(date +%Y%m%d_%H%M%S)"

echo "=========================================="
echo "     Vim Codeforces IDE - Instalação"
echo "=========================================="
echo

if ! command -v vim >/dev/null 2>&1; then
    echo "ERRO: Vim não encontrado."
    echo "Instale o Vim antes de continuar."
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERRO: Git não encontrado."
    echo "Instale o Git antes de continuar."
    exit 1
fi

echo "[1/5] Criando diretórios..."
mkdir -p "$VIM_DIR/templates"
mkdir -p "$VIM_DIR/config"
mkdir -p "$VIM_DIR/pack/themes/start"
mkdir -p "$VIM_DIR/pack/plugins/start"

echo "[2/5] Fazendo backup da configuração atual..."
if [ -f "$HOME/.vimrc" ]; then
    cp "$HOME/.vimrc" "$BACKUP"
    echo "Backup criado em:"
    echo "  $BACKUP"
fi

echo "[3/5] Copiando configuração..."
cp "$ROOT/vimrc" "$HOME/.vimrc"
cp "$ROOT/config/"*.vim "$VIM_DIR/config/"
cp "$ROOT/templates/cpp.cpp" "$VIM_DIR/templates/cpp.cpp"

echo "[4/5] Instalando Catppuccin..."
if [ ! -d "$VIM_DIR/pack/themes/start/catppuccin" ]; then
    git clone --depth 1 https://github.com/catppuccin/vim.git \
        "$VIM_DIR/pack/themes/start/catppuccin"
else
    echo "Catppuccin já instalado."
fi

echo "[5/5] Instalando Airline..."
if [ ! -d "$VIM_DIR/pack/plugins/start/vim-airline" ]; then
    git clone --depth 1 https://github.com/vim-airline/vim-airline.git \
        "$VIM_DIR/pack/plugins/start/vim-airline"
else
    echo "vim-airline já instalado."
fi

if [ ! -d "$VIM_DIR/pack/plugins/start/vim-airline-themes" ]; then
    git clone --depth 1 https://github.com/vim-airline/vim-airline-themes.git \
        "$VIM_DIR/pack/plugins/start/vim-airline-themes"
else
    echo "vim-airline-themes já instalado."
fi

echo
echo "=========================================="
echo "          Verificação do ambiente"
echo "=========================================="

echo -n "Vim: "
vim --version | head -n 1

echo -n "Git: "
git --version

if command -v g++ >/dev/null 2>&1; then
    echo -n "g++: "
    g++ --version | head -n 1
else
    echo "AVISO: g++ não encontrado."
    echo "F5-F8 só funcionarão depois que o compilador for instalado."
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
echo "  F2       Explorer"
echo "  F5       Compilar"
echo "  F6       Executar"
echo "  F7       Compilar + executar"
echo "  F8       Testar com input.txt"
echo "  F9       Terminal"
echo "  Ctrl+S   Salvar"
echo "  Ctrl+H   Navegar para janela à esquerda"
echo "  Ctrl+J   Navegar para baixo"
echo "  Ctrl+K   Navegar para cima"
echo "  Ctrl+L   Navegar para direita"
echo "  Esc      Limpar highlight da busca"
echo
echo "Backup: ${BACKUP:-nenhum backup necessário}"
