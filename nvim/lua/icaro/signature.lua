-- Popup de assinatura de método COMPACTO (substitui o do noice/nvim, que lista todas as
-- sobrecargas com documentação e cobria metade da tela).
--   • uma linha só: a assinatura ativa, com o parâmetro atual destacado
--   • "(2/5)" quando há sobrecargas; largura se adapta à janela; aparece ACIMA do cursor
--   • sem documentação (isso fica no K / Ctrl+Space)
-- Automático só quando "dicas" (Shift+F3) estiver ligado; <C-k> e <leader>s sempre mostram.
local M = {}

local ns = vim.api.nvim_create_namespace("icaro_signature")
local win, last_key
local seq = 0

function M.close()
  if win and vim.api.nvim_win_is_valid(win) then pcall(vim.api.nvim_win_close, win, true) end
  win, last_key = nil, nil
end

function M.is_open() return win ~= nil and vim.api.nvim_win_is_valid(win) end

local function byte_index(label, idx)
  local ok, b = pcall(vim.str_byteindex, label, "utf-16", idx)
  if ok and b then return b end
  ok, b = pcall(vim.str_byteindex, label, idx, true) -- Neovim 0.10
  if ok and b then return b end
  return idx
end

-- Calcula o trecho (em bytes, base 0) do parâmetro ativo dentro do label.
local function active_range(sig, result, label)
  local ap = sig.activeParameter or result.activeParameter
  local p = ap and sig.parameters and sig.parameters[ap + 1]
  if not p or not p.label then return end
  if type(p.label) == "table" then
    return byte_index(label, p.label[1]), byte_index(label, p.label[2])
  end
  local s, e = label:find(p.label, 1, true)
  if s then return s - 1, e end
end

local function handler(err, result, ctx)
  if err or not result or not result.signatures or #result.signatures == 0 then return M.close() end
  if vim.api.nvim_get_current_buf() ~= ctx.bufnr then return end

  local idx = (result.activeSignature or 0) + 1
  local sig = result.signatures[idx] or result.signatures[1]
  local label = sig.label
  local s, e
  if not label:find("\n", 1, true) then
    s, e = active_range(sig, result, label)
  else
    label = label:gsub("%s*\n%s*", " ")
  end
  local suffix = #result.signatures > 1 and ("  (%d/%d)"):format(idx, #result.signatures) or ""

  local key = label .. suffix .. tostring(s) .. tostring(e)
  if key == last_key and M.is_open() then return end
  M.close()

  local maxw = math.max(30, math.min(90, math.floor(vim.o.columns * 0.6)))
  local ft = vim.bo[ctx.bufnr].filetype
  local buf, w = vim.lsp.util.open_floating_preview({ label .. suffix }, ft, {
    border = "rounded", focusable = false, wrap = true,
    max_width = maxw, max_height = 3, anchor_bias = "above",
    close_events = { "InsertLeave", "BufHidden" },
  })
  win, last_key = w, key
  if s and e and e > s then
    pcall(vim.api.nvim_buf_set_extmark, buf, ns, 0, s, { end_col = e, hl_group = "LspSignatureActiveParameter" })
  end
end
M._handler = handler -- exposto para teste

-- manual=true ignora o toggle (usado por <C-k> e <leader>s)
function M.show(manual)
  if not manual then
    if not require("icaro.toggles").hints_on() then return end
    if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i" then return end
  end
  local has = false
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
    if c.server_capabilities and c.server_capabilities.signatureHelpProvider then has = true; break end
  end
  if not has then return end
  vim.lsp.buf_request(0, "textDocument/signatureHelp", function(client)
    return vim.lsp.util.make_position_params(0, client.offset_encoding)
  end, handler)
end

-- Debounce: pede de novo (com atraso curto) enquanto o popup estiver aberto.
local function later(ms)
  seq = seq + 1
  local mine = seq
  vim.defer_fn(function() if mine == seq then M.show(false) end end, ms)
end

function M.setup()
  local g = vim.api.nvim_create_augroup("icaro_signature", { clear = true })
  -- abre ao digitar ( ou ,
  vim.api.nvim_create_autocmd("InsertCharPre", { group = g, callback = function()
    local c = vim.v.char
    if c == "(" or c == "," then later(40) end
  end })
  -- enquanto está dentro de uma chamada, acompanha o cursor (troca o parâmetro destacado)
  vim.api.nvim_create_autocmd("CursorMovedI", { group = g, callback = function()
    if M.is_open() then later(120) end
  end })
  vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, { group = g, callback = M.close })
end

return M
