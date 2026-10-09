-- Toggles (F3, F4, F10, Shift+F3, Shift+F4, Shift+F10, Shift+F11, Shift+F12) com estado restaurável.
local state = require("icaro.state")
local M = {}

local AC_FTS = { cpp = true, java = true, python = true }
local function ac_key(ft) return AC_FTS[ft] and ft or "outros" end
local function say(msg) vim.api.nvim_echo({ { "  " .. msg, "Title" } }, false, {}) end
local function onoff(b) return b and "LIGADO" or "DESLIGADO" end

-- ---------- estados (lidos do disco, com padrão = tudo ligado) ----------
M.s = {
  ac = state.get("ac", {}),                 -- autocomplete POR linguagem
  inlay = state.get("inlay", true),
  pairs = state.get("pairs", true),         -- fecha-pares + assinatura
  matchparen = state.get("matchparen", true),
  header = state.get("header", true),
  hints = state.get("hints", false),        -- popups de assinatura/documentação (Shift+F3): desligado por padrão
  diag = state.get("diag", true),           -- avisos/erros de código (Shift+F4)
}
vim.g.icaro_lsp_progress = state.get("lsp_progress", false) -- mensagens "Validate documents jdtls"
vim.g.icaro_quiet = false

local function ac_on(ft) return M.s.ac[ac_key(ft)] ~= false end

-- dicas (assinatura de método + documentação ao lado das sugestões)
function M.hints_on() return M.s.hints and not vim.g.icaro_quiet end

function M.completion_enabled()
  return not vim.g.icaro_quiet and ac_on(vim.bo.filetype)
end
function M.ac_label()
  if vim.g.icaro_quiet then return "AC off (silencioso)" end
  return ac_on(vim.bo.filetype) and "AC on" or "AC off"
end

-- ---------- aplicadores (idempotentes) ----------
local function apply_inlay(on)
  if vim.lsp.inlay_hint then pcall(vim.lsp.inlay_hint.enable, on) end
end
local function apply_pairs(on)
  local ok, ap = pcall(require, "nvim-autopairs")
  if ok then if on then ap.enable() else ap.disable() end end
end
-- marcas de erro/aviso na barra de rolagem (nvim-scrollbar) acompanham o toggle
local function sync_scrollbar(on)
  if not package.loaded["scrollbar"] then return end
  local ok, dh = pcall(require, "scrollbar.handlers.diagnostic")
  local ok2, utils = pcall(require, "scrollbar.utils")
  if not (ok and ok2) then return end
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(b) then
      if on then pcall(dh.handler.show, nil, b, nil, nil)
      else pcall(function()
        local m = utils.get_scrollbar_marks(b); m.diagnostics = {}; utils.set_scrollbar_marks(b, m)
      end) end
    end
  end
  pcall(function() require("scrollbar").throttled_render() end)
end
local function apply_diag(on)
  -- enable(false) só esconde (não apaga): ao religar, os avisos voltam na hora
  vim.diagnostic.enable(on)
  sync_scrollbar(on)
end
-- documentação automática ao lado das sugestões do blink.cmp acompanha as "dicas"
local function apply_docs()
  pcall(function() require("blink.cmp.config").completion.documentation.auto_show = M.hints_on() end)
end
local function close_hints()
  pcall(function() require("icaro.signature").close() end)
  pcall(function() require("blink.cmp").hide_documentation() end)
end
local function apply_matchparen(on)
  vim.cmd(on and "silent! DoMatchParen" or "silent! NoMatchParen")
end
local function apply_header(on)
  local ok, ll = pcall(require, "lualine")
  if ok then ll.hide({ place = { "winbar" }, unhide = on }) end
  if on then
    vim.o.winbar = vim.o.winbar -- lualine redefine ao reaparecer
  end
end

local function close_popups()
  pcall(function() require("blink.cmp").hide() end)
  pcall(vim.lsp.buf.clear_references)
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local cfg = vim.api.nvim_win_get_config(w)
    if cfg.relative ~= "" then
      local b = vim.api.nvim_win_get_buf(w)
      local ft = vim.bo[b].filetype
      local keep = vim.bo[b].buftype == "terminal" or ft == "icaro-cheatsheet" or ft:match("^Telescope") or ft == "lazy" or ft == "mason"
      if not keep and (cfg.focusable == false or ft == "markdown" or ft == "" or ft:match("^blink")) then
        pcall(vim.api.nvim_win_close, w, true)
      end
    end
  end
end

-- ---------- F4: autocomplete (por linguagem) ----------
function M.autocomplete()
  local ft = vim.bo.filetype
  local k = ac_key(ft)
  M.s.ac[k] = not ac_on(ft)
  state.set("ac", M.s.ac)
  if not M.s.ac[k] then pcall(function() require("blink.cmp").hide() end) end
  say(("Autocomplete (%s): %s"):format(k, onoff(M.s.ac[k])))
  pcall(function() require("lualine").refresh() end)
