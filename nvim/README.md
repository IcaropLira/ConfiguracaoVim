# Neovim — Configuração Ícaro Lira

A versão **Neovim** da config do Vim: mesmos atalhos (`F1`–`F12`), mesmos aliases (`:Th`, `:Cp`, `:Br`…), mesmos **45 temas**, mas com **LSP nativo**, **Treesitter**, completion moderno e uma interface mais completa. Feita para programação competitiva e desenvolvimento em **C++, Java e Python**.

## Instalar

```bash
./install.sh            # pela raiz: escolha "Neovim" ou "Os dois" no menu
# ou só o Neovim:
cd nvim && ./install.sh
```

O instalador baixa o Neovim (0.10+) para `~/.local` se faltar (sem sudo), liga `~/.config/nvim` a esta pasta (backup automático da config antiga), baixa os plugins, compila os parsers do Treesitter e instala os servidores LSP. Use `--copy` para copiar em vez de criar symlink e `--no-bootstrap` para deixar o download dos plugins para a primeira abertura.

Depois: abra `nvim`, aperte **F12** para ver todos os atalhos e rode `:IcaroDoctor` para conferir o que falta.

## Atalhos

| Tecla | Alias | O que faz |
|---|---|---|
| `F1` / `Shift+F1` | `:Th` / `:Pv` | próximo / anterior tema |
| `F13`–`F24` | — | equivalentes de `Shift+F1`–`Shift+F12` em terminais que não transmitem Shift diretamente |
| `F2` | `:Nt` | explorer (neo-tree) |
| `F3` | `:Ih` | inlay hints |
| `F4` | `:Ac` | autocomplete (estado separado para C++, Java e Python) |
| `F5` | `:Cp` | compilar |
| `F6` | `:Rn` | executar |
| `F7` | `:Br` | compilar + executar (Python: salvar + executar) |
| `F8` | `:Ti` | executar com `input.txt` |
| `F9` | `:Te` | terminal |
| `F10` | `:Pa` | fecha-pares + assinatura de método |
| `Shift+F10` | `:Mh` | destaque do par de parênteses |
| `Shift+F11` | `:Of` | **modo silencioso** |
| `Shift+F12` / `F24` | `:Hd` | mostra/esconde o header |
| `F12` | `:Cs` | folha de atalhos |

**Modo silencioso (`Shift+F11`)**: fecha popups e floats, desliga sugestões, assinatura, inlay hints, pares automáticos, diagnósticos (sinais, virtual text, sublinhado) e matchparen. Apertando de novo, **restaura exatamente os estados anteriores**.

**F5–F8**: o programa roda num terminal embutido. Enquanto ele executa, `Enter` vai para o `stdin`; depois que termina, `Enter` (ou `q`) fecha o terminal.

Outros: `Ctrl+S` salva, `Ctrl+H/J/K/L` navega entre janelas, `Tab`/`Shift+Tab` troca de buffer, `Alt+j/k` move linhas.

**Busca (`<leader>` = espaço):** `ff` arquivos, `fg` texto, `fb` buffers, `fr` recentes, `ft` temas com preview, `/` busca no arquivo.
**LSP:** `gd` `gD` `gr` `gi` `gy` `K` `<leader>rn` `<leader>ca` `<leader>f` `[d` `]d`, `<leader>xx` lista de diagnósticos.
**Git:** `]h` `[h` `<leader>hp` `<leader>hb`.

## O que vem a mais que o Vim

- **LSP nativo** (clangd, pyright, jdtls) instalado pelo Mason só se faltar e se o ambiente permitir (precisa de `npm` para o pyright e `java` para o jdtls). Arquivos `.cpp` soltos também ganham LSP.
- **Treesitter** para realce e indentação, e um "polimento" que adapta os temas antigos do Vim aos grupos novos do Neovim.
- **blink.cmp** (completion rápido), **Telescope**, **Trouble**, **gitsigns**, **which-key**, **lualine** com separadores Powerline, **bufferline**, **neo-tree**, tela inicial e guias de indentação.
- **Noice + nvim-notify** para command-line, mensagens, progresso do LSP e notificações flutuantes.
- **mini.indentscope** para destacar visualmente o bloco atual, **nvim-scrollbar** com diagnóstico/git/busca, **vim-illuminate** para referências e **todo-comments** para TODO/FIXME/NOTE.
- **6 temas extras** de plugins (Tokyo Night, Catppuccin, Kanagawa, Rosé Pine, Nightfox, Carbonfox), carregados só quando você chega neles com `F1`.
- Templates automáticos de `.cpp`, `.java` e `_cp.java`, igual ao Vim.

## Personalizar

- **Temas seus:** copie `lua/icaro/themes_local.lua.example` para `themes_local.lua` e liste `{ id, title, short, subtitle }`. O catálogo oficial está em `lua/icaro/catalog.lua`.
- **Sem Nerd Font:** abra com `ICARO_NERD_FONT=0 nvim` (usa ícones ASCII).
- O estado (tema, toggles, autocomplete por linguagem) fica salvo em `~/.local/state/nvim/icaro.json`.

## Estrutura

```
nvim/
├── init.lua
├── install.sh
└── lua/icaro/
    ├── core.lua        liga tudo (F-keys, aliases)
    ├── themes.lua      F1 / Shift+F1, catálogo, polimento de cores
    ├── toggles.lua     F3 F4 F10 Shift+F10/F11/F12 e o modo silencioso
    ├── runner.lua      F5–F8, terminal, templates
    ├── cheatsheet.lua  F12
    ├── lsp.lua         servidores e atalhos de LSP
    └── plugins/        ui, editor, lsp, completion, treesitter, colorschemes
```

## Problemas comuns

- **Servidores LSP não instalam (Mason):** o Mason consulta a API do GitHub, que limita requisições por IP (comum em rede de laboratório). Instale `clangd` pelo sistema, ou tente de novo depois: `:Mason`. O `:IcaroDoctor` mostra o que está faltando.
- **Sem `rg`:** instale o ripgrep para a busca de texto (`<leader>fg`).
- **Sem blur/ícones quebrados:** instale uma Nerd Font no terminal (o instalador do kitty já traz a JetBrainsMono Nerd Font).

### Ctrl+C e área de transferência

No modo visual, `Ctrl+C` agora copia a seleção diretamente para a área de transferência do sistema (`"+y`). A configuração também mantém `clipboard = unnamedplus` para integrar os registradores padrão ao clipboard.

Se `:checkhealth vim.provider` indicar que nenhum provider de clipboard está disponível, instale um no sistema:

- Wayland: `wl-clipboard` (`wl-copy`/`wl-paste`)
- X11: `xclip` ou `xsel`

## Correção do erro de inicialização

A configuração agora usa a API correta do `vim-illuminate` (`configure()` em vez de `setup()`). Isso evita o erro do lazy.nvim:

`attempt to call field 'setup' (a nil value)`

Também foram adicionados pequenos refinamentos visuais (cursorword, animações discretas, scrollbar/indentação e highlights de janela).
