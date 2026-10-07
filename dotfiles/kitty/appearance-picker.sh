#!/usr/bin/env bash
# appearance-picker.sh — seletor interativo de Opacidade / Blur / Paleta.
# Uso: appearance-picker.sh <arquivo-de-saida> <opacidade 0-100> <blur 0-100> <paleta_idx>
# Grava "opacidade blur paleta_idx" no arquivo de saída. Opacidade e blur vão de 0 a 100.
#
# Preview:
#  • Cores: aplicadas na hora via OSC 10/11.
#  • Opacidade/blur REAIS: via `kitten @` (precisa de allow_remote_control; o install.sh abre este
#    seletor numa janela do kitty com isso ligado, quando possível).
#  • Simulação: o quadro "janela sobre papel de parede" mostra opacidade e blur em QUALQUER terminal.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$DIR/palettes.sh"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"

OUT="$1"; op="${2:-80}"; bl="${3:-18}"; pi="${4:-0}"

clamp() { local v="$1"; [ "$v" -lt 0 ] && v=0; [ "$v" -gt 100 ] && v=100; echo "$v"; }
bar() { # $1 = 0..100 -> [██████░░░░]
    local v="$1" n=$(( $1 / 5 )) i out="["
    for ((i = 0; i < 20; i++)); do [ "$i" -lt "$n" ] && out+="█" || out+="░"; done
    printf '%s]' "$out"
}
op_float() { awk -v o="$1" 'BEGIN{printf "%.2f", o/100}'; }

rename_palette() { # $1 = índice
    local id="${ICARO_PALETTES[$1]%%|*}" cur new
    IFS='|' read -ra _f <<< "${ICARO_PALETTES[$1]}"; cur="${_f[1]}"
    printf '\033[0m\n  Novo nome para "%s" (vazio = cancelar): ' "$cur"
    IFS= read -re new || true
    new="${new//|/ }"; new="${new//=/ }"
    [ -n "$new" ] || return 0
    mkdir -p "$(dirname "$NAMES_FILE")"
    [ -f "$NAMES_FILE" ] && grep -v "^${id}=" "$NAMES_FILE" > "$NAMES_FILE.tmp" || : > "$NAMES_FILE.tmp"
    echo "${id}=${new}" >> "$NAMES_FILE.tmp"; mv "$NAMES_FILE.tmp" "$NAMES_FILE"
    local rest="${ICARO_PALETTES[$1]#*|}"; rest="${rest#*|}"
    ICARO_PALETTES[$1]="$id|$new|$rest"
}

hex_to_rgb() { local h="${1#\#}"; printf '%d;%d;%d' "$((16#${h:0:2}))" "$((16#${h:2:2}))" "$((16#${h:4:2}))"; }

position_dots() { # mostra onde está entre todas as opções (comprime em até 40 pontos)
    local cur="$1" total="$2" i out="" w=40 pos
    [ "$total" -lt "$w" ] && w="$total"
    pos=$(( total > 1 ? cur * (w - 1) / (total - 1) : 0 ))
    for ((i = 0; i < w; i++)); do [ "$i" -eq "$pos" ] && out+="●" || out+="·"; done
    printf '%s' "$out"
}

# Simulação: papel de parede listrado + janela com a opacidade e o blur escolhidos.
sim_preview() { # $1=bg hex  $2=fg hex  $3=opacidade  $4=blur
    awk -v bg="$(hex_to_rgb "$1")" -v fg="$(hex_to_rgb "$2")" -v op="$3" -v blur="$4" 'BEGIN{
        split(bg,B,";"); W=64; H=5; rad=int(blur/8); m=5
        n=split("230,60,60 240,160,40 240,220,60 60,200,90 50,180,220 80,100,240 170,80,230 240,90,170",P," ")
        for(c=0;c<W;c++){ k=int(c/4)%n+1; split(P[k],q,","); wr[c]=q[1]; wg[c]=q[2]; wb[c]=q[3] }
        txt="  ÍCARO LIRA — opacidade " op "  blur " blur "  "
        for(r=0;r<H;r++){
            line="  "
            for(c=0;c<W;c++){
                inwin=(c>=m && c<W-m && r>=1 && r<H-1)
                if(inwin){
                    sr=0;sg=0;sb=0;cnt=0
                    for(d=-rad;d<=rad;d++){ x=c+d; if(x<0)x=0; if(x>=W)x=W-1; sr+=wr[x];sg+=wg[x];sb+=wb[x];cnt++ }
                    sr/=cnt;sg/=cnt;sb/=cnt
                    R=int(op*B[1]+(1-op)*sr); G=int(op*B[2]+(1-op)*sg); Bl=int(op*B[3]+(1-op)*sb)
                } else { R=wr[c];G=wg[c];Bl=wb[c] }
                ch=" "
                if(inwin && r==2){ i=c-m-1; if(i>=0 && i<length(txt)) ch=substr(txt,i+1,1) }
                line=line sprintf("\033[48;2;%d;%d;%dm\033[38;2;%sm%s", R,G,Bl,fg,ch)
            }
            print line "\033[0m"
        }
    }'
}

