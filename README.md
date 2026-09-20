# Vim Codeforces / Java IDE — Configuração Ícaro Lira

Configuração portátil de **Vim para programação competitiva e desenvolvimento em Java**, pensada principalmente para **Codeforces, OBI, maratonas, exercícios de algoritmos em C++ e Java**.

A ideia é transformar o Vim em um pequeno IDE: tema bonito, números de linha, statusline, explorer em árvore com ícones, autocomplete tipo IDE (com toggle rápido), templates automáticos, compilação rápida, execução, testes com `input.txt`, terminal e atalhos para navegação.

---

# 1. O que essa configuração possui?

## Interface

- Tema próprio **preto + vermelho** (`icaro`), moderno e escuro — construído do zero pra essa configuração (veja seção 13)
- `vim-airline` para uma statusline completa: modo atual, git branch (se `vim-fugitive`/similar existir), nome do arquivo, indicador de autocomplete, posição do cursor, tudo combinando com o tema
- Barra de buffers (`tabline`) no topo, estilo abas de IDE
- Números de linha (absoluto + relativo)
- Linha atual destacada
- Separadores de janelas estilizados
- Winbar quando suportada pela versão do Vim
- Menu de autocomplete (popup) estilizado combinando com o tema
- True Color, com correção específica para funcionar dentro do tmux
- Mouse habilitado
- Clipboard do sistema

## Explorer de arquivos (estilo IDE)

- `NERDTree` como painel lateral de arquivos, com `vim-devicons` (ícones por tipo de arquivo)
- Atalho único (`F2`) pra abrir/fechar

## Autocomplete "de verdade" (estilo IDE)

- `coc.nvim` como motor de autocomplete (LSP), com suporte a Java via `coc-java`
- Ir para definição, ver referências, documentação ao passar o cursor (`K`), renomear símbolo
- **Liga/desliga com uma tecla** (`F4`), com indicador visual permanente na statusline mostrando se está ligado ou desligado

## Programação competitiva / desenvolvimento

- Template automático para `.cpp` e para `.java` (dois templates de Java: um "estilo IDE" e um de programação competitiva — veja seção 6)
- Compilação C++ com:

```bash
g++ -std=c++17 -O2 -Wall -Wextra
```

- Compilação/execução Java com `javac`/`java`
- Execução rápida
- Compilar + executar com uma tecla
- Teste automático usando `input.txt`
- Terminal integrado
- Navegação rápida entre janelas

---

# 2. Instalação rápida

## Método recomendado

Primeiro obtenha o projeto:

```bash
git clone <SEU_REPOSITORIO>
cd vim-codeforces-ide
```

Depois torne o instalador executável:

```bash
chmod +x install.sh
```

Execute:

```bash
./install.sh
```

Depois:

```bash
vim
```

**Não é necessário `sudo` para instalar a configuração do Vim.**

O instalador copia tudo para:

```text
~/.vim/
~/.vimrc
```

Também cria automaticamente um backup do seu `.vimrc` anterior, caso exista.

---

# 3. Se Vim, Git, g++, JDK ou Node.js não estiverem instalados

O projeto foi pensado para Linux.

Além do Vim, Git e g++ (para C++), você também vai precisar de:

- **JDK** (17 ou mais recente) — para compilar/executar Java e para o `coc-java` funcionar
- **Node.js** — obrigatório para o `coc.nvim` (o motor de autocomplete). Sem Node.js, o autocomplete simplesmente não liga, mas o resto da configuração continua funcionando normalmente.

## Ubuntu / Debian / Linux Mint

```bash
sudo apt update
sudo apt install vim git g++ default-jdk nodejs npm
```

Depois confira:

```bash
vim --version
git --version
g++ --version
javac --version
node --version
```

---

## Fedora

```bash
sudo dnf install vim git gcc-c++ java-17-openjdk-devel nodejs npm
```

Confira:

```bash
vim --version
git --version
g++ --version
javac --version
node --version
```

---

## Arch Linux / Manjaro

```bash
sudo pacman -S vim git gcc jdk-openjdk nodejs npm
```

Confira:

```bash
vim --version
git --version
g++ --version
javac --version
node --version
```

---

# 4. Instalação manual completa

Se você não quiser usar `install.sh`, pode instalar tudo manualmente.

## 4.1 Criar diretórios

```bash
mkdir -p ~/.vim/config
mkdir -p ~/.vim/templates
mkdir -p ~/.vim/pack/plugins/opt
```

Repare que agora **todos** os plugins vão para `pack/plugins/opt` (não `start`). Isso é proposital: o `~/.vimrc` carrega cada um explicitamente com `packadd!`, na ordem certa (isso importa principalmente pro `vim-devicons`, que precisa carregar depois do NERDTree).

---

## 4.2 Instalar o tema (preto + vermelho)

Diferente dos outros, esse não vem de um repositório externo: é um tema
próprio, feito sob medida pra essa configuração, e já vem dentro da
pasta `theme/icaro-theme` deste projeto. Só copiar:

```bash
cp -r theme/icaro-theme ~/.vim/pack/plugins/opt/icaro-theme
```

Ele inclui o colorscheme (`colors/icaro.vim`) e o tema do airline
(`autoload/airline/themes/icaro.vim`) — os dois já combinando entre si.

---

## 4.3 Instalar vim-airline e temas

