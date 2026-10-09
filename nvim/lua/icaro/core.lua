-- Liga tudo: temas, toggles, runner, cheatsheet, atalhos e comandos.
local M = {}

function M.setup()
  local themes = require("icaro.themes")
  local toggles = require("icaro.toggles")
  local runner = require("icaro.runner")
  local cheat = require("icaro.cheatsheet")

  -- ---------- temas ----------
  -- depois do lazy: o :colorscheme dos extras dispara o carregamento do plugin
  themes.setup()
  toggles.setup()
  runner.setup_templates()

  -- ---------- atalhos de função (n + i) ----------
  local function fk(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { silent = true, desc = desc })
    vim.keymap.set("i", lhs, function() vim.cmd.stopinsert(); vim.schedule(fn) end, { silent = true, desc = desc })
  end
  local function explorer() vim.cmd("Neotree toggle") end
  -- F1–F12 normais.
  fk("<F1>", themes.next, "Próximo tema")
  fk("<F2>", explorer, "Explorer")
  fk("<F3>", toggles.inlay, "Inlay hints")
  fk("<F4>", toggles.autocomplete, "Autocomplete")
  fk("<F5>", function() runner.dispatch("compile") end, "Compilar")
  fk("<F6>", function() runner.dispatch("run") end, "Executar")
  fk("<F7>", function() runner.dispatch("build_run") end, "Compilar + executar")
  fk("<F8>", function() runner.dispatch("test") end, "Testar com input.txt")
  fk("<F9>", runner.terminal, "Terminal")
  fk("<F10>", toggles.autopairs, "Fecha-pares")
  fk("<F12>", cheat.toggle, "Folha de atalhos")

  -- IMPORTANTE: muitos terminais não transmitem Shift+F1 diretamente.
  -- A convenção mais comum é converter Shift+F1..F12 em F13..F24.
  -- Mapeamos as duas formas para funcionar no kitty, GNOME Terminal,
  -- Konsole, terminal integrado etc., sem perder os <S-Fn> nativos.
  -- Shift+F3 e Shift+F4 deixaram de ser cópias de F3/F4: agora são as dicas de método
  -- e os avisos de código (F3/F4 normais continuam sendo inlay hints e autocomplete).
  local shifted = {
    { "<S-F1>", "<F13>", themes.prev, "Tema anterior" },
    { "<S-F2>", "<F14>", explorer, "Explorer (alternativo)" },
    { "<S-F3>", "<F15>", toggles.hints, "Dicas de método (assinatura + documentação)" },
    { "<S-F4>", "<F16>", toggles.diagnostics, "Avisos/erros do código" },
    { "<S-F5>", "<F17>", function() runner.dispatch("compile") end, "Compilar (alternativo)" },
    { "<S-F6>", "<F18>", function() runner.dispatch("run") end, "Executar (alternativo)" },
    { "<S-F7>", "<F19>", function() runner.dispatch("build_run") end, "Compilar + executar (alternativo)" },
    { "<S-F8>", "<F20>", function() runner.dispatch("test") end, "Testar com input.txt (alternativo)" },
    { "<S-F9>", "<F21>", runner.terminal, "Terminal (alternativo)" },
    { "<S-F10>", "<F22>", toggles.matchparen, "Matchparen" },
    { "<S-F11>", "<F23>", toggles.quiet, "Modo silencioso" },
    { "<S-F12>", "<F24>", toggles.header, "Header" },
  }

  for _, item in ipairs(shifted) do
    local native, terminal, fn, desc = item[1], item[2], item[3], item[4]
    fk(native, fn, desc)
    fk(terminal, fn, desc .. " — compatibilidade de terminal")
  end

  -- ---------- aliases curtos (:Th :Pv ...) ----------
  local cmds = {
    Th = themes.next, Pv = themes.prev, Nt = explorer, Ih = toggles.inlay, Ac = toggles.autocomplete,
    Cp = function() runner.dispatch("compile") end, Rn = function() runner.dispatch("run") end,
    Br = function() runner.dispatch("build_run") end, Ti = function() runner.dispatch("test") end,
    Te = runner.terminal, Pa = toggles.autopairs, Mh = toggles.matchparen, Of = toggles.quiet,
    Hd = toggles.header, Cs = cheat.toggle,
    Dc = toggles.hints, Dg = toggles.diagnostics, LspProgress = toggles.lsp_progress,
  }
  for name, fn in pairs(cmds) do vim.api.nvim_create_user_command(name, function() fn() end, {}) end
  vim.api.nvim_create_user_command("ThemeList", themes.pick, {})

  require("icaro.keymaps")
  require("icaro.autocmds")
  require("icaro.doctor")
end

return M
