# dotfiles — kitty + starship

Configuração pessoal do [kitty](https://sw.kovidgoyal.net/kitty/) (terminal, com visual
translúcido e cursor animado), com tema **Adwaita Dark**, fonte **JetBrains Mono Nerd Font**, e
opcionalmente um prompt ([starship](https://starship.rs/)) + CLIs modernas (`eza`, `bat`,
`zoxide`, `fzf`) já configuradas.

**Funciona mesmo sem acesso a sudo** — o instalador baixa binários prontos e instala tudo em
`~/.local`, o que cobre laboratórios de faculdade e outras máquinas onde você não é root
(testado pensando em labs como os da UFCG).

Também deixa o **kitty como terminal padrão do sistema** (pro "Abrir terminal aqui" do seu
gerenciador de arquivos abrir ele) e cria um **atalho fixado na barra de tarefas**.

## Preview

- Terminal bem translúcido (`background_opacity 0.78` + `background_blur`), padding generoso,
  cursor beam com **trilha animada** (`cursor_trail`) e abas em estilo powerline arredondado.
  Decoração nativa da janela (título + botões de minimizar/maximizar/fechar) continua ligada.
- Prompt do starship com segmentos coloridos (usuário, diretório, git, linguagem do projeto).
- `ls`/`ll`/`la`/`lt` via `eza` (ícones), `cat` via `bat` (syntax highlight), `cd` mais esperto
  via `zoxide`, e busca fuzzy no histórico com `Ctrl+R` via `fzf`.

## Instalação rápida

```bash
git clone https://github.com/SEU_USUARIO/dotfiles.git
cd dotfiles
chmod +x install.sh
./install.sh
```

O `install.sh`:

1. **Pergunta se você tem acesso a sudo.** Se não tiver (ou passar `--user`), **nada** é
   instalado com privilégios de root: kitty, starship, eza, bat, zoxide e fzf são baixados
   prontos direto do GitHub e instalados em `~/.local/bin` / `~/.local/kitty.app` — só tocando
   na sua própria pasta. **Funciona em PCs de laboratório sem sudo (ex: labs da UFCG).**
2. Se você tiver sudo (ou passar `--system`), usa o gerenciador de pacotes da distro
   (`pacman`, `apt`, `dnf`, `zypper` ou `brew`); se um pacote falhar ou não existir no repositório,
   cai automaticamente para o binário pré-compilado, sem travar a instalação.
3. Pergunta se você quer instalar também **starship**, **eza**, **bat**, **zoxide** e **fzf**.
4. Baixa e instala a **JetBrainsMono Nerd Font** em `~/.local/share/fonts` (nunca precisa de sudo).
5. Faz **backup** de qualquer config existente em `~/.config/kitty`, `~/.config/starship.toml` e
   `~/.config/dotfiles-shell` (salva como `.bak-<data>`) e cria **symlinks** apontando pra este
   repositório — então dar `git pull` no repo já atualiza sua config.
6. Garante que `~/.local/bin` está no seu `PATH` (adiciona ao `.bashrc`/`.zshrc` se preciso).
7. Se você instalou os extras, adiciona uma linha no `.bashrc`/`.zshrc` que carrega
   `shell/shellrc.sh` — é ali que ficam os aliases do `eza`/`bat` e a inicialização do
   `starship`/`zoxide`/`fzf`.
8. **Define o kitty como terminal padrão do sistema** (veja a seção abaixo) e **fixa um atalho
   dele na barra de tarefas** (GNOME Shell — em outros ambientes, faz na mão em poucos cliques).

### Instalando sem sudo (PC de laboratório, servidor compartilhado, etc.)

```bash
./install.sh --user
```

Isso pula completamente a pergunta sobre sudo e instala tudo em `~/.local`:

| Ferramenta | Como é instalada sem sudo |
|---|---|
| `kitty` | instalador oficial (`sw.kovidgoyal.net/kitty/installer.sh`) → `~/.local/kitty.app`, com link em `~/.local/bin` |
| `eza`, `bat`, `fzf` | binário pré-compilado baixado do GitHub Releases (`.tar.gz`) → `~/.local/bin` |
| `starship`, `zoxide` | scripts oficiais de instalação, apontados pra `~/.local/bin` |
| Nerd Font | sempre foi instalada em `~/.local/share/fonts`, com ou sem sudo |

Nada é escrito fora da sua `$HOME` — nenhum arquivo em `/usr`, `/etc` nem pacotes do sistema são
tocados. Um bônus: o `kitty` ainda aparece no menu de aplicativos, porque o `.desktop` file é
copiado pra `~/.local/share/applications`, que também não precisa de root.

### Flags opcionais

```bash
./install.sh --user          # instala tudo em ~/.local, sem sudo (ideal pra labs)
./install.sh --system        # usa o gerenciador de pacotes do sistema (precisa de sudo)
./install.sh --no-font       # não baixa a Nerd Font
./install.sh --no-extras     # não instala/configura starship, eza, bat, zoxide, fzf
./install.sh --copy          # copia os arquivos em vez de criar symlink
```

Sem nenhuma dessas duas primeiras flags, o script pergunta interativamente se você tem sudo.

## kitty como terminal padrão + barra de tarefas

O instalador tenta três coisas, cada uma checando se o mecanismo existe antes de mexer (nunca
falha a instalação por causa disso):

1. **`~/.config/xdg-terminals.list`** — o jeito moderno/portável (spec `xdg-terminal-exec`) de
   dizer "abra este terminal aqui", cada vez mais usado por gerenciadores de arquivos e
   lançadores. Funciona sem sudo.
2. **`update-alternatives --set x-terminal-emulator`** — Debian/Ubuntu e derivados. Só roda com
   sudo de verdade (modo `--system`).
3. **`gsettings`** — a chave clássica de terminal padrão do GNOME, quando a versão instalada
   ainda tem esse schema.

Pra fixar o kitty na **barra de tarefas**, o instalador usa `gsettings set org.gnome.shell
favorite-apps` (GNOME Shell — o mais comum em labs Fedora, como os da UFCG), sem duplicar nem
apagar o que já estava fixado. Se seu ambiente gráfico não for o GNOME Shell (KDE, XFCE etc), o
script avisa e não falha — é só clicar com o botão direito no ícone do kitty na barra/dock depois
de abri-lo uma vez e escolher "Adicionar aos favoritos" (ou equivalente).

Se o "Abrir Terminal Aqui" do seu gerenciador de arquivos continuar abrindo outro terminal depois
da instalação, procure a opção de terminal padrão nas configurações dele — cada gerenciador de
arquivos decide de um jeito ligeiramente diferente qual desses três mecanismos ele escuta.

## Estrutura

```
dotfiles/
├── install.sh              # instalador
├── kitty/
│   ├── kitty.conf           # config principal do kitty
│   └── current-theme.conf   # tema Adwaita Dark
├── starship/
│   └── starship.toml        # prompt (segmentos com paleta Adwaita Dark)
└── shell/
    └── shellrc.sh           # aliases (eza/bat) + init do starship/zoxide/fzf
```

## Customizando

- **Cores do terminal**: edite `kitty/current-theme.conf`, ou troque de tema com
  `kitten themes` (kitty já vem com um seletor de temas embutido).
- **Fonte**: mude `font_family` em `kitty/kitty.conf` (por padrão `JetBrainsMono Nerd Font`).
- **Transparente ou preto total**: o `install.sh` pergunta (ou use `--transparent` / `--black`) e
  grava a escolha em `kitty/transparency.conf`, que o `kitty.conf` inclui por último. Edite esse
  arquivo (`background_opacity`, `background_blur`, `background`) pra ajustar depois.
- **Transparência**: `background_opacity` em `kitty/transparency.conf` (0.0 a 1.0; quanto menor, mais
  translúcido) e `background_blur` (força do desfoque atrás da janela — só funciona no macOS e
  no Linux com GNOME/KDE em Wayland).
- **Cursor animado**: `cursor_trail`, `cursor_trail_decay` e `cursor_trail_start_threshold` em
  `kitty/kitty.conf` controlam a trilha que segue o cursor ao mover.
- **Decoração da janela**: por padrão a barra de título nativa (com os botões de
  minimizar/maximizar/fechar) fica ligada. Só desative com `hide_window_decorations` se
  realmente não precisar dos botões — com essa opção ligada eles somem e o comportamento em
  tela cheia muda, porque é o gerenciador de janelas quem desenha essa moldura.

## Publicando no GitHub

```bash
cd dotfiles
git init
git add .
git commit -m "dotfiles: kitty + starship"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/dotfiles.git
git push -u origin main
```

Depois disso, qualquer pessoa pode instalar sua config com os três comandos da seção
"Instalação rápida" lá em cima.

## Ferramentas extras incluídas

O `install.sh` oferece instalar e já deixar configurado:

| Ferramenta | O que faz | Onde fica configurado |
|---|---|---|
| [`starship`](https://starship.rs/) | Prompt de shell rápido, com segmentos de usuário/diretório/git/linguagem | `starship/starship.toml` |
| [`eza`](https://github.com/eza-community/eza) | Substitui o `ls` (ícones, cores, árvore) — aliases `ls`, `ll`, `la`, `lt` | `shell/shellrc.sh` |
| [`bat`](https://github.com/sharkdp/bat) | Substitui o `cat` com syntax highlighting | `shell/shellrc.sh` |
| [`zoxide`](https://github.com/ajeetdsouza/zoxide) | `cd` mais esperto — aprende os diretórios mais usados (alias `cd`) | `shell/shellrc.sh` |
| [`fzf`](https://github.com/junegunn/fzf) | Busca fuzzy (`Ctrl+R` no histórico, `Ctrl+T` pra arquivos) | `shell/shellrc.sh` |

Pra pular tudo isso na instalação, use `./install.sh --no-extras` ou responda `n` quando o
instalador perguntar. Pra instalar depois, é só rodar `./install.sh` de novo.

Bash e zsh já são detectados automaticamente pelo `shell/shellrc.sh` — fish não é suportado
ainda, mas dá pra adaptar o `shellrc.sh` fácil se você usar fish.

## Parte de um pacote maior

Este repositório também pode ser instalado junto com a [configuração de
tmux](../tmux) e o [Vim para C++/Java/Python](../vim) — veja o `install.sh` combinado na raiz do
pacote, que pergunta sobre sudo **uma única vez** pros três.

## Licença

MIT — use, modifique e distribua à vontade.
