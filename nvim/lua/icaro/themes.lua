-- Sistema de temas: F1 = próximo, Shift+F1 = anterior.
-- Os temas do Vim (colors/*.vim) funcionam direto; os "extras" vêm de plugins
-- e são carregados sob demanda pelo lazy.nvim quando você chega neles.
local state = require("icaro.state")
local M = {}

M.list = vim.deepcopy(require("icaro.catalog"))

-- Temas extras (plugins). O id é o nome do :colorscheme.
local extras = {
  { id = "tokyonight-night", title = "Tokyo Night",     short = "TKY", subtitle = "Extra (plugin)" },
  { id = "catppuccin-mocha", title = "Catppuccin Mocha", short = "CAT", subtitle = "Extra (plugin)" },
  { id = "kanagawa",         title = "Kanagawa",        short = "KAN", subtitle = "Extra (plugin)" },
  { id = "rose-pine",        title = "Rosé Pine",       short = "ROS", subtitle = "Extra (plugin)" },
  { id = "nightfox",         title = "Nightfox",        short = "NIG", subtitle = "Extra (plugin)" },
  { id = "carbonfox",        title = "Carbonfox",       short = "CRB", subtitle = "Extra (plugin)" },
}
for _, e in ipairs(extras) do M.list[#M.list + 1] = e end

-- Temas seus: crie lua/icaro/themes_local.lua retornando uma lista de
-- { id=, title=, short=, subtitle= } (veja themes_local.lua.example).
local ok, mine = pcall(require, "icaro.themes_local")
if ok and type(mine) == "table" then
  for _, e in ipairs(mine) do M.list[#M.list + 1] = e end
end

M.index = 1
local by_id = {}
for i, t in ipairs(M.list) do by_id[t.id] = i end

function M.current() return M.list[M.index] end
function M.name() return M.current().title end
function M.short() return M.current().short end
function M.badge() return "[" .. M.short() .. "] " .. M.name() end
function M.header()
  local sub = M.current().subtitle or ""
  return sub == "" and M.badge() or (M.badge() .. " › " .. sub)
end

-- Liga grupos que temas antigos de Vim não definem (treesitter/LSP/diagnóstico/
-- floats/completion), derivando tudo do que o tema JÁ definiu. Sem isso, temas
-- feitos pro Vim ficam "pelados" no Neovim.
local function hl(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end
local function ensure(name, link, fallback)
  local cur = vim.api.nvim_get_hl(0, { name = name })
  if next(cur) == nil then
    if link then vim.api.nvim_set_hl(0, name, { link = link, default = true }) else vim.api.nvim_set_hl(0, name, fallback) end
  end
end

local function polish()
  local normal = hl("Normal")
  local bg = normal.bg
  local function fg_of(g) return hl(g).fg end
  -- diagnósticos
  for kind, src in pairs({ Error = "ErrorMsg", Warn = "WarningMsg", Info = "Special", Hint = "Comment" }) do
    ensure("Diagnostic" .. kind, nil, { fg = fg_of(src) })
    ensure("DiagnosticUnderline" .. kind, nil, { undercurl = true, sp = fg_of(src) or fg_of("Normal") })
    ensure("DiagnosticVirtualText" .. kind, "Diagnostic" .. kind)
    ensure("DiagnosticSign" .. kind, "Diagnostic" .. kind)
  end
  ensure("FloatBorder", "Comment")
  ensure("NormalFloat", "Pmenu")
  ensure("LspReferenceText", nil, { underline = true })
  ensure("LspReferenceRead", "LspReferenceText")
  ensure("LspReferenceWrite", "LspReferenceText")
  ensure("LspInlayHint", "Comment")
  ensure("WinSeparator", "VertSplit")
  -- treesitter: liga os grupos @ aos grupos clássicos que o tema já pintou
  local map = {
    ["@variable"] = "Identifier", ["@variable.builtin"] = "Special", ["@variable.parameter"] = "Identifier",
    ["@function"] = "Function", ["@function.call"] = "Function", ["@function.builtin"] = "Special",
    ["@function.method"] = "Function", ["@function.method.call"] = "Function",
    ["@constructor"] = "Special", ["@keyword"] = "Keyword", ["@keyword.function"] = "Keyword",
    ["@keyword.return"] = "Keyword", ["@keyword.operator"] = "Operator", ["@keyword.import"] = "Include",
    ["@string"] = "String", ["@string.escape"] = "SpecialChar", ["@number"] = "Number", ["@boolean"] = "Boolean",
    ["@type"] = "Type", ["@type.builtin"] = "Type", ["@property"] = "Identifier", ["@field"] = "Identifier",
    ["@comment"] = "Comment", ["@operator"] = "Operator", ["@punctuation"] = "Delimiter",
    ["@punctuation.bracket"] = "Delimiter", ["@namespace"] = "Include", ["@module"] = "Include",
    ["@constant"] = "Constant", ["@constant.builtin"] = "Constant", ["@macro"] = "Macro",
    ["@label"] = "Label", ["@attribute"] = "PreProc", ["@tag"] = "Tag",
    ["@lsp.type.class"] = "Type", ["@lsp.type.interface"] = "Type", ["@lsp.type.enum"] = "Type",
    ["@lsp.type.parameter"] = "Identifier", ["@lsp.type.property"] = "Identifier",
  }
  for g, l in pairs(map) do ensure(g, l) end
  -- menus de completion
  ensure("BlinkCmpMenu", "Pmenu")
  ensure("BlinkCmpMenuBorder", "FloatBorder")
  ensure("BlinkCmpMenuSelection", "PmenuSel")
  ensure("BlinkCmpDoc", "NormalFloat")
  ensure("BlinkCmpDocBorder", "FloatBorder")
  ensure("BlinkCmpSignatureHelp", "NormalFloat")
  ensure("BlinkCmpSignatureHelpBorder", "FloatBorder")
  -- barra de abas / neo-tree herdam do tema
  if bg then ensure("NeoTreeNormal", nil, { bg = bg, fg = normal.fg }) end
  ensure("NeoTreeNormalNC", "NeoTreeNormal")
  ensure("NeoTreeWinSeparator", "WinSeparator")

  -- Pequenos detalhes visuais que funcionam com praticamente qualquer tema.
  ensure("CursorLineNr", "LineNr")
  ensure("CursorLineSign", "SignColumn")
  ensure("WinBar", "NormalFloat")
  ensure("WinBarNC", "Comment")
  ensure("IblIndent", "NonText")
  ensure("IblScope", "Special")
  ensure("MiniCursorword", "Visual")
  ensure("MiniCursorwordCurrent", "Visual")
end

local function announce()
  vim.api.nvim_echo({ { "  " .. M.header(), "Title" } }, false, {})
end

local function apply(idx, quiet)
  idx = ((idx - 1) % #M.list) + 1
  local t = M.list[idx]
  M.index = idx
  local ok, err = pcall(vim.cmd.colorscheme, t.id)
  if not ok then
    vim.notify("Tema '" .. t.id .. "' não pôde ser carregado: " .. tostring(err), vim.log.levels.WARN)
    return false
  end
  state.set("theme", t.id)
  if not quiet then announce() end
  return true
end

function M.next() apply(M.index + 1) end
function M.prev() apply(M.index - 1) end
function M.apply_saved()
  local saved = state.get("theme", nil)
  M.index = by_id[saved] or 1
  -- se o tema salvo falhar, cai pro próximo que funcione
  for step = 0, #M.list - 1 do
    if apply(M.index + step, true) then return end
  end
end

-- Se alguém trocar de tema por fora (:colorscheme, telescope), sincroniza o índice
-- e reaplica o polimento.
function M.setup()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("icaro_theme_sync", { clear = true }),
    callback = function(ev)
      local i = by_id[ev.match]
      if i then M.index = i; state.set("theme", ev.match) end
      polish()
    end,
  })
  M.apply_saved()
  polish()
end

function M.pick()
  local items = {}
  for i, t in ipairs(M.list) do
    items[#items + 1] = string.format("%2d. %s  [%s]%s", i, t.title, t.short, (t.subtitle or "") ~= "" and ("  › " .. t.subtitle) or "")
  end
  vim.ui.select(items, { prompt = "Tema" }, function(_, idx) if idx then apply(idx) end end)
end

return M
