-- F12 / :Cs — folha de atalhos flutuante (toggle).
local M = {}

local sections = {
  { "TECLAS DE FUNÇÃO", {
    { "F1",        "próximo tema            (:Th)" },
    { "S-F1",      "tema anterior           (:Pv)" },
    { "F2",        "explorer (neo-tree)     (:Nt)" },
    { "F3",        "inlay hints             (:Ih)" },
    { "F4",        "autocomplete (por linguagem) (:Ac)" },
    { "F5",        "compilar                (:Cp)" },
    { "F6",        "executar                (:Rn)" },
    { "F7",        "compilar + executar     (:Br)" },
    { "F8",        "testar com input.txt    (:Ti)" },
    { "F9",        "terminal                (:Te)" },
    { "F10",       "fecha-pares + assinatura (:Pa)" },
    { "S-F10",     "destaque de parênteses  (:Mh)" },
    { "S-F11",     "modo silencioso         (:Of)" },
    { "S-F12/F24", "mostra/esconde o header (:Hd)" },
    { "F12",       "esta folha              (:Cs)" },
  } },
  { "GERAL", {
    { "Ctrl+S",        "salvar" },
    { "Ctrl+H/J/K/L",  "navegar entre janelas" },
    { "Tab / S-Tab",   "próximo / anterior buffer" },
    { "Esc",           "limpar destaque da busca" },
    { "Alt+j / Alt+k", "mover linha(s) pra baixo / cima" },
    { "gc / gcc",      "comentar (nativo do Neovim)" },
    { "<leader>w/q",   "salvar / sair" },
  } },
  { "BUSCA (Telescope)", {
    { "<leader>ff", "arquivos" },
    { "<leader>fg", "texto no projeto (ripgrep)" },
    { "<leader>fb", "buffers" },
    { "<leader>fr", "arquivos recentes" },
    { "<leader>fh", "ajuda" },
    { "<leader>ft", "escolher tema (com preview)" },
    { "<leader>/",  "buscar no arquivo" },
  } },
  { "LSP", {
    { "gd / gD",     "definição / declaração" },
    { "gr / gi / gy", "referências / implementação / tipo" },
    { "K",           "documentação" },
    { "<leader>rn",  "renomear símbolo" },
    { "<leader>ca",  "ações de código" },
    { "<leader>f",   "formatar" },
    { "[d / ]d",     "diagnóstico anterior / próximo" },
    { "<leader>xx",  "lista de diagnósticos (Trouble)" },
    { "Tab / S-Tab", "navegar nas sugestões" },
    { "Enter",       "confirmar sugestão" },
    { "Ctrl+Space",  "abrir sugestões" },
  } },
  { "GIT", {
    { "]h / [h",       "próximo / anterior hunk" },
    { "<leader>hp",    "ver hunk" },
    { "<leader>hb",    "git blame da linha" },
  } },
  { "TEMAS / EXTRAS", {
    { ":ThemeList",   "listar e escolher tema" },
    { ":Lazy",        "gerenciar plugins" },
    { ":Mason",       "gerenciar servidores LSP" },
    { ":IcaroDoctor", "diagnóstico da instalação" },
  } },
}

local win, buf

function M.close()
  if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  win, buf = nil, nil
end

function M.toggle()
  if win and vim.api.nvim_win_is_valid(win) then return M.close() end
  local lines, marks = {}, {}
  local keyw = 0
  for _, s in ipairs(sections) do for _, kv in ipairs(s[2]) do keyw = math.max(keyw, vim.fn.strdisplaywidth(kv[1])) end end
  for _, s in ipairs(sections) do
    lines[#lines + 1] = ""
    lines[#lines + 1] = "  " .. s[1]
    marks[#marks + 1] = { #lines - 1, "Title" }
    for _, kv in ipairs(s[2]) do
      local pad = string.rep(" ", keyw - vim.fn.strdisplaywidth(kv[1]))
      lines[#lines + 1] = "   " .. kv[1] .. pad .. "  " .. kv[2]
      marks[#marks + 1] = { #lines - 1, "Special", 3, 3 + #kv[1] }
    end
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "  q / Esc / F12 fecha"
  marks[#marks + 1] = { #lines - 1, "Comment" }

  local width = 0
  for _, l in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(l)) end
  width = math.min(width + 4, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  local ns = vim.api.nvim_create_namespace("icaro_cheatsheet")
  for _, m in ipairs(marks) do
    if m[3] then
      vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[3], { end_col = m[4], hl_group = m[2] })
    else
      vim.api.nvim_buf_set_extmark(buf, ns, m[1], 0, { end_row = m[1] + 1, hl_group = m[2], hl_eol = true })
    end
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "icaro-cheatsheet"

  win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    width = width, height = height,
    row = math.floor((vim.o.lines - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
    title = " Atalhos — Config: Ícaro Lira ", title_pos = "center",
  })
  vim.wo[win].cursorline = true
  vim.wo[win].wrap = false
  for _, k in ipairs({ "q", "<Esc>", "<F12>" }) do
    vim.keymap.set("n", k, M.close, { buffer = buf, nowait = true, silent = true })
  end
  vim.api.nvim_create_autocmd("BufLeave", { buffer = buf, once = true, callback = M.close })
end

return M
