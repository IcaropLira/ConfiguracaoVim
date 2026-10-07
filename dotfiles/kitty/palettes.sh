#!/usr/bin/env bash
# palettes.sh — tabela de paletas do terminal (usada pelo install.sh).
# Para adicionar um tema novo, basta acrescentar UMA linha em ICARO_PALETTES.
# Formato (separado por "|"):
#  id|Nome|bg|fg|selecao|cursor|destaque|c1|c2|c3|c4|c5|c6|c8|c9|c10|c11|c12|c13|c14|c15
# color0 = bg, color7 = fg. As cores das abas são derivadas de bg/seleção.
ICARO_PALETTES=(
"navy|Exagerado|#0b1220|#dbeafe|#1e3a5f|#93c5fd|#2563eb|#ef4444|#22c55e|#f59e0b|#3b82f6|#a855f7|#06b6d4|#475569|#f87171|#4ade80|#fbbf24|#60a5fa|#c084fc|#22d3ee|#f8fafc"
"midnight|Ainda gosto dela|#070b12|#e5e7eb|#1f2937|#e5e7eb|#334155|#fb7185|#4ade80|#facc15|#38bdf8|#c084fc|#2dd4bf|#475569|#fda4af|#86efac|#fde047|#7dd3fc|#d8b4fe|#5eead4|#f8fafc"
"graphite|Tenta acreditar|#15171a|#e6e6e6|#34383f|#ffffff|#4b5563|#f7768e|#9ece6a|#e0af68|#7aa2f7|#bb9af7|#73daca|#414868|#ff899d|#a9dc76|#e9c46a|#8db0ff|#c7a0ff|#7fe8d2|#ffffff"
"purple|Primeiros erros|#17111f|#eee7f7|#3b2850|#e9d5ff|#7c3aed|#fb7185|#86efac|#fcd34d|#a78bfa|#d8b4fe|#67e8f9|#6b5a78|#fda4af|#bbf7d0|#fde68a|#c4b5fd|#e9d5ff|#a5f3fc|#ffffff"
"pastel|Tareco & Mariola|#2b2633|#f5edf7|#574b61|#f9d5e5|#c4a7e7|#eb6f92|#9ccfd8|#f6c177|#a8c7fa|#c4a7e7|#b7e4c7|#6f6575|#f5a9bc|#b8e3e8|#f8d39a|#c5dbff|#d8c4f1|#c8edd5|#fffaff"
"pastel_blue|João e Maria|#17212b|#e8f1f8|#31536b|#b7e3ff|#6cb6e6|#ff9fb3|#a9dfbf|#f5d69a|#8bd5ff|#d3b7f5|#9ee7e5|#536a79|#ffb9c8|#bdebd0|#f9e3b4|#b7e3ff|#e4d0fb|#b9f0ee|#ffffff"
"solarized_dark|Não creio em mais nada|#002b36|#839496|#073642|#93a1a1|#586e75|#dc322f|#859900|#b58900|#268bd2|#d33682|#2aa198|#586e75|#cb4b16|#b4c342|#cb8b00|#4aa3df|#d55f9a|#35bdb1|#fdf6e3"
"solarized_light|BORA PEDRO|#fdf6e3|#657b83|#eee8d5|#586e75|#93a1a1|#dc322f|#859900|#b58900|#268bd2|#d33682|#2aa198|#002b36|#cb4b16|#586e75|#657b83|#839496|#6c71c4|#93a1a1|#fdf6e3"
"wine|Gatinha comunista|#260d12|#ffe5ea|#5c1824|#ff7185|#d94b62|#d94b62|#58b77b|#d6a64f|#6d8cff|#c56bdb|#58c7c7|#5c2933|#ff7185|#79d99a|#e9bd68|#8fa8ff|#df8cf0|#7de4e4|#fff5f7"
"forest|Destá|#0c2118|#e5ffef|#17452f|#73e6a5|#3bbf78|#e35d6a|#3bbf78|#d9b75f|#5d91e8|#b77bd9|#46c5c0|#31503f|#ff7885|#62e99a|#edcf73|#80adff|#d49aed|#70e2dc|#f4fff8"
"cyan|Wham Bam Shang-A-Lang|#062b30|#d9ffff|#0d5961|#67e8e8|#18b8bd|#e85d75|#49c878|#e3b341|#3d9cff|#b07cff|#18b8bd|#27565a|#ff788f|#68e99a|#f0c85a|#70b8ff|#c89cff|#67e8e8|#f2ffff"
"amber|Camelo|#291a05|#fff1c7|#62420b|#ffd166|#e6a72e|#e06c75|#77b255|#e6a72e|#6d9cff|#c084fc|#55c2c7|#5f4822|#ff8990|#94d36f|#ffd166|#8db3ff|#d5a5ff|#7ae0e3|#fff9e8"
"indigo|Iogurte|#17112f|#ece6ff|#332566|#9f8cff|#7c68ee|#ef6675|#68c77a|#e2b84e|#668cff|#a77bff|#55c8cf|#40375f|#ff8996|#8be39a|#f3d16a|#91adff|#c5a5ff|#7de6e9|#ffffff"
"pink|Tamborete de forró|#2a0d24|#ffe4f5|#5d164d|#ff75c3|#ed4eaa|#f05b72|#61c98b|#e4b84e|#6e8cff|#ed4eaa|#55c7d0|#5b2d50|#ff7f91|#82e4a8|#f2cf66|#8eabff|#ff78c9|#76e3eb|#fff4fa"
"dracula|Pra amar & ser feliz|#282a36|#f8f8f2|#44475a|#f8f8f2|#bd93f9|#ff5555|#50fa7b|#f1fa8c|#bd93f9|#ff79c6|#8be9fd|#6272a4|#ff6e6e|#69ff94|#ffffa5|#d6acff|#ff92df|#a4ffff|#ffffff"
"nord|Evidências|#2e3440|#d8dee9|#434c5e|#d8dee9|#88c0d0|#bf616a|#a3be8c|#ebcb8b|#81a1c1|#b48ead|#88c0d0|#4c566a|#d08770|#b5d49d|#f0d399|#8fb0d0|#c79fbf|#8fbcbb|#eceff4"
"gruvbox|Garçon|#282828|#ebdbb2|#504945|#ebdbb2|#d79921|#cc241d|#98971a|#d79921|#458588|#b16286|#689d6a|#928374|#fb4934|#b8bb26|#fabd2f|#83a598|#d3869b|#8ec07c|#fbf1c7"
"tokyo|Serenata Existencialista|#1a1b26|#c0caf5|#33467c|#c0caf5|#7aa2f7|#f7768e|#9ece6a|#e0af68|#7aa2f7|#bb9af7|#7dcfff|#414868|#ff899d|#9fe044|#faba4a|#8db0ff|#c7a9ff|#a4daff|#ffffff"
"catppuccin|O Prefeito|#1e1e2e|#cdd6f4|#45475a|#f5e0dc|#cba6f7|#f38ba8|#a6e3a1|#f9e2af|#89b4fa|#f5c2e7|#94e2d5|#585b70|#f38ba8|#a6e3a1|#f9e2af|#89b4fa|#f5c2e7|#94e2d5|#ffffff"
"onedark|Eu tenho medo|#282c34|#abb2bf|#3e4451|#528bff|#61afef|#e06c75|#98c379|#e5c07b|#61afef|#c678dd|#56b6c2|#5c6370|#e06c75|#98c379|#e5c07b|#61afef|#c678dd|#56b6c2|#ffffff"
"rosepine|Otário|#191724|#e0def4|#403d52|#e0def4|#c4a7e7|#eb6f92|#31748f|#f6c177|#9ccfd8|#c4a7e7|#ebbcba|#6e6a86|#eb6f92|#3e8fb0|#f6c177|#9ccfd8|#c4a7e7|#ebbcba|#ffffff"
"monokai|Decida|#272822|#f8f8f2|#49483e|#f8f8f0|#a6e22e|#f92672|#a6e22e|#f4bf75|#66d9ef|#ae81ff|#a1efe4|#75715e|#f92672|#a6e22e|#f4bf75|#66d9ef|#ae81ff|#a1efe4|#f9f8f5"
"ayu|Céu Azul|#1f2430|#cccac2|#33415e|#ffcc66|#ffcc66|#f28779|#87d96c|#ffcc66|#6dcbfa|#dfbfff|#95e6cb|#707a8c|#f29e74|#a6e07f|#ffd580|#73d0ff|#d4bfff|#95e6cb|#ffffff"
"everforest|Suíte 14|#2d353b|#d3c6aa|#475258|#d3c6aa|#a7c080|#e67e80|#a7c080|#dbbc7f|#7fbbb3|#d699b6|#83c092|#859289|#e67e80|#a7c080|#dbbc7f|#7fbbb3|#d699b6|#83c092|#fdf6e3"
"kanagawa|Me dê motivo|#1f1f28|#dcd7ba|#2d4f67|#c8c093|#7e9cd8|#c34043|#76946a|#c0a36e|#7e9cd8|#957fb8|#6a9589|#727169|#e82424|#98bb6c|#e6c384|#7fb4ca|#938aa9|#7aa89f|#c8c093"
"oled|Te lascar dd|#000000|#e6e6e6|#262626|#ffffff|#5a5a5a|#ff5f5f|#5fd75f|#ffd75f|#5f87ff|#af87ff|#5fd7d7|#4a4a4a|#ff8787|#87ff87|#ffe787|#87afff|#d7afff|#87ffff|#ffffff"
"github|Black|#0d1117|#c9d1d9|#264f78|#58a6ff|#388bfd|#ff7b72|#3fb950|#d29922|#58a6ff|#bc8cff|#39c5cf|#6e7681|#ffa198|#56d364|#e3b341|#79c0ff|#d2a8ff|#56d4dd|#ffffff"
"sunset|Já sei namorar|#1f1424|#ffe8d6|#4a2740|#ffb482|#ff7e5f|#ff5e78|#8fd694|#ffc857|#7aa7ff|#e07bd9|#6fd6d0|#6b4a63|#ff8aa0|#b0efb4|#ffdb85|#a0c0ff|#f09be9|#98ece6|#fff6ee"
)

