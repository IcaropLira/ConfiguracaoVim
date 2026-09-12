# Vim Codeforces / Java IDE — Configuração Ícaro Lira

Configuração portátil de **Vim para programação competitiva e desenvolvimento em Java**.

A ideia é transformar o Vim em um pequeno IDE: tema bonito, números de linha, statusline, explorer em árvore com ícones, autocomplete tipo IDE (com toggle rápido), templates automáticos, compilação rápida, execução, testes com `input.txt`, terminal e atalhos para navegação.

---

# 1. O que essa configuração possui?

## Interface

- Tema **Catppuccin**
- `vim-airline` para uma statusline bonita, com indicador de autocomplete
- Números de linha (absoluto + relativo)
- Linha atual destacada
- Separadores de janelas estilizados
- Winbar quando suportada pela versão do Vim
- Menu de autocomplete (popup) estilizado 
- True Color
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

## 4.2 Instalar Catppuccin

```bash
git clone --depth 1 \
https://github.com/catppuccin/vim.git \
~/.vim/pack/plugins/opt/catppuccin
```

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
│   └── java_cp.java
│
└── pack/
    └── plugins/
        └── opt/
            ├── catppuccin/
            ├── vim-airline/
            ├── vim-airline-themes/
            ├── nerdtree/
            ├── vim-devicons/
            └── coc.nvim/

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
| `F4` | Liga/desliga o autocomplete (coc.nvim) |
| `gd` | Ir para definição |
| `gy` | Ir para definição do tipo |
| `gr` | Ver referências |
| `K` | Mostrar documentação do símbolo sob o cursor |
| `<leader>rn` | Renomear símbolo |
| `Tab` / `Shift+Tab` | Navegar nas sugestões (quando o menu de autocomplete está visível) |
| `Enter` | Confirmar sugestão selecionada |

Quando o autocomplete está ligado, a statusline mostra `● AC ON`; quando desligado, `○ AC OFF`.

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

# 13. Buffers

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

# 14. Janelas

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

# 15. Comandos básicos do Vim

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

# 16. Modos do Vim

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
:colorscheme catppuccin
```

---

# 17. Navegação rápida

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

# 18. Edição rápida

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

# 19. Visual + indentação

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

# 20. Pesquisa

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

# 21. Substituição

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

# 22. Configuração do editor

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

# 23. Configurações importantes

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

# 24. Segurança e arquivos temporários

A configuração usa:

```vim
set nobackup
set noswapfile
set nowritebackup
```

Isso evita a criação dos arquivos temporários tradicionais do Vim.

**Observação:** isso é conveniente para um ambiente de competição, mas significa que você abre mão de parte da recuperação automática que os swapfiles oferecem.

---

# 25. Por que usar C++17?

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

# 26. Flags do compilador

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

# 27. Como restaurar seu Vim antigo

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

# 28. Desinstalar a configuração

Para remover a configuração:

```bash
rm -f ~/.vimrc
rm -rf ~/.vim/config
rm -rf ~/.vim/templates
```

Para remover os plugins instalados por este projeto:

```bash
rm -rf ~/.vim/pack/plugins/opt/catppuccin
rm -rf ~/.vim/pack/plugins/opt/vim-airline
rm -rf ~/.vim/pack/plugins/opt/vim-airline-themes
rm -rf ~/.vim/pack/plugins/opt/nerdtree
rm -rf ~/.vim/pack/plugins/opt/vim-devicons
rm -rf ~/.vim/pack/plugins/opt/coc.nvim
```

Para remover a extensão `coc-java` (e outras extensões do coc):

```bash
rm -rf ~/.config/coc
```

Se você tiver um `.vimrc` antigo, restaure o backup.

---

# 29. Levar para outro computador

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

# 30. Instalação no PC do LCC

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

# 31. Teste final

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

# 32. Resumo rápido

```text
┌───────────────────────────────────────────┐
│     VIM CODEFORCES / JAVA IDE             │
│     Configuração Ícaro Lira               │
├───────────────────────────────────────────┤
│ F2       Explorer (NERDTree)              │
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
│ Catppuccin + Airline                      │
│ NERDTree + devicons                       │
│ Terminal                                  │
└───────────────────────────────────────────┘
```

---

# 33. Ideia do workflow

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

# 34. Próximas extensões possíveis

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

# 35. Filosofia da configuração

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
