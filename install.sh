#!/usr/bin/env bash
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VIM_DIR="$HOME/.vim"

echo "==> Instalando configuração Vim Codeforces"

if ! command -v vim >/dev/null 2>&1; then
    echo "ERRO: Vim não encontrado."
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "ERRO: Git não encontrado."
    exit 1
fi

mkdir -p "$VIM_DIR/templates" "$VIM_DIR/config"
mkdir -p "$VIM_DIR/pack/themes/start"
mkdir -p "$VIM_DIR/pack/plugins/start"

echo "==> Copiando configuração"
cp "$ROOT/vimrc" "$VIM_DIR/vimrc"
cp "$ROOT/config/"*.vim "$VIM_DIR/config/"
cp "$ROOT/templates/cpp.cpp" "$VIM_DIR/templates/cpp.cpp"

echo "==> Instalando Catppuccin"
if [ ! -d "$VIM_DIR/pack/themes/start/catppuccin" ]; then
    git clone --depth 1 https://github.com/catppuccin/vim.git \
        "$VIM_DIR/pack/themes/start/catppuccin"
else
    echo "    Catppuccin já instalado."
fi

echo "==> Instalando Airline"
if [ ! -d "$VIM_DIR/pack/plugins/start/vim-airline" ]; then
    git clone --depth 1 https://github.com/vim-airline/vim-airline.git \
        "$VIM_DIR/pack/plugins/start/vim-airline"
else
    echo "    Airline já instalado."
fi

echo "==> Instalando temas do Airline"
if [ ! -d "$VIM_DIR/pack/plugins/start/vim-airline-themes" ]; then
    git clone --depth 1 https://github.com/vim-airline/vim-airline-themes.git \
        "$VIM_DIR/pack/plugins/start/vim-airline-themes"
else
    echo "    Airline themes já instalado."
fi

echo
echo "==> Verificando compilador"
if command -v g++ >/dev/null 2>&1; then
    echo "    g++ encontrado: $(g++ --version | head -n 1)"
else
    echo "    AVISO: g++ não encontrado. O Vim será instalado, mas F5-F8 não funcionarão até haver um compilador."
fi

echo
echo "=========================================="
echo " Instalação concluída!"
echo "=========================================="
echo
echo "Abra com:"
echo "    vim"
echo
echo "Atalhos:"
echo "    F5  compilar"
echo "    F6  executar"
echo "    F7  compilar + executar"
echo "    F8  testar com input.txt"
echo "    F9  terminal"
echo
