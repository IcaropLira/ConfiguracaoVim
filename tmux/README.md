# TMUX Ícaro Lira

Configuração portátil e completa do tmux para Fedora/Linux.

## Instalação

```bash
./install.sh
```

**Funciona mesmo sem sudo** (comum em labs, como os da UFCG): se o `tmux` não estiver instalado
e você não tiver acesso a root, o instalador baixa um **build estático oficial**
([tmux/tmux-builds](https://github.com/tmux/tmux-builds)) pra `~/.local/bin`, sem compilar nada
e sem tocar em nada fora da sua pasta pessoal. Com sudo, tenta primeiro o gerenciador de pacotes
da distro (`dnf`/`apt`/`pacman`/`zypper`/`brew`) e só cai pro build estático se isso falhar.

O instalador faz backup do `~/.tmux.conf` existente.

Também faz parte de um [pacote maior](..) com kitty e Vim — o `install.sh` combinado na raiz
pergunta sobre sudo uma única vez para os três.

## Cores (truecolor)

`terminal-overrides` já cobre `xterm-256color`, `xterm-kitty` e, por segurança, qualquer terminal
`*256col*` com `Tc` — a maioria dos terminais modernos, mesmo os que não anunciam suporte a
truecolor por conta própria. Isso evita cores "lavadas" dentro do tmux em terminais fora do kitty.

## Prefixo

O prefixo padrão foi alterado de `Ctrl+B` para:

```text
Ctrl+A
```

## Atalhos principais

### Painéis

| Atalho | Ação |
|---|---|
| `Ctrl+A \|` | dividir verticalmente |
| `Ctrl+A \=` | dividir verticalmente |
| `Ctrl+A -` | dividir horizontalmente |
| `Ctrl+A h/j/k/l` | navegar |
| `Alt + setas` | navegar sem prefixo |
| `Ctrl+A H/J/K/L` | redimensionar |
| `Alt+Shift+setas` | redimensionar |
| `Ctrl+A z` | maximizar/restaurar |
| `Ctrl+A Space` | próximo layout |
| `Ctrl+A x` | fechar painel |
| `Ctrl+A q` | sincronizar/desincronizar painéis |

### Janelas

| Atalho | Ação |
|---|---|
| `Ctrl+A c` | nova janela no diretório atual |
| `Ctrl+A Tab` | última janela |
| `Ctrl+A n` | próxima |
| `Ctrl+A p` | anterior |
| `Ctrl+Shift+←/→` | trocar janela |
| `Ctrl+A ,` | renomear janela |
| `Ctrl+A 1..9` | ir para janela |

### Geral

| Atalho | Ação |
|---|---|
| `Ctrl+A r` | recarregar configuração |
| `Ctrl+A ?` | abrir central de ajuda |
| `Ctrl+A d` | detach |
| `Ctrl+A [` | copy mode |
| `Ctrl+Shift+Space` | mostrar/esconder barra |

## Copy mode

O copy mode usa teclas estilo Vim:

```text
Esc       entrar
v         iniciar seleção
Ctrl+V    seleção retangular
y         copiar
Esc       cancelar
```

## Visual

A barra inferior mostra:

```text
TMUX ÍCARO LIRA | janelas | sessão | host | data | hora
```

O painel ativo fica destacado e cada painel mostra seu número, título e diretório.

## Filosofia

- Sem plugins obrigatórios.
- Funciona em instalação limpa de Fedora.
- Adequado para computadores de laboratório.
- Configuração concentrada em um único `~/.tmux.conf`.
- Backup automático durante instalação.