end

-- ---------- F3: inlay hints ----------
function M.inlay()
  M.s.inlay = not M.s.inlay
  state.set("inlay", M.s.inlay)
  if not vim.g.icaro_quiet then apply_inlay(M.s.inlay) end
  say("Dicas de parâmetro inline (inlay hints): " .. onoff(M.s.inlay))
end

-- ---------- F10: fecha-pares ----------
function M.autopairs()
  M.s.pairs = not M.s.pairs
  state.set("pairs", M.s.pairs)
  if not vim.g.icaro_quiet then apply_pairs(M.s.pairs) end
  say("Fecha-parênteses/aspas automático: " .. onoff(M.s.pairs))
end

-- ---------- Shift+F3: dicas (popups de assinatura de método e documentação) ----------
function M.hints()
  M.s.hints = not M.s.hints
  state.set("hints", M.s.hints)
  apply_docs()
  if not M.s.hints then close_hints() end
  say("Dicas de método (assinatura + documentação nas sugestões): " .. onoff(M.s.hints))
end

-- ---------- Shift+F4: avisos/erros do código (diagnósticos) ----------
function M.diagnostics()
  M.s.diag = not M.s.diag
  state.set("diag", M.s.diag)
  if not vim.g.icaro_quiet then apply_diag(M.s.diag) end
  say("Avisos e erros no código (texto, sublinhado, sinais): " .. onoff(M.s.diag))
end

-- ---------- mensagens de progresso do LSP ("Validate documents jdtls") ----------
-- Escondidas por padrão. :LspProgress mostra/esconde.
function M.lsp_progress()
  vim.g.icaro_lsp_progress = not vim.g.icaro_lsp_progress
  state.set("lsp_progress", vim.g.icaro_lsp_progress)
  say("Mensagens de progresso do LSP: " .. onoff(vim.g.icaro_lsp_progress))
end

-- ---------- Shift+F10: matchparen ----------
function M.matchparen()
  M.s.matchparen = not M.s.matchparen
  state.set("matchparen", M.s.matchparen)
  if not vim.g.icaro_quiet then apply_matchparen(M.s.matchparen) end
  say("Destaque do par de parênteses: " .. onoff(M.s.matchparen))
end

-- ---------- Shift+F12: header (winbar) ----------
function M.header()
  M.s.header = not M.s.header
  state.set("header", M.s.header)
  apply_header(M.s.header)
  say("Header no topo: " .. onoff(M.s.header))
end

-- ---------- Shift+F11: modo silencioso ----------
-- Liga: fecha popups/floats, desliga sugestões, dicas, inlay hints, pares,
--       diagnósticos (sinais, virtual text, sublinhado) e matchparen.
-- Desliga: restaura EXATAMENTE o que estava antes (não liga tudo às cegas).
local saved
function M.quiet()
  if not vim.g.icaro_quiet then
    saved = {
      ac = vim.deepcopy(M.s.ac),
      diag_config = vim.deepcopy(vim.diagnostic.config()),
    }
    vim.g.icaro_quiet = true
    apply_docs()
    close_popups()
    close_hints()
    apply_inlay(false)
    apply_pairs(false)
    apply_matchparen(false)
    vim.diagnostic.config({ virtual_text = false, virtual_lines = false, signs = false, underline = false })
    apply_diag(false)
    say("Modo silencioso: popups, sugestões, assinatura, inlay hints, pares, diagnósticos e matchparen DESLIGADOS")
  else
    vim.g.icaro_quiet = false
    if saved then
      M.s.ac = saved.ac
      vim.diagnostic.config(saved.diag_config)
    end
    -- restaura o estado ATUAL de cada toggle (inclusive o que mudou durante o silêncio)
    apply_docs()
    apply_diag(M.s.diag)
    apply_inlay(M.s.inlay)
    apply_pairs(M.s.pairs)
    apply_matchparen(M.s.matchparen)
    say("Modo silencioso: DESLIGADO — estados anteriores restaurados")
  end
  pcall(function() require("lualine").refresh() end)
end

-- reaplica o header (usado depois que o lualine é reconfigurado ao trocar de tema)
function M.reapply_header() apply_header(M.s.header) end

-- aplica o estado salvo no início
function M.setup()
  apply_pairs(M.s.pairs)
  apply_matchparen(M.s.matchparen)
  if not M.s.diag then apply_diag(false) end
  require("icaro.signature").setup()
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("icaro_inlay", { clear = true }),
    callback = function() if not vim.g.icaro_quiet then apply_inlay(M.s.inlay) end end,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function() apply_header(M.s.header); apply_pairs(M.s.pairs) end,
  })
end

return M