apply_live() { # opacidade/blur reais, se o kitty deixar
    command -v kitten >/dev/null 2>&1 || return 0
    kitten @ set-background-opacity "$1" >/dev/null 2>&1 || true
    kitten @ load-config --override "background_blur=$2" --override "background_opacity=$1" >/dev/null 2>&1 || true
}

draw() {
    local focus="$1" i
    local -a f
    IFS='|' read -ra f <<< "${ICARO_PALETTES[$pi]}"
    local bg="${f[2]}" fg="${f[3]}" opacity; opacity="$(op_float "$op")"; local blur="$bl"
    local fgrgb bgrgb; fgrgb="$(hex_to_rgb "$fg")"; bgrgb="$(hex_to_rgb "$bg")"

    printf '\033]10;%s\007\033]11;%s\007' "$fg" "$bg"
    apply_live "$opacity" "$blur"

    printf '\033[2J\033[H\033[38;2;%sm\033[48;2;%sm' "$fgrgb" "$bgrgb"
    printf '\n  \033[1mAPARÊNCIA DO TERMINAL\033[22m — ajuste cada item separadamente\n\n'
    local -a labels=("Opacidade" "Blur" "Paleta")
    local -a values=("$(bar "$op") ${op}%" "$(bar "$bl") ${bl}" "${f[1]}")
    local -a idxs=("$op" "$bl" "$((pi + 1))")
    local -a totals=(100 100 "${#ICARO_PALETTES[@]}")
    for i in 0 1 2; do
        if [ "$i" -eq "$focus" ]; then
            printf '  \033[1;7m ▶ %-10s ◀ %-34s %3d/%-3d \033[27;22m\n' "${labels[$i]}" "${values[$i]}" "${idxs[$i]}" "${totals[$i]}"
        else
            printf '      %-10s   %-34s %3d/%-3d\n' "${labels[$i]}" "${values[$i]}" "${idxs[$i]}" "${totals[$i]}"
        fi
    done
    [ "$op" -lt 20 ] && printf '\n  \033[33m⚠ opacidade muito baixa: o texto pode ficar difícil de ler.\033[0m\033[38;2;%sm\033[48;2;%sm' "$fgrgb" "$bgrgb"
    printf '\n  Posição em "%s": ' "${labels[$focus]}"; position_dots "$(( ${idxs[$focus]} - 1 < 0 ? 0 : ${idxs[$focus]} - 1 ))" "${totals[$focus]}"; printf '\n\n'

    # simulação de opacidade + blur (funciona em qualquer terminal)
    printf '  \033[2mSimulação (janela sobre papel de parede):\033[22m\n'
    sim_preview "$bg" "$fg" "$opacity" "$blur"
    printf '\033[38;2;%sm\033[48;2;%sm\n' "$fgrgb" "$bgrgb"

    if [ "$focus" -eq 2 ]; then
        local n="${#ICARO_PALETTES[@]}" start=$((pi - 3)) end=$((pi + 3))
        [ "$start" -lt 0 ] && { end=$((end - start)); start=0; }
        [ "$end" -ge "$n" ] && { start=$((start - (end - n + 1))); end=$((n - 1)); }
        [ "$start" -lt 0 ] && start=0
        for ((i = start; i <= end; i++)); do
            local -a g; IFS='|' read -ra g <<< "${ICARO_PALETTES[$i]}"
            if [ "$i" -eq "$pi" ]; then printf '   \033[1m❯ %2d. %-20s\033[22m' "$((i + 1))" "${g[1]}"
            else printf '     %2d. %-20s' "$((i + 1))" "${g[1]}"; fi
            local k; for k in 2 7 8 9 10 11 12; do printf '\033[48;2;%sm  ' "$(hex_to_rgb "${g[$k]}")"; done
            printf '\033[38;2;%sm\033[48;2;%sm\n' "$fgrgb" "$bgrgb"
        done
    fi
    printf '\n  \033[2m↑ ↓ / TAB  trocar de item    ← →  mudar (±5)    , .  ajuste fino (±1)\n  R  renomear paleta    ENTER  continuar\033[22m\n\033[0m'
}

