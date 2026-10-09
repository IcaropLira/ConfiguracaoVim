-- Polimento visual que depende das CORES REAIS do tema ativo (não só de ligar grupos faltantes,
-- isso continua em themes.lua). Tudo aqui é derivado do que o tema já definiu e conferido por
-- contraste (WCAG), então funciona igual em temas escuros, claros e nos criados via themes_local.
--
--   1. Popups/floats: borda e fundo coerentes com o tema (sem o contorno preto "escapando").
--   2. Menu de autocomplete (blink.cmp): menu, linha selecionada, trecho casado, detalhes.
--   3. Contraste de variáveis, parâmetros e propriedades (grupos clássicos, Tree-sitter e LSP).
--   4. Ajustes específicos do tema GVSL (paleta clara marcada como background=dark).
--
-- É reaplicado quando o tema muda (themes.lua), quando um LSP conecta e na primeira vez que o
-- menu do blink abre — equivalente ao "CocNvimInit" da versão Vim.
local lt = require("icaro.lualine_theme")
local M = {}

-- ---------- utilidades ----------
local function resolved(name)
  local ok, h = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
  return (ok and h) or {}
end
local function hexof(n) return n and string.format("#%06x", n) or nil end
local function fg(name) return hexof(resolved(name).fg) end
local function bg(name) return hexof(resolved(name).bg) end

-- Mescla `attrs` por cima do que o grupo já resolve (preserva bold/italic etc.).
local function set(name, attrs)
  local cur = resolved(name)
  cur.ctermfg, cur.ctermbg = nil, nil
  vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", cur, attrs))
end

-- Cor legível em DOIS fundos ao mesmo tempo (ex.: linha normal e linha selecionada do menu).
local function both(color, a, b, min)
  local c = lt.readable(color, a, min)
  if lt.contrast(c, b) >= min then return c end
  local c2 = lt.readable(color, b, min)
  if lt.contrast(c2, a) >= min then return c2 end
  return c
end

-- ---------- paleta dos popups ----------
-- primeira cor da lista (aceita nil no meio) que já tem contraste suficiente sobre `on`
local function pick(on, min, ...)
  for i = 1, select("#", ...) do
    local c = select(i, ...)
    if c and lt.contrast(c, on) >= min then return c end
  end
end

local function palette()
  local nbg = bg("Normal") or "#16161e"
  local nfg = fg("Normal") or "#d0d0d0"
  local light = lt.luminance(nbg) > 0.4

  local pbg = bg("Pmenu")
  if not pbg or pbg:lower() == nbg:lower() then
    pbg = lt.shift(nbg, 0, 0, light and -0.05 or 0.06)
  end

  -- Linha selecionada. Se o tema usa polaridade OPOSTA à do menu (menu claro + seleção escura,
  -- como no GVSL, ou o contrário), nenhuma cor de texto/trecho-casado serve nos dois fundos ao
  -- mesmo tempo; nesse caso a seleção vira um tom da própria família do menu.
  local sel = bg("PmenuSel")
  local pl = lt.luminance(pbg) > 0.35
  if not sel or (lt.luminance(sel) > 0.35) ~= pl then
    sel = lt.shift(pbg, 0, 0, pl and -0.12 or 0.12)
  end

  local pfg = pick(pbg, 4.5, fg("Pmenu"), nfg) or lt.readable(fg("Pmenu") or nfg, pbg, 4.5)
  local sfg = pick(sel, 4.5, fg("PmenuSel"), pfg, nbg, nfg) or lt.readable(fg("PmenuSel") or pfg, sel, 4.5)

  -- cor de destaque do tema: a mesma do bloco principal da barra, com fallback em outros grupos
  -- (2.2:1 basta para uma moldura/scrollbar e preserva o roxo de temas como o Iogurte)
  local accent = pick(pbg, 2.2, bg("TabLineSel"), fg("Function"), fg("Special"), fg("Title"), fg("WinSeparator"), bg("PmenuSel"))
    or lt.readable(nfg, pbg, 3)

  local muted = both(fg("Comment") or fg("NonText") or pfg, pbg, sel, 3.5)
  local match = both(fg("PmenuMatch") or fg("Special") or accent, pbg, sel, 4.5)

  return { nbg = nbg, nfg = nfg, pbg = pbg, sel = sel, pfg = pfg, sfg = sfg, accent = accent, muted = muted, match = match }