```bash
git clone --depth 1 \
https://github.com/vim-airline/vim-airline.git \
~/.vim/pack/plugins/opt/vim-airline

git clone --depth 1 \
https://github.com/vim-airline/vim-airline-themes.git \
~/.vim/pack/plugins/opt/vim-airline-themes
```

---

## 4.4 Instalar NERDTree + ícones

```bash
git clone --depth 1 \
https://github.com/preservim/nerdtree.git \
~/.vim/pack/plugins/opt/nerdtree

git clone --depth 1 \
https://github.com/Xuyuanp/nerdtree-git-plugin.git \
~/.vim/pack/plugins/opt/nerdtree-git-plugin

git clone --depth 1 \
https://github.com/tpope/vim-fugitive.git \
~/.vim/pack/plugins/opt/vim-fugitive

git clone --depth 1 \
https://github.com/ryanoasis/vim-devicons.git \
~/.vim/pack/plugins/opt/vim-devicons
```

**Importante:** para os ícones aparecerem (em vez de caixinhas), instale uma [Nerd Font](https://www.nerdfonts.com) e configure seu terminal para usá-la.

---

## 4.5 Instalar o motor de autocomplete (coc.nvim)

```bash
git clone --branch release --depth 1 \
https://github.com/neoclide/coc.nvim.git \
~/.vim/pack/plugins/opt/coc.nvim
```

Depois, dentro do vim, instale o suporte a Java:

```vim
:CocInstall coc-java
```

Na primeira vez que você abrir um `.java`, o `coc-java` baixa o Eclipse JDT Language Server — isso pode demorar um pouco e precisa de internet.

---

# 5. Estrutura dos arquivos

Depois da instalação:

```text
~/.vim/
├── config/
│   ├── appearance.vim
│   ├── coc.vim
│   ├── cpp.vim
│   ├── java.vim
│   ├── explorer.vim
│   ├── keymaps.vim
│   └── search.vim
│
├── templates/
│   ├── cpp.cpp
│   ├── java_main.java
│   ├── java_cp.java
│   └── coc-settings.json
│
└── pack/
    └── plugins/
        └── opt/
            ├── icaro-theme/
            ├── vim-airline/
            ├── vim-airline-themes/
            ├── vim-fugitive/
            ├── nerdtree/
            ├── nerdtree-git-plugin/
            ├── vim-devicons/
            └── coc.nvim/

~/.vim/coc-settings.json
~/.vimrc
```

O arquivo principal é:

```text
~/.vimrc
```

---

# 6. Criando um problema novo (C++)

Basta fazer:

```bash
vim main.cpp
```

O Vim detecta que é um arquivo `.cpp` novo e coloca automaticamente o template.

O template fica em:

```text
~/.vim/templates/cpp.cpp
```

Template padrão:

```cpp
#include <bits/stdc++.h>
using namespace std;

using ll = long long;

void solve() {

}

int main() {
    ios::sync_with_stdio(false);
    cin.tie(nullptr);

    int t = 1;
    cin >> t;

    while (t--) {
        solve();
    }

    return 0;
}
```

---

# 6.1 Criando um problema novo (Java)

Duas situações:

## Template "estilo IDE" (padrão)

```bash
vim Solution.java
```

Gera automaticamente uma classe pública com o **mesmo nome do arquivo** (do jeito que uma IDE de verdade faz):

```java
public class Solution {

    public static void main(String[] args) {

    }
}
```

## Template de programação competitiva

Se o nome do arquivo terminar com `_cp` (antes do `.java`), o template muda para uma versão com entrada/saída rápida, pronta pra múltiplos casos de teste:

```bash
vim A_cp.java
```

```java
import java.io.*;
import java.util.*;

class Main {
    // ... leitura rápida com BufferedReader/StringTokenizer,
    // loop de múltiplos casos de teste, método solve() pra você preencher
}
```

Repare que essa classe **não é `public`**, de propósito: assim ela compila normalmente independente do nome do arquivo (`A_cp.java`, `B_cp.java`, etc. todos geram sempre a classe `Main`).

Quer trocar o sufixo `_cp` por outra coisa? Edite a variável no topo de `~/.vim/config/java.vim`:

```vim
let g:java_cp_suffix = '_cp'
```

---

# 7. Atalhos principais

## Geral

| Tecla | Função |
|---|---|
| `F1` | Trocar de tema (mostra popup com o nome por ~1,6s) |
| `Shift+Backspace` / `Ctrl+Backspace` | Apaga um par vazio `()`, `[]`, `{}`, `""`, `''` de uma vez |

## C++ e Java

Os atalhos são os mesmos, mas cada um chama o compilador certo dependendo do arquivo aberto (`.cpp` usa `g++`, `.java` usa `javac`/`java`):

| Tecla | Função |
|---|---|
| `F5` | Compilar |
| `F6` | Executar |
| `F7` | Compilar + executar |
| `F8` | Compilar + executar com `input.txt` |
| `F9` | Abrir terminal |

## Autocomplete

| Tecla | Função |
|---|---|
| `F4` | Liga/desliga o autocomplete inteiro (persistente, em tempo real) |
| `F3` | Liga/desliga só as dicas de parâmetro inline (persistente, em tempo real) |
| `gd` | Ir para definição |
| `gy` | Ir para definição do tipo |
| `gr` | Ver referências |
| `K` | Mostrar documentação do símbolo sob o cursor |
| `<leader>rn` | Renomear símbolo |
| `<leader>oi` | Organizar imports |
| `<leader>s` | Mostrar assinatura do método (parâmetros) |
| `Tab` / `Shift+Tab` | Navegar nas sugestões (quando o menu de autocomplete está visível) |
| `Enter` | Confirmar sugestão selecionada |
| `Ctrl+j` / `Ctrl+k` | Pular entre os parâmetros de um método aceito |


Quando o autocomplete está ligado, a statusline mostra `[AC:ON]`; quando desligado, `[AC:OFF]`. O estado de ambos (`F3` e `F4`) é salvo em disco — fechar e abrir o vim de novo mantém sua última escolha.

---

## Arquivos

| Tecla | Função |
|---|---|
| `F2` | Abrir Explorer |
| `Ctrl+S` | Salvar |
| `Tab` | Próximo buffer |
| `Shift+Tab` | Buffer anterior |

---

## Janelas

| Tecla | Função |
|---|---|
| `Ctrl+H` | Janela à esquerda |
| `Ctrl+J` | Janela abaixo |
| `Ctrl+K` | Janela acima |
| `Ctrl+L` | Janela à direita |

---

## Busca

| Tecla | Função |
|---|---|
| `/texto` | Procurar |
| `n` | Próxima ocorrência |
| `N` | Ocorrência anterior |
| `Esc` | Limpar highlight |

Também existe:

```text
<leader>h
```

para limpar o highlight.

Por padrão, `<leader>` é `\`.

Então:

```text
\h
```

limpa o highlight.

---

# 8. Fluxo recomendado para Codeforces

Imagine que você recebeu o problema A.

Crie:

```bash
mkdir -p contests/round
cd contests/round
vim A.cpp
```

O template aparece automaticamente.

Escreva sua solução.

Depois:

### Compilar

Pressione:

```text
F5
```

Equivale aproximadamente a:

```bash
g++ -std=c++17 -O2 -Wall -Wextra A.cpp -o A
```

---

### Executar

Pressione:

```text
F6
```

---

### Compilar e executar

Pressione:

```text
F7
```

Esse é o atalho principal para competição.

Ele faz:

```text
salvar
  ↓
compilar
  ↓
se compilou
  ↓
executar
```

---

# 9. Testando com input.txt

Crie:

```bash
touch input.txt
```

Coloque o teste dentro:

```text
5
1
2
3
4
5
```

Depois pressione:

```text
F8
```

O Vim executará aproximadamente:

```bash
g++ -std=c++17 -O2 -Wall -Wextra A.cpp -o A
./A < input.txt
```

Isso é muito útil para testar exemplos do enunciado.

---

# 10. Executável gerado

Se você estiver editando:

```text
A.cpp
```

o compilador gera:

```text
A
```

No Linux, o executável fica no mesmo diretório.

Você pode remover manualmente depois:

```bash
rm A
```

Ou limpar vários executáveis:

```bash
rm -f A B C D E F G
```

---

# 11. Terminal dentro do Vim

Pressione:

```text
F9
```

Isso abre:

```vim
:terminal
```

No terminal você pode executar comandos normalmente.

Por exemplo:

```bash
ls
g++ --version
./A
```

Para sair do modo de terminal e voltar ao Vim:

```text
Ctrl-\ Ctrl-N
```

Depois você pode navegar normalmente.

---

# 12. Explorer de arquivos (NERDTree)

Pressione:

```text
F2
```

O Vim abre/fecha um painel lateral com o **NERDTree**, com ícones por tipo de arquivo (via `vim-devicons`) — bem mais parecido com o explorer de uma IDE do que o netrw padrão.

Comandos úteis dentro do NERDTree:

| Tecla | Ação |
|---|---|
| `Enter` ou `o` | Abrir arquivo/diretório |
| `t` | Abrir em nova aba |
| `i` | Abrir em split horizontal |
| `s` | Abrir em split vertical |
| `m` | Menu (criar, renomear, mover, deletar) |
| `R` | Atualizar a árvore |
| `q` | Fechar o NERDTree |

**Se os ícones aparecerem como caixinhas/quadrados:** seu terminal não está usando uma Nerd Font. Baixe uma em [nerdfonts.com](https://www.nerdfonts.com) e configure o terminal para usá-la — a configuração do Vim já está pronta para exibir os ícones assim que a fonte certa estiver ativa.

Se o `NERDTree` não estiver instalado por algum motivo, a configuração cai de volta pro `netrw` nativo do Vim (mesmo atalho `F2` não vai funcionar nesse caso; use `:Explore`).

---

# 13. Tema preto + vermelho, e o problema do indicador sumindo no tmux

O tema (`colors/icaro.vim` + o tema do airline correspondente, dentro de `theme/icaro-theme/`) foi feito do zero pra essa configuração: fundo bem preto, statusline, sidebar, popups e bordas predominantemente em tons de vermelho/preto. O código em si continua colorido normalmente (verde pra strings, âmbar pra números, azul pra tipos, laranja pra funções) — só a "casca" da interface que segue a paleta preto+vermelho.

## Por que o "AC ON/OFF" sumia dentro do tmux

O `vim-airline` esconde seções inteiras da statusline quando a janela fica estreita demais — por padrão, a seção onde fica o indicador de autocomplete só aparecia com a janela tendo pelo menos **80 colunas**. Um painel de tmux dividido facilmente fica menor que isso, daí o indicador sumir sem nenhum erro aparecer.

A correção (já aplicada em `config/appearance.vim`) desliga esse truncamento:

```vim
let g:airline#extensions#default#section_truncate_width = {
      \ 'b': 0, 'x': 0, 'y': 0, 'z': 0,
      \ 'warning': 0, 'error': 0, 'warning2': 0,
      \ }