restore_terminal() { printf '\033]110\007\033]111\007\033[0m\033[2J\033[H'; }

confirm_screen() { # devolve 0 = aplicar, 1 = voltar a ajustar
    local sel=0 key rest
    local -a f; IFS='|' read -ra f <<< "${ICARO_PALETTES[$pi]}"
    local opacity blur="$bl"; opacity="$(op_float "$op")"
    while true; do
        printf '\033]10;%s\007\033]11;%s\007' "${f[3]}" "${f[2]}"
        printf '\033[2J\033[H\033[38;2;%sm\033[48;2;%sm' "$(hex_to_rgb "${f[3]}")" "$(hex_to_rgb "${f[2]}")"
        printf '\n  \033[1mCONFIRMAR APARÊNCIA\033[22m\n\n'
        printf '     Opacidade : %s%%\n' "$op"
        printf '     Blur      : %s\n     Paleta    : %s\n\n' "$blur" "${f[1]}"
        sim_preview "${f[2]}" "${f[3]}" "$opacity" "$blur"
        printf '\033[38;2;%sm\033[48;2;%sm\n  Tem certeza de que é essa a aparência que você quer?\n\n' "$(hex_to_rgb "${f[3]}")" "$(hex_to_rgb "${f[2]}")"
        if [ "$sel" -eq 0 ]; then printf '   \033[1;7m ❯ Sim, aplicar \033[27;22m\n      Não, voltar e ajustar\n'
        else printf '      Sim, aplicar\n   \033[1;7m ❯ Não, voltar e ajustar \033[27;22m\n'; fi
        printf '\n  \033[2m↑ ↓ escolher   ENTER confirmar   (S = sim, N = não)\033[22m\033[0m\n'
        IFS= read -rsn1 key || true
        if [ "$key" = $'\033' ]; then IFS= read -rsn2 -t 0.05 rest || true; key="$key$rest"; fi
        case "$key" in
            $'\033[A'|$'\033[B'|$'\t') sel=$((1 - sel)) ;;
            s|S) return 0 ;;
            n|N) return 1 ;;
            "") return "$sel" ;;
        esac
    done
}

apply_custom_names
trap 'restore_terminal' EXIT
focus=2
while true; do
    draw "$focus"
    IFS= read -rsn1 key || true
    if [ "$key" = $'\033' ]; then IFS= read -rsn2 -t 0.05 rest || true; key="$key$rest"; fi
    case "$key" in
        $'\033[A') focus=$(( (focus + 2) % 3 )) ;;
        $'\033[B'|$'\t') focus=$(( (focus + 1) % 3 )) ;;
        $'\033[C'|$'\033[D'|.|,)
            d=1; step=5
            { [ "$key" = $'\033[D' ] || [ "$key" = "," ]; } && d=-1
            { [ "$key" = "." ] || [ "$key" = "," ]; } && step=1
            case "$focus" in
                0) op="$(clamp $(( op + d * step )))" ;;
                1) bl="$(clamp $(( bl + d * step )))" ;;
                2) pi=$(( (pi + d + ${#ICARO_PALETTES[@]}) % ${#ICARO_PALETTES[@]} )) ;;
            esac ;;
        r|R) rename_palette "$pi" ;;
        "") if confirm_screen; then echo "$op $bl $pi" > "$OUT"; exit 0; fi ;;
    esac
done
