-- Toggles (F3, F4, F10, Shift+F10, Shift+F11, Shift+F12) com estado restaurável.
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
}
vim.g.icaro_quiet = false

local function ac_on(ft) return M.s.ac[ac_key(ft)] ~= false end

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
  vim.g.icaro_signature = on
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

-- ---------- F10: fecha-pares + assinatura ----------
function M.autopairs()
  M.s.pairs = not M.s.pairs
  state.set("pairs", M.s.pairs)
  if not vim.g.icaro_quiet then apply_pairs(M.s.pairs) end
  say("Fecha-parênteses/aspas e popup de assinatura: " .. onoff(M.s.pairs))
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
-- Liga: fecha popups/floats, desliga sugestões, assinatura, inlay hints, pares,
--       diagnósticos (sinais, virtual text, sublinhado) e matchparen.
-- Desliga: restaura EXATAMENTE o que estava antes (não liga tudo às cegas).
local saved
function M.quiet()
  if not vim.g.icaro_quiet then
    saved = {
      inlay = M.s.inlay, pairs = M.s.pairs, matchparen = M.s.matchparen,
      ac = vim.deepcopy(M.s.ac),
      diag_enabled = vim.diagnostic.is_enabled(),
      diag_config = vim.deepcopy(vim.diagnostic.config()),
    }
    vim.g.icaro_quiet = true
    close_popups()
    apply_inlay(false)
    apply_pairs(false)                 -- pares + assinatura
    apply_matchparen(false)
    vim.diagnostic.config({ virtual_text = false, virtual_lines = false, signs = false, underline = false })
    vim.diagnostic.enable(false)
    vim.diagnostic.reset()
    say("Modo silencioso: popups, sugestões, assinatura, inlay hints, pares, diagnósticos e matchparen DESLIGADOS")
  else
    vim.g.icaro_quiet = false
    if saved then
      M.s.ac = saved.ac
      vim.diagnostic.config(saved.diag_config)
      if saved.diag_enabled then vim.diagnostic.enable(true) end
      apply_inlay(saved.inlay)
      apply_pairs(saved.pairs)
      apply_matchparen(saved.matchparen)
    end
    say("Modo silencioso: DESLIGADO — estados anteriores restaurados")
  end
  pcall(function() require("lualine").refresh() end)
end

-- aplica o estado salvo no início
function M.setup()
  apply_pairs(M.s.pairs)
  apply_matchparen(M.s.matchparen)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("icaro_inlay", { clear = true }),
    callback = function() if not vim.g.icaro_quiet then apply_inlay(M.s.inlay) end end,
  })
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function() apply_header(M.s.header); apply_pairs(M.s.pairs) end,
  })
  -- assinatura de método automática ao digitar ( e ,  (só se F10 estiver ligado)
  vim.api.nvim_create_autocmd("InsertCharPre", {
    group = vim.api.nvim_create_augroup("icaro_signature", { clear = true }),
    callback = function()
      if vim.g.icaro_signature == false or vim.g.icaro_quiet then return end
      local c = vim.v.char
      if c == "(" or c == "," then
        vim.defer_fn(function()
          if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" then
            pcall(vim.lsp.buf.signature_help, { focusable = false, border = "rounded" })
          end
        end, 40)
      end
    end,
  })
end

return M