```

Com isso o indicador (e o créditozinho) ficam visíveis mesmo em janelas bem estreitas. Isso foi verificado diretamente: numa janela de 40 colunas, o texto `[AC:ON]` continua aparecendo na seção certa da statusline.

Havia ainda uma segunda causa, mais sutil: o `vim-airline` monta a primeira versão da statusline **antes** do `VimEnter` disparar, então só sobrescrever a variável global depois (como a configuração original fazia) não bastava — ele não redesenhava sozinho. Por isso as funções `AutocompleteStatus()`/`CreditFooter()` e as seções `g:airline_section_y`/`g:airline_section_z` agora ficam definidas bem no topo do `~/.vimrc`, antes de qualquer plugin carregar.

## Cores estranhas/lavadas dentro do tmux

Isso normalmente é o tmux não estando configurado pra repassar true color (24 bits) pro Vim. Adicione ao seu `~/.tmux.conf`:

```tmux
set -g default-terminal "tmux-256color"
set -ga terminal-overrides ",*:RGB"
```

E reinicie o tmux (`tmux kill-server` e abra de novo, ou `tmux source-file ~/.tmux.conf`).

Mesmo sem isso, o tema tem um fallback de 256 cores (aproximações da paleta preto+vermelho) configurado, então nunca fica totalmente quebrado — só um pouco menos fiel às cores exatas.

---

# 14. Correções: teclado travando, cores em conflito, toggle não persistente

Esta seção documenta uma leva de correções feitas depois de relatos de uso real.

## O teclado travava com o autocomplete desligado

**Causa raiz:** o mapeamento da tecla `Tab` chamava `coc#refresh()` sempre que você não estava no meio de uma sugestão — inclusive com o autocomplete desligado no `F4`. Só que `coc#refresh()` tenta reiniciar o serviço do coc.nvim no meio da digitação, o que deixava o `Tab`, o `Enter` e a digitação em geral instáveis.