# Gera o arquivo de tema do kitty a partir de uma linha de ICARO_PALETTES.
# Uso: icaro_write_palette "<linha>" "<arquivo destino>"
icaro_write_palette() {
    local IFS='|'
    local -a f
    read -ra f <<< "$1"
    local dest="$2"
    cat > "$dest" <<PAL
# Gerado pelo install.sh — paleta: ${f[1]}
background                ${f[2]}
foreground                ${f[3]}
selection_background      ${f[4]}
selection_foreground      ${f[3]}
cursor                    ${f[5]}
cursor_text_color         ${f[2]}
url_color                 ${f[19]}
active_border_color       ${f[6]}
inactive_border_color     ${f[4]}
bell_border_color         ${f[7]}
visual_bell_color         none
active_tab_background     ${f[4]}
active_tab_foreground     ${f[3]}
inactive_tab_background   ${f[2]}
inactive_tab_foreground   ${f[13]}
tab_bar_background        none
tab_bar_margin_color      none
color0                    ${f[2]}
color1                    ${f[7]}
color2                    ${f[8]}
color3                    ${f[9]}
color4                    ${f[10]}
color5                    ${f[11]}
color6                    ${f[12]}
color7                    ${f[3]}
color8                    ${f[13]}
color9                    ${f[14]}
color10                   ${f[15]}
color11                   ${f[16]}
color12                   ${f[17]}
color13                   ${f[18]}
color14                   ${f[19]}
color15                   ${f[20]}
PAL
}

# Nomes personalizados: crie/edite ~/.config/kitty/palette-names.conf com linhas "id=Novo nome"
# (ex.: dracula=Meu roxo). Também dá pra renomear com a tecla R dentro do seletor.
ICARO_NAMES_FILE="${ICARO_NAMES_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/kitty/palette-names.conf}"
NAMES_FILE="$ICARO_NAMES_FILE"
apply_custom_names() {
    [ -f "$NAMES_FILE" ] || return 0
    local id name i
    while IFS='=' read -r id name; do
        [ -n "$id" ] && [ "${id#\#}" = "$id" ] && [ -n "$name" ] || continue
        for i in "${!ICARO_PALETTES[@]}"; do
            if [ "${ICARO_PALETTES[$i]%%|*}" = "$id" ]; then
                local rest="${ICARO_PALETTES[$i]#*|}"; rest="${rest#*|}"
                ICARO_PALETTES[$i]="$id|$name|$rest"
            fi
        done
    done < "$NAMES_FILE"
}
