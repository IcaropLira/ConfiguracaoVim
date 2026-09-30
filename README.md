# Ícaro Lira Setup — kitty + tmux + Vim, tudo de uma vez

Pacote combinado com os três projetos:

- **[`dotfiles/`](dotfiles)** — kitty (terminal), definido como terminal padrão do sistema e
  fixado na barra de tarefas, + opcionalmente starship/eza/bat/zoxide/fzf
- **[`tmux/`](tmux)** — configuração de tmux, prefixo `Ctrl+A`
- **[`vim/`](vim)** — Vim para C++/Java/Python (competitive programming), com autocomplete
  (coc.nvim) individual por linguagem

Cada um funciona sozinho (tem seu próprio `install.sh`), mas o jeito mais simples é instalar tudo
de uma vez com o instalador combinado.

## Instalação

```bash
chmod +x install.sh
./install.sh
```

Isso pergunta **uma única vez** se você tem acesso a sudo e se quer o terminal **transparente**
ou **preto total, sem transparência** — nenhum dos três instaladores pergunta de novo — e instala kitty, tmux e Vim nessa ordem, com um resumo no final.

### Estilo do terminal sem perguntar

```bash
./install.sh --transparent   # translúcido, com blur
./install.sh --black         # preto total, sem transparência
```

Pra trocar depois, rode o instalador de novo ou edite `dotfiles/kitty/transparency.conf`.

### Sem acesso a sudo (PC de laboratório, ex: UFCG)

```bash
./install.sh --user
```

Pula a pergunta e instala **tudo** em `$HOME/.local`, sem nenhum comando precisando de root:

| Ferramenta | Como é instalada sem sudo |
|---|---|
| kitty | instalador oficial → `~/.local/kitty.app` |
| tmux | build estático oficial (tmux/tmux-builds) → `~/.local/bin` |
| Node.js (pro autocomplete do Vim) | build oficial LTS → `~/.local/node-icaro` |
| JDK (pra Java no Vim) | Eclipse Temurin (Adoptium) → `~/.local/jdk-icaro` |
| starship, eza, bat, zoxide, fzf | binários/scripts oficiais → `~/.local/bin` |
| Nerd Font | → `~/.local/share/fonts` |
| Plugins do Vim | `git clone` → `~/.vim/pack/...` (nunca precisa de sudo) |

Nada fora da sua `$HOME` é tocado — exceto pelos arquivos de configuração que você já espera que
mudem (`~/.bashrc`, `~/.zshrc`, `~/.vimrc`, `~/.tmux.conf`), sempre com **backup automático**
antes de qualquer sobrescrita.

### Com sudo

```bash
./install.sh --system
```

Usa o gerenciador de pacotes da distro (`dnf`/`apt`/`pacman`/`zypper`/`brew`) sempre que possível,
e só cai pro binário pré-compilado se o pacote falhar ou não existir no repositório da distro.

### Outras flags

```bash
./install.sh --no-font       # kitty: não instala a Nerd Font
./install.sh --no-extras     # kitty: não instala starship/eza/bat/zoxide/fzf
./install.sh --copy          # kitty: copia as configs em vez de criar symlinks
```

## kitty como terminal padrão

O instalador também:

1. Define o kitty como terminal padrão via `~/.config/xdg-terminals.list` (padrão moderno,
   funciona sem sudo) + `update-alternatives` (só com sudo de verdade) + a chave clássica do
   GNOME (`gsettings`, quando existir).
2. Fixa um atalho do kitty na **barra de tarefas** (GNOME Shell — o mais comum em labs Fedora).

Em ambientes gráficos diferentes de GNOME, o passo 2 avisa e não falha a instalação — é rápido
fazer na mão (clique direito no ícone do kitty → "Adicionar aos favoritos").

## Instalar só uma parte

Cada pasta tem seu próprio `install.sh` e pode ser usada sozinha:

```bash
cd vim && ./install.sh      # só o Vim
cd tmux && ./install.sh     # só o tmux
cd dotfiles && ./install.sh # só o kitty
```

Nesse caso, cada um pergunta sobre sudo na hora (não reaproveita a escolha dos outros).

## Estrutura

```
.
├── install.sh      # instalador combinado (este arquivo)
├── dotfiles/        # kitty + terminal padrão + barra de tarefas
├── tmux/             # configuração de tmux
└── vim/               # Vim (C++/Java/Python)
```

Veja o README de cada pasta para detalhes específicos (atalhos do Vim, customização do kitty,
prefixo do tmux, etc).