**Correção:** todo mapeamento que chama alguma função `coc#*` agora checa `g:my_autocomplete_enabled` primeiro. Desligado, essas teclas viram o comportamento nativo do Vim, sem passar perto do coc:

```vim
inoremap <silent><expr> <TAB>
            \ !g:my_autocomplete_enabled ? "\<Tab>" :
            \ coc#pum#visible() ? coc#pum#next(1) :
            \ CheckBackspace() ? "\<Tab>" :
            \ coc#refresh()
```

Isso foi testado digitando de verdade (parênteses, chaves, backspace) com o autocomplete desligado, num terminal real — sem travar.

## Cores em conflito (texto vermelho em cima de seleção vermelha)

O menu de sugestões usa o grupo `CocPumSearch` (o texto que bate com o que você digitou) linkado por padrão a `CocSearch`. Esse grupo estava vermelho, e a linha selecionada no menu (`PmenuSel`) também tinha fundo vermelho — resultado: texto vermelho em cima de fundo vermelho, ilegível.

**Correção:**
- `PmenuSel` agora é fundo vermelho escuro + texto branco (bem legível)
- `CocSearch`/`CocPumSearch` (o texto buscado) virou âmbar — contrasta com fundo escuro normal E com a seleção vermelha escura
- As dicas de parâmetro inline (`CocInlayHint`) ganharam uma cor cinza-clara própria, em vez de ficar escura demais e sumir no fundo preto

## O toggle do autocomplete não era persistente

Antes, `F4` só valia pra sessão atual — fechar e abrir o vim voltava tudo pro padrão (ligado). Agora:

- Toda vez que você aperta `F4`, o estado (0 ou 1) é salvo em `~/.vim/.icaro_autocomplete_state`
- Esse arquivo é lido **antes** de qualquer plugin carregar (bem no topo do `~/.vimrc`), e usado pra decidir se o coc.nvim sequer deve iniciar o serviço (`g:coc_start_at_startup`)
- Resultado: se você deixar desligado, da próxima vez que abrir o vim ele já nasce desligado — e vice-versa

Isso foi verificado num teste de ida e volta completo: desligar → nova sessão (continua desligado) → religar → nova sessão (continua ligado).

## Novo atalho: `F3` — só as dicas de parâmetro

Separado do `F4` (que liga/desliga o autocomplete inteiro), o `F3` liga/desliga só aquele texto fantasma que aparece dentro das chamadas de método (tipo `println(/* x: */ valor)`), sem mexer nas sugestões normais. Também é persistente, salvo em `~/.vim/.icaro_inlayhints_state`.

## Nerd Font agora é opcional de verdade

Antes, os ícones do NERDTree e as setinhas "powerline" da statusline dependiam de você ter uma Nerd Font instalada — sem isso, ficavam caixinhas quebradas. Agora o `install.sh` pergunta na hora da instalação:

