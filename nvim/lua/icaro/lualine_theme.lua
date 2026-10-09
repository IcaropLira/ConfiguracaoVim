-- Tema do lualine gerado a partir do tema de cores ativo.
--  • O modo Insert (e Visual/Replace/Command) usa VARIAÇÕES da cor principal do tema,
--    em vez do verde fixo que o tema "auto" pegava de `String`.
--  • Todo texto da barra é conferido por contraste (WCAG): se ficar ilegível sobre o
--    fundo (ex.: GVSL, que é claro), o texto vira escuro/claro conforme precisar.
local M = {}

-- ---------- cores ----------
local function hex2rgb(h)
  h = tostring(h):gsub("#", "")
  if #h ~= 6 then return nil end
  return tonumber(h:sub(1, 2), 16) / 255, tonumber(h:sub(3, 4), 16) / 255, tonumber(h:sub(5, 6), 16) / 255
end
local function rgb2hex(r, g, b)
  local function c(x) return math.floor(math.max(0, math.min(1, x)) * 255 + 0.5) end
  return string.format("#%02x%02x%02x", c(r), c(g), c(b))
end
local function rgb2hsl(r, g, b)
  local mx, mn = math.max(r, g, b), math.min(r, g, b)
  local l = (mx + mn) / 2
  if mx == mn then return 0, 0, l end
  local d = mx - mn
  local s = l > 0.5 and d / (2 - mx - mn) or d / (mx + mn)
  local h
  if mx == r then h = (g - b) / d + (g < b and 6 or 0)
  elseif mx == g then h = (b - r) / d + 2
  else h = (r - g) / d + 4 end
  return h * 60, s, l
end
local function hsl2rgb(h, s, l)
  h = (h % 360) / 360
  if s == 0 then return l, l, l end
  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  local function f(t)
    if t < 0 then t = t + 1 elseif t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end
  return f(h + 1 / 3), f(h), f(h - 1 / 3)
end
local function lin(x) return x <= 0.03928 and x / 12.92 or ((x + 0.055) / 1.055) ^ 2.4 end
local function luminance(hex)
  local r, g, b = hex2rgb(hex)
  if not r then return 0 end
  return 0.2126 * lin(r) + 0.7152 * lin(g) + 0.0722 * lin(b)
end
function M.contrast(a, b)
  local la, lb = luminance(a), luminance(b)
  if la < lb then la, lb = lb, la end
  return (la + 0.05) / (lb + 0.05)
end
local function hsl_shift(hex, dh, ds, dl)
  local r, g, b = hex2rgb(hex)
  if not r then return hex end
  local h, s, l = rgb2hsl(r, g, b)
  return rgb2hex(hsl2rgb(h + dh, math.max(0, math.min(1, s + ds)), math.max(0.08, math.min(0.92, l + dl))))
end

-- helpers reaproveitados por icaro/polish.lua (popups, contraste de variáveis, GVSL)
M.shift = hsl_shift
M.luminance = luminance

local DARK, LIGHT = "#0d0d14", "#ffffff"
-- texto legível sobre `bg`: mantém `fg` se já tem contraste; senão escurece/clareia o próprio
-- `fg` (preservando o tom) e, em último caso, usa preto/branco.
function M.readable(fg, bg, min)
  min = min or 4.5
  if not bg then return fg end
  if fg and hex2rgb(fg) and M.contrast(fg, bg) >= min then return fg end
  local r, g, b = hex2rgb(fg or "")
  if r then
    local dir = luminance(bg) > 0.4 and -0.04 or 0.04
    local h, s, l = rgb2hsl(r, g, b)
    for _ = 1, 24 do
      l = l + dir
      local c = rgb2hex(hsl2rgb(h, s, l))
      if M.contrast(c, bg) >= min then return c end
    end
  end
  return M.contrast(DARK, bg) >= M.contrast(LIGHT, bg) and DARK or LIGHT
