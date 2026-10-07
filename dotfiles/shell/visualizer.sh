#!/usr/bin/env bash
# Visualizer opcional de inicialização — Neofetch / Fastfetch.
# A configuração é gerada pelo install.sh em:
#   ~/.config/icaro-visualizer/config.sh
#
# Este arquivo é carregado independentemente dos extras (starship/eza/bat/etc.).
# Se ICARO_VISUALIZER_ENABLED=0, não executa absolutamente nada.

ICARO_VISUALIZER_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/icaro-visualizer/config.sh"
[ -f "$ICARO_VISUALIZER_CONFIG" ] || return 0 2>/dev/null || exit 0
# shellcheck disable=SC1090
source "$ICARO_VISUALIZER_CONFIG"

[ "${ICARO_VISUALIZER_ENABLED:-0}" = "1" ] || return 0 2>/dev/null || exit 0
[ -z "${ICARO_VISUALIZER_SHOWN:-}" ] || return 0 2>/dev/null || exit 0
export ICARO_VISUALIZER_SHOWN=1

case "${ICARO_VISUALIZER_TYPE:-}" in
    fastfetch)
        if command -v fastfetch >/dev/null 2>&1; then
            if [ -n "${ICARO_VISUALIZER_IMAGE:-}" ] && [ -f "${ICARO_VISUALIZER_IMAGE}" ]; then
                fastfetch \
                    --logo-type kitty \
                    --logo "${ICARO_VISUALIZER_IMAGE}" \
                    --logo-width 24 \
                    --logo-height 12 \
                    --color "${ICARO_VISUALIZER_FASTCOLOR:-@33}" \
                    2>/dev/null || true
            else
                fastfetch \
                    --color "${ICARO_VISUALIZER_FASTCOLOR:-@33}" \
                    --logo-color-1 "${ICARO_VISUALIZER_FASTCOLOR:-@33}" \
                    --logo-color-2 "${ICARO_VISUALIZER_FASTCOLOR:-@33}" \
                    2>/dev/null || true
            fi
        fi
        ;;
    neofetch)
        if command -v neofetch >/dev/null 2>&1; then
            if [ -n "${ICARO_VISUALIZER_IMAGE:-}" ] && [ -f "${ICARO_VISUALIZER_IMAGE}" ]; then
                neofetch \
                    --image_backend kitty \
                    --image_source "${ICARO_VISUALIZER_IMAGE}" \
                    --ascii_colors "${ICARO_VISUALIZER_NEOCOLOR:-4}" \
                    2>/dev/null || true
            else
                neofetch \
                    --ascii_colors "${ICARO_VISUALIZER_NEOCOLOR:-4}" \
                    2>/dev/null || true
            fi
        fi
        ;;
esac