- **Sim, tenho Nerd Font** → ícones e setinhas powerline ligados
- **Não tenho** (padrão, se você não tiver certeza) → o `vim-devicons` nem chega a carregar, e a statusline usa separadores simples em Unicode comum (`│`), que funcionam em qualquer fonte monoespaçada

Sua resposta fica salva em `~/.vim/config/local.vim` — o `install.sh` nunca mais pergunta de novo depois disso, mas você pode editar esse arquivo manualmente a qualquer momento pra mudar de ideia.

## Tela inicial nova

Abrir o vim sem nenhum arquivo agora mostra uma tela de boas-vindas com o nome da configuração, atalhos principais e como começar. De propósito, ela usa só caracteres ASCII simples (nada de blocos Unicode `█▓▒`) — durante os testes, encontramos telas onde esses blocos ficavam embaralhados dependendo da fonte/locale do terminal, então preferimos algo 100% seguro em qualquer lugar.

## F3 corrigido: agora desliga de verdade as dicas dentro dos parênteses

A primeira versão do `F3` só mexia numa configuração específica do `coc-java` (`java.inlayHints.parameterNames.enabled`). Só que aquele texto fantasma tipo `println(mensagem: "oi")` é controlado pelo interruptor **geral** do coc.nvim (`inlayHint.enable`), que vale pra qualquer linguagem com LSP — não só Java.

Agora o `F3` usa os dois:
- `inlayHint.enable` (0/1) — o interruptor geral, funciona pra Java, C++ (se você instalar um language server pra C++, tipo `coc-clangd`) ou qualquer outra linguagem
- o comando nativo `document.toggleInlayHint`, que atualiza a tela na hora, sem precisar fechar e abrir o arquivo de novo
- `java.inlayHints.parameterNames.enabled` continua sendo ajustado também, por garantia

## Git na interface

Duas adições novas, pra ficar mais parecido com uma IDE de verdade:

- **`vim-fugitive`**: mostra o nome da branch atual (`master`, etc.) na statusline, dentro de um repositório git. Não precisa configurar nada — só estar num repo.
- **`nerdtree-git-plugin`**: mostra o status do git (`M` modificado, `+` staged, `?` não rastreado, `*` sujo, `D` deletado) do lado do nome de cada arquivo dentro do NERDTree, cada um com uma cor diferente dentro da nossa paleta.
- A statusline também ganhou contadores de erro/aviso do coc (`E:N`/`W:N`), perto do tipo do arquivo.

## Paleta com mais variação

Adicionamos um tom ciano (`#5fb3b3`) à paleta, usado em: nome de diretórios (no `Directory` e no NERDTree), sinalizadores de informação do coc, e a borda da janela flutuante de `hover`/documentação. Continua sendo uma paleta preto+vermelho no fundo — o ciano é só um tempero a mais pra diferenciar "tipo" (azul) de "informação" (ciano) visualmente, do jeito que uma IDE de verdade costuma fazer.

---

# 15. O teclado travando depois do F4 — causa raiz encontrada de vez

Essa demorou mais pra encontrar. A explicação de "processo do coc pendurado" (seção anterior a esta, ainda válida e mantida) não era a causa principal — o teclado continuava travando mesmo depois de matar o processo do coc de verdade.

A causa real: **`F4`, `F3` e `F1` não tinham nenhum mapeamento dentro do modo de inserção.** Se você aperta uma dessas teclas *enquanto está digitando* (sem apertar `Esc` antes — que é o jeito mais natural de usar um atalho desses), o Vim recebe a sequência de escape da tecla de função sem saber o que fazer com ela no insert mode, e isso podia jogar você pro modo normal **sem avisar**. Dali pra frente, Backspace e parênteses realmente não "escrevem" nada — porque em modo normal essas teclas fazem outra coisa (navegação, principalmente), não edição. Fechar e abrir o vim "resolvia" só porque você entrava no insert mode de novo, do zero, mascarando a causa real.

**Correção:** `F1`, `F2`, `F3`, `F4`, `F9` (e também `F5`-`F8`, dentro de arquivos `.cpp`/`.java`) agora têm mapeamento também dentro do insert mode, usando `<C-o>`:

```vim
inoremap <silent> <F4> <C-o>:call ToggleAutocomplete()<CR>
```

`<C-o>` executa um único comando de modo normal e volta pro insert mode sozinho, automaticamente — é o jeito correto e padrão do Vim pra isso. Testamos digitando de verdade, apertando `F4` no meio da frase, sem tocar em `Esc` antes nem depois: o texto continuou entrando normalmente, parênteses e backspace incluídos.

Se mesmo assim alguma tecla de função ainda se comportar de forma estranha no seu terminal específico, pode ser um conflito de sequência de escape do seu emulador de terminal com essa tecla — nesse caso, me avise qual tecla e qual terminal você usa.

---

# 16. Desligar/ligar autocomplete sem quebrar a edição

O `F4` agora **não mata o processo RPC do coc.nvim**. Antes de desligar, ele apenas fecha qualquer popup aberto e usa `CocDisable`; ao religar, usa `CocEnable`. Isso evita reiniciar o servidor LSP no meio da edição e reduz a chance de o estado do Insert Mode ficar inconsistente.

Além disso, o `config/coc.vim` possui tratamento explícito para as teclas básicas de edição:

```vim
inoremap <silent><expr> <BS> CocBackspace()
inoremap <silent><expr> <Esc> CocEscape()
```