end
-- melhor entre escuro e claro sobre `bg` (rótulo do modo)
local function label_on(bg) return M.contrast(DARK, bg) >= M.contrast(LIGHT, bg) and DARK or LIGHT end
-- se nem preto nem branco leem bem sobre `bg` (tons médios), empurra a luz do fundo até ler
local function fit_bg(bg, min)
  local best = math.max(M.contrast(DARK, bg), M.contrast(LIGHT, bg))
  if best >= min then return bg end
  local dir = M.contrast(DARK, bg) >= M.contrast(LIGHT, bg) and 0.03 or -0.03
  local c = bg
  for _ = 1, 12 do
    c = hsl_shift(c, 0, 0, dir)
    if math.max(M.contrast(DARK, c), M.contrast(LIGHT, c)) >= min then return c end
  end
  return c
end

-- ---------- tema ----------
local function hl_color(group, attr)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if ok and h and h[attr] then return string.format("#%06x", h[attr]) end
end

local function base_theme()
  package.loaded["lualine.themes.auto"] = nil
  local ok, t = pcall(require, "lualine.themes.auto")
  if ok and type(t) == "table" then return t end
end

function M.build()
  local base = base_theme() or {}
  local function get(mode, sec, key)
    local m = base[mode] or base.normal or {}
    return m[sec] and m[sec][key]
  end
  local normal_bg = hl_color("Normal", "bg") or "#101014"
  local normal_fg = hl_color("Normal", "fg") or "#d0d0d0"

  -- cor principal do tema = fundo do modo Normal (a mesma que você já via roxa no Alan Turing)
  local main = get("normal", "a", "bg") or hl_color("PmenuSel", "bg") or hl_color("Function", "fg") or "#7aa2f7"
  if not hex2rgb(main) then main = "#7aa2f7" end

  -- variações da cor principal: mesmo "clima", tom/luz um pouco diferentes
  local _, _, l = rgb2hsl(hex2rgb(main))
  local up = l < 0.55 and 0.14 or -0.14 -- clareia temas escuros, escurece os claros
  local mode_bg = {
    normal  = main,
    insert  = hsl_shift(main, 0, 0.05, up),
    visual  = hsl_shift(main, 32, 0, up / 2),
    replace = hsl_shift(main, -32, 0.05, -up / 2),
    command = hsl_shift(main, 62, 0, up / 3),
  }

  local b_bg = get("normal", "b", "bg") or hl_color("StatusLine", "bg") or normal_bg
  local b_fg = get("normal", "b", "fg") or normal_fg
  local c_bg = get("normal", "c", "bg") or normal_bg
  local c_fg = get("normal", "c", "fg") or normal_fg
  -- escada de 3 tons (a = cor principal, b = tom médio, c = fundo): se o tema entrega b quase
  -- igual a c, o bloco do meio some e a barra vira uma faixa chapada. Separa um pouco.
  if M.contrast(b_bg, c_bg) < 1.12 then
    b_bg = hsl_shift(b_bg, 0, 0, luminance(c_bg) > 0.4 and -0.07 or 0.07)
  end
  b_fg = M.readable(b_fg, b_bg)
  c_fg = M.readable(c_fg, c_bg)

  local theme = {}
  for mode, bg in pairs(mode_bg) do
    bg = fit_bg(bg, 4.5)
    local z_bg = fit_bg(hsl_shift(bg, 24, 0, up / 3), 4.5)
    theme[mode] = {
      a = { bg = bg, fg = label_on(bg), gui = "bold" },
      b = { bg = b_bg, fg = M.readable(b_fg, b_bg) },
      c = { bg = c_bg, fg = c_fg },
      y = { bg = b_bg, fg = M.readable(b_fg, b_bg) },
      z = { bg = z_bg, fg = label_on(z_bg), gui = "bold" },
    }
  end
  local ina_bg = get("inactive", "c", "bg") or c_bg
  local ina_fg = M.readable(get("inactive", "c", "fg") or c_fg, ina_bg, 3)
  theme.inactive = {
    a = { bg = ina_bg, fg = ina_fg },
    b = { bg = ina_bg, fg = ina_fg },
    c = { bg = ina_bg, fg = ina_fg },
  }
  return theme
end

return M