end

-- ---------- 1) popups ----------
local function popups(p)
  -- fundo único para todo float => a célula da borda tem o MESMO fundo do conteúdo (some o contorno preto)
  set("NormalFloat", { fg = p.pfg, bg = p.pbg })
  set("FloatBorder", { fg = p.accent, bg = p.pbg })
  set("FloatTitle", { fg = p.accent, bg = p.pbg, bold = true })
  set("FloatFooter", { fg = p.muted, bg = p.pbg })
  set("Pmenu", { fg = p.pfg, bg = p.pbg })
  set("PmenuSel", { fg = p.sfg, bg = p.sel, bold = true })
  set("PmenuSbar", { bg = p.pbg })
  set("PmenuThumb", { bg = p.accent })
  set("PmenuMatch", { fg = p.match, bg = p.pbg, bold = true })
  set("PmenuMatchSel", { fg = p.match, bg = p.sel, bold = true })

  -- plugins que nascem com borda própria (colorida/diferente) passam a seguir o tema
  for _, g in ipairs({ "TelescopeBorder", "TelescopePromptBorder", "TelescopeResultsBorder",
    "TelescopePreviewBorder", "NeoTreeFloatBorder", "WhichKeyBorder", "LazyBorder", "MasonBorder" }) do
    set(g, { fg = p.accent, bg = p.pbg })
  end
  -- noice: o popup da cmdline usa o fundo do editor, não o do menu
  for _, g in ipairs({ "NoiceCmdlinePopupBorder", "NoiceConfirmBorder", "NoicePopupBorder", "NoicePopupmenuBorder" }) do
    set(g, { fg = p.accent, bg = p.nbg })
  end
end

-- ---------- 2) menu de autocomplete (blink.cmp) ----------
local function completion(p)
  set("BlinkCmpMenu", { fg = p.pfg, bg = p.pbg })
  set("BlinkCmpMenuBorder", { fg = p.accent, bg = p.pbg })
  set("BlinkCmpMenuSelection", { fg = p.sfg, bg = p.sel, bold = true })
  set("BlinkCmpScrollBarThumb", { bg = p.accent })
  set("BlinkCmpScrollBarGutter", { bg = p.pbg })

  set("BlinkCmpLabel", { fg = p.pfg })
  set("BlinkCmpLabelMatch", { fg = p.match, bold = true })
  set("BlinkCmpLabelDeprecated", { fg = p.muted, strikethrough = true })
  -- informações complementares (detalhe, descrição, fonte, tipo)
  set("BlinkCmpLabelDetail", { fg = p.muted })
  set("BlinkCmpLabelDescription", { fg = p.muted })
  set("BlinkCmpSource", { fg = p.muted })
  set("BlinkCmpKind", { fg = both(p.accent, p.pbg, p.sel, 3) })
  set("BlinkCmpGhostText", { fg = p.muted, italic = true })

  -- janela de documentação e de assinatura
  set("BlinkCmpDoc", { fg = p.pfg, bg = p.pbg })
  set("BlinkCmpDocBorder", { fg = p.accent, bg = p.pbg })
  set("BlinkCmpDocSeparator", { fg = p.muted, bg = p.pbg })
  set("BlinkCmpDocCursorLine", { bg = p.sel })
  set("BlinkCmpSignatureHelp", { fg = p.pfg, bg = p.pbg })
  set("BlinkCmpSignatureHelpBorder", { fg = p.accent, bg = p.pbg })
  set("BlinkCmpSignatureHelpActiveParameter", { fg = p.match, bold = true, underline = true })
end

-- ---------- 3) contraste de variáveis / parâmetros / propriedades ----------
-- Grupos "base": se o tema não deu cor, usam o fg de Normal (nunca branco puro em tema claro).
local CORE = { "Identifier", "@variable", "@variable.parameter", "@variable.member", "@property", "@field" }
-- Grupos de tokens semânticos (LSP): só mexe se já tiverem cor — sem cor própria eles deixam o
-- Tree-sitter pintar, e forçar uma cor aqui apagaria a diferença entre variável/parâmetro/membro.
local SEMANTIC = {
  "@variable.builtin", "@lsp.type.variable", "@lsp.type.parameter", "@lsp.type.property",
  "@lsp.typemod.variable.readonly", "@lsp.typemod.variable.defaultLibrary",
}