`CocBackspace()` só fecha o popup, se houver um, e depois devolve o `Backspace` para o Vim. Assim, com ou sem autocomplete, `Backspace`, parênteses, chaves e colchetes continuam sendo edição normal.

---

# 17. Novidades: temas, atalho pra dicas inline, backspace inteligente

## F1 — 16 temas, com popup mostrando o nome

Aperte `F1` pra alternar entre os temas abaixo (cicla e volta pro primeiro). Um popup no centro da tela mostra o nome do tema escolhido por ~1,6 segundos e some sozinho. Sua escolha fica salva — fechar e abrir o vim mantém o último tema usado.

| # | Tema | Descrição |
|---|---|---|
| 1 | **Malvadão** | preto + vermelho (o padrão, o mesmo de antes) |
| 2 | **Camelo** | deserto, sépia e amarelo |
| 3 | **Pedro de...** | claro, branco — "Cor: Clara" |
| 4 | **Mateus São Paulino** | branco predominante, vermelho e preto — "tema trikas" |
| 5 | **Of(f) light** | preto, branco e cinza, sem nenhuma outra cor |
| 6 | **Belchior** | branco predominante + azul |
| 7 | **Alan Turing** | arco-íris |
| 8 | **Ever Dream This Man?** | gruvbox |
| 9 | **Sassá?** | Catppuccin |
| 10 | **Jales** | vermelho predominante, detalhes em preto, pouco branco |
| 11 | **Maria Isabel** | preto + verde, estilo Spotify |
| 12 | **Dijkstra** | azul-acinzentado + branco-gelo — "Como é que se escreve Dijkstra?" |
| 13 | **Geraldo** | rosa estilo Hello Kitty + branco |
| 14 | **Lucas ->Ribeiro?** | dourado, remetendo a ouro/dinheiro |
| 15 | **Raul** | rock/metal, tons de aço e um vermelho sangue |
| 16 | **ACESSO NEGADO** | só preto e branco (alvinegro) |

Cada tema tem seu próprio colorscheme (`~/.vim/pack/plugins/opt/icaro-theme/colors/`) e seu próprio tema do airline — a statusline, o NERDTree, o menu de sugestões e a sintaxe do código mudam juntos.

Quer editar as cores de um tema específico? Os arquivos estão em `theme/icaro-theme/colors/<nome>.vim` (nomes sem espaço/acento: `malvadao`, `camelo`, `pedro_de`, `mateus_sao_paulino`, `off_light`, `belchior`, `alan_turing`, `ever_dream_this_man`, `sassa`, `jales`, `maria_isabel`, `dijkstra`, `geraldo`, `lucas_ribeiro`, `raul`, `acesso_negado`).

## Indicador `IH` na statusline

Igual o `[AC:ON]`/`[AC:OFF]`, agora tem um `[IH:ON]`/`[IH:OFF]` do lado, mostrando o estado das dicas de parâmetro inline (o `F3`).

## Separadores em formato de seta

Sem Nerd Font, a statusline agora usa `>` e `<` como separadores entre as seções (em vez da barrinha `│` ou nada) — funciona em qualquer fonte, sem depender de ícone nenhum.

## Backspace inteligente: `Shift+Backspace` apaga o par inteiro

Se o cursor estiver bem entre um par vazio — `()`, `[]`, `{}`, `""`, `''` ou `` `` `` — apertar `Shift+Backspace` (ou `Ctrl+Backspace`, dependendo do que seu terminal enviar) apaga os dois de uma vez, em vez de só um. Fora dessa situação exata, funciona como um Backspace normal.


---

# 18. Buffers

No Vim, um arquivo aberto é um buffer.

Você pode abrir vários:

```vim
:e A.cpp
:e B.cpp
:e C.cpp
```

Trocar:

```text
Tab
```

ou:

```text
Shift+Tab
```

Também existem os comandos:

```vim
:bnext
:bprevious
```

Listar buffers:

```vim
:buffers
```

Ir diretamente para um buffer:

```vim
:buffer 2
```

---

# 19. Janelas

Dividir horizontalmente:

```vim
:split
```

Dividir verticalmente:

```vim
:vsplit
```

Ou:

```text
Ctrl+W S
Ctrl+W V
```

Depois navegue usando:

```text
Ctrl+H
Ctrl+J
Ctrl+K
Ctrl+L
```

Isso é especialmente útil para deixar o código de um lado e outro arquivo/terminal do outro.

---

# 20. Comandos básicos do Vim

## Abrir arquivo

```bash
vim arquivo.cpp
```

---

## Abrir vários arquivos

```bash
vim A.cpp B.cpp C.cpp
```

---

## Salvar

```vim
:w
```

---

## Salvar e sair

```vim
:wq
```

ou:

```vim
:x
```

---

## Sair sem salvar

```vim
:q!
```

---

## Fechar

```vim
:q
```

---

## Salvar todos

```vim
:wa
```

---

# 21. Modos do Vim

O Vim possui principalmente:

```text
NORMAL
INSERT
VISUAL
COMMAND
```

### Normal

É o modo padrão.

Use:

```text
Esc
```

para voltar.

---

### Insert

Para escrever:

```text
i
```

Outros atalhos:

```text
a
o
O
I
A
```

---

### Visual

Seleção de texto:

```text
v
```

Linha inteira:

```text
V
```

Bloco:

```text
Ctrl+V
```

---

### Command

Pressione:

```text
:
```

Exemplos:

```vim
:w
:q
:wq
:set number
:colorscheme icaro
```

---

# 22. Navegação rápida

No modo normal:

```text
h  esquerda
j  baixo
k  cima
l  direita
```

Movimentos importantes:

```text
w  próxima palavra
b  palavra anterior
e  fim da palavra
0  começo da linha
$  fim da linha
gg início do arquivo
G  fim do arquivo
```

Ir para uma linha:

```vim
:100
```

ou:

```text
100G
```

---

# 23. Edição rápida

```text
dd      apagar linha
yy      copiar linha
p       colar
u       desfazer
Ctrl+r  refazer
x       apagar caractere
ciw     mudar palavra
diw     apagar palavra
dw      apagar até próxima palavra
D       apagar até fim da linha
C       mudar até fim da linha
```

Alguns comandos extremamente úteis:

```text
ci"
```

muda o conteúdo dentro de aspas.

```text
ci(
```

muda o conteúdo dentro de parênteses.

```text
di{
```

apaga o conteúdo dentro de `{}`.

---

# 24. Visual + indentação

Selecione linhas:

```text
V
```

Depois:

```text
>
```

para indentar.

Ou:

```text
<
```

para remover indentação.

No Vim, você também pode selecionar e usar:

```text
=
```

para reindentar automaticamente.

Exemplo:

```text
gg=G
```

formata/reindenta o arquivo inteiro segundo as regras do Vim.

---

# 25. Pesquisa

Pesquisar:

```text
/abc
```

Próximo:

```text
n
```

Anterior:

```text
N
```

Pesquisa reversa:

```text
?abc
```

Depois de pesquisar, o Vim deixa os resultados destacados.

Para limpar:

```text
Esc
```

ou:

```vim
:nohlsearch
```

---

# 26. Substituição

Substituir na linha atual:

```vim
:s/old/new/
```

No arquivo inteiro:

```vim
:%s/old/new/g
```

Perguntando antes:

```vim
:%s/old/new/gc
```

---

# 27. Configuração do editor

A configuração principal está em:

```text
~/.vimrc
```

As partes foram separadas:

```text
~/.vim/config/
├── appearance.vim
├── coc.vim
├── cpp.vim
├── java.vim
├── explorer.vim
├── keymaps.vim
└── search.vim
```

Isso facilita modificar o Vim sem transformar o `.vimrc` em um arquivo gigante.

---

# 28. Configurações importantes

## Números de linha

```vim
set number
set relativenumber
```

O número da linha atual aparece normalmente e as demais aparecem relativamente.

Isso ajuda bastante para comandos como:

```text
5j
10k
```

---

## Tab como 4 espaços

```vim
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
```

---

## Busca inteligente

```vim
set ignorecase
set smartcase
set incsearch
set hlsearch
```

Assim:

```text
abc
```

ignora maiúsculas/minúsculas.

Mas:

```text
ABC
```

passa a diferenciar maiúsculas/minúsculas.

---

## Cursor

```vim
set cursorline
```

destaca a linha atual.

---

## Scroll

```vim
set scrolloff=5
```

mantém algumas linhas ao redor do cursor durante a rolagem.

---

# 29. Segurança e arquivos temporários

A configuração usa:

```vim
set nobackup
set noswapfile
set nowritebackup
```

Isso evita a criação dos arquivos temporários tradicionais do Vim.

**Observação:** isso é conveniente para um ambiente de competição, mas significa que você abre mão de parte da recuperação automática que os swapfiles oferecem.

---

# 30. Por que usar C++17?

A configuração compila com:

```bash
-std=c++17
```

Isso permite usar recursos modernos e bibliotecas comuns em programação competitiva.

Exemplo:

```cpp
#include <bits/stdc++.h>
using namespace std;

int main() {
    vector<int> v = {1, 2, 3};

    for (int x : v)
        cout << x << '\n';
}
```

---

# 31. Flags do compilador

O comando padrão é:

```bash
g++ -std=c++17 -O2 -Wall -Wextra
```

### `-std=c++17`

Usa C++17.

### `-O2`

Ativa otimizações adequadas para competição.

### `-Wall`

Ativa vários warnings.

### `-Wextra`

Ativa warnings adicionais.

Esses warnings ajudam a encontrar erros que poderiam virar WA ou comportamento inesperado.

---

# 32. Como restaurar seu Vim antigo

O instalador cria um backup antes de substituir:

```text
~/.vimrc
```

O arquivo fica parecido com:

```text
~/.vimrc.backup.20260909_021500
```

Para restaurar:

```bash
cp ~/.vimrc.backup.DATA ~/.vimrc
```

Substitua `DATA` pelo nome real do backup.

---

# 33. Desinstalar a configuração

Para remover a configuração:

```bash
rm -f ~/.vimrc
rm -rf ~/.vim/config
rm -rf ~/.vim/templates
rm -f ~/.vim/coc-settings.json
rm -f ~/.vim/.icaro_autocomplete_state
rm -f ~/.vim/.icaro_inlayhints_state
```

Para remover os plugins instalados por este projeto:

```bash
rm -rf ~/.vim/pack/plugins/opt/icaro-theme
rm -rf ~/.vim/pack/plugins/opt/vim-airline
rm -rf ~/.vim/pack/plugins/opt/vim-airline-themes
rm -rf ~/.vim/pack/plugins/opt/nerdtree
rm -rf ~/.vim/pack/plugins/opt/nerdtree-git-plugin
rm -rf ~/.vim/pack/plugins/opt/vim-fugitive
rm -rf ~/.vim/pack/plugins/opt/vim-devicons
rm -rf ~/.vim/pack/plugins/opt/coc.nvim
```

Para remover a extensão `coc-java` (e outras extensões do coc):

```bash
rm -rf ~/.config/coc
```

Se você tiver um `.vimrc` antigo, restaure o backup.

---

# 34. Levar para outro computador

Esse é um dos objetivos principais deste projeto.

No computador de destino:

```bash
git clone <SEU_REPOSITORIO>
cd vim-codeforces-ide
chmod +x install.sh
./install.sh
```

Depois:

```bash
vim
```

Tudo será reconstruído:

```text
Tema
Configuração
Template
Atalhos
Airline
Explorer
Workflow C++
```

---

# 35. Instalação no PC do LCC

Exemplo completo:

```bash
git clone <SEU_REPOSITORIO>
cd vim-codeforces-ide
chmod +x install.sh
./install.sh
```

Se aparecer:

```text
g++ não encontrado
```

instale o compilador de acordo com a distribuição Linux.

Ubuntu/Debian:

```bash
sudo apt update
sudo apt install g++
```

Depois:

```bash
g++ --version
```

E finalmente:

```bash
vim
```

---

# 36. Teste final

Depois da instalação:

```bash
mkdir -p ~/teste-vim
cd ~/teste-vim
vim main.cpp
```

O template deve aparecer.

Depois pressione:

```text
F5
```

para compilar.

Depois:

```text
F7
```

para compilar e executar.

Para testar entrada:

```bash
touch input.txt
```

Edite o arquivo:

```bash
vim input.txt
```

Coloque uma entrada e volte para:

```text
main.cpp
```

Pressione:

```text
F8
```

Se tudo funcionar, o ambiente está pronto para Codeforces.

---

# 37. Resumo rápido

```text
┌───────────────────────────────────────────┐
│     VIM CODEFORCES / JAVA IDE             │
│     Configuração Ícaro Lira               │
├───────────────────────────────────────────┤
│ F2       Explorer (NERDTree)              │
│ F3       Liga/desliga dicas de parâmetro  │
│ F4       Liga/desliga autocomplete        │
│ F5       Compilar                         │
│ F6       Executar                         │
│ F7       Compilar + Executar              │
│ F8       Testar input.txt                 │
│ F9       Terminal                         │
│ Ctrl+S   Salvar                           │
│ Ctrl+H   Janela esquerda                  │
│ Ctrl+J   Janela abaixo                    │
│ Ctrl+K   Janela acima                     │
│ Ctrl+L   Janela direita                   │
│ Tab      Próximo buffer                   │
│ S-Tab    Buffer anterior                  │
│ Esc      Limpar busca                     │
├───────────────────────────────────────────┤
│ Templates automáticos: .cpp e .java       │
│ C++17 + O2 + Wall + Wextra                │
│ Autocomplete via coc.nvim + coc-java      │
│ Tema preto + vermelho (icaro)              │
│ NERDTree (+ ícones, se tiver Nerd Font)   │
│ F3/F4 persistentes                        │
│ Terminal                                  │
└───────────────────────────────────────────┘
```

---

# 38. Ideia do workflow

A intenção é que, durante uma competição, você consiga fazer:

```text
Terminal
   │
   ├── criar pasta
   │
   ▼
vim A.cpp
   │
   ├── template automático
   │
   ▼
escrever solução
   │
   ▼
F7
   │
   ├── compila
   │
   └── executa
   │
   ▼
input.txt
   │
   ▼
F8
   │
   ▼
testar exemplos
   │
   ▼
submeter no Codeforces
```

O objetivo é deixar o máximo possível do processo de competição dentro do Vim.

---

# 39. Próximas extensões possíveis

O projeto foi estruturado para receber mais ferramentas futuramente.

Possíveis extensões:

- `fzf` para busca de arquivos
- `vim-fugitive` para Git
- integração com testes múltiplos
- comparação automática `output.txt`
- gerador de arquivos A/B/C/D/E
- comando para criar uma pasta de contest
- suporte a Python
- execução com casos de teste múltiplos
- timer de competição
- integração com Codeforces
- download automático de problemas
- submissão pelo terminal
- suporte a C++20/C++23
- snippets de algoritmos
- biblioteca pessoal de templates
- comandos para debug
- perfil específico para OBI/ICPC/Codeforces

---

# 40. Filosofia da configuração

A configuração não tenta transformar o Vim em uma cópia do VS Code.

A proposta é manter a principal vantagem do Vim:

```text
teclado
+
velocidade
+
atalhos
+
terminal
+
editor
```

e adicionar somente o que realmente ajuda em programação competitiva.

O resultado é um ambiente pequeno, rápido e portátil que pode ser reproduzido em qualquer máquina Linux com:

```text
Vim
Git
g++
JDK (para Java)
Node.js (para o autocomplete)
```

---

## Licença

Esta configuração é pessoal/educacional e pode ser modificada livremente.

Os plugins utilizados pertencem aos seus respectivos projetos e autores.

**Configuração Vim Ícaro Lira**