local function lift(name, min, fallback)
  local cur = resolved(name)
  local color = hexof(cur.fg) or fallback
  if not color then return end
  local nbg = bg("Normal")
  if not nbg then return end
  local fixed = lt.readable(color, nbg, min)
  if fixed:lower() ~= (hexof(cur.fg) or ""):lower() then set(name, { fg = fixed }) end
end

local function variables(p)
  for _, g in ipairs(CORE) do lift(g, 4.5, p.nfg) end
  for _, g in ipairs(SEMANTIC) do lift(g, 4.5, nil) end
end

-- ---------- 4) GVSL ----------
-- Paleta clara (bg #fff6d8) marcada como background=dark. Alguns tons de acento ficam abaixo de
-- 4.5:1 sobre esse fundo (verde, laranja, ciano e o comentário) e o Neovim ainda cria grupos novos
-- (@lsp.*) que o gvsl.vim do Vim nunca conheceu. Aqui escurecemos só o necessário, mantendo o tom.
local function gvsl(p)
  for _, g in ipairs({ "String", "Character", "Number", "Float", "Constant", "Boolean", "Function", "Type",
    "Statement", "Conditional", "Repeat", "Keyword", "Exception", "Operator", "PreProc", "Include", "Define",
    "Macro", "Special", "SpecialChar", "Tag", "Title", "Directory" }) do
    lift(g, 4.5, nil)
  end
  lift("Comment", 4.0, nil)
  lift("Delimiter", 4.5, nil)

  -- variáveis seguem o texto principal; parâmetros (laranja) e membros (ciano) mantêm a identidade
  set("@variable", { fg = p.nfg })
  set("@lsp.type.variable", { fg = p.nfg })
  set("@lsp.typemod.variable.readonly", { fg = p.nfg, bold = true })
  set("@variable.builtin", { fg = lt.readable(fg("Type") or "#4c6d9d", p.nbg, 4.5), bold = true })
  -- cin/cout/endl e afins (biblioteca padrão) ganham o azul dos tipos, em negrito
  set("@lsp.typemod.variable.defaultLibrary", { fg = lt.readable(fg("Type") or "#4c6d9d", p.nbg, 4.5), bold = true })
  set("@lsp.typemod.function.defaultLibrary", { fg = lt.readable(fg("Function") or "#b05d27", p.nbg, 4.5), bold = true })
  set("LspInlayHint", { fg = lt.readable(fg("@variable.member") or "#3d7f7a", p.nbg, 4.5), bg = lt.shift(p.nbg, 0, 0, -0.05), italic = true })
  set("LspReferenceText", { bg = p.sel })
  set("LspReferenceRead", { bg = p.sel })
  set("LspReferenceWrite", { bg = p.sel, underline = true })
end

-- ---------- entrada ----------
local function apply_all()
  local p = palette()
  popups(p)
  completion(p)
  variables(p)
  if vim.g.colors_name == "gvsl" then gvsl(p) end
end

function M.apply()
  local ok, err = pcall(apply_all)
  if not ok then
    vim.schedule(function() vim.notify_once("icaro.polish: " .. tostring(err), vim.log.levels.WARN) end)
  end
end

-- Reaplica quando o tema muda (themes.lua chama M.apply), quando um LSP conecta (grupos @lsp.*
-- só ficam completos depois) e na 1ª abertura do menu do blink (ele cria os grupos dele só então).
function M.setup()
  local group = vim.api.nvim_create_augroup("icaro_polish", { clear = true })
  local pending = false
  local function later()
    if pending then return end
    pending = true
    vim.schedule(function() pending = false; M.apply() end)
  end
  vim.api.nvim_create_autocmd("LspAttach", { group = group, callback = later })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "VeryLazy", callback = later })
  vim.api.nvim_create_autocmd("User", { group = group, pattern = "BlinkCmpMenuOpen", once = true, callback = later })
  M.apply()
end

return M
