-- Usado pelo install.sh (modo headless): instala parsers do Treesitter e os
-- servidores LSP do Mason ANTES do primeiro uso, mostrando o progresso.
-- Nunca falha o instalador: sem internet ou com limite da API do GitHub, só avisa.
local M = {}

local function say(msg) io.stdout:write(msg .. "\n"); io.stdout:flush() end

function M.run()
  local ok_lazy, lazy = pcall(require, "lazy")
  if not ok_lazy then say("lazy.nvim indisponível — pulei o bootstrap."); return end

  -- 1) parsers do Treesitter
  pcall(lazy.load, { plugins = { "nvim-treesitter" } })
  say("• Treesitter: compilando parsers (c, cpp, java, python, lua, vim, bash, json, markdown)…")
  pcall(vim.cmd, "TSInstallSync! c cpp java python lua vim vimdoc bash json markdown markdown_inline query")

  -- 2) servidores LSP (Mason)
  pcall(lazy.load, { plugins = { "mason.nvim" } })
  local ok, reg = pcall(require, "mason-registry")
  if not ok then say("Mason indisponível — os servidores LSP serão instalados no primeiro uso."); return end

  local refreshed = nil
  reg.refresh(function(success) refreshed = success end)
  vim.wait(60000, function() return refreshed ~= nil end, 100)
  if not refreshed then
    say("! Não consegui baixar o registro do Mason (sem internet ou limite da API do GitHub).")
    say("  Os servidores LSP serão tentados de novo quando você abrir o nvim.")
    return
  end

  local lsp = require("icaro.lsp")
  local pending = lsp.missing(reg)
  if #pending == 0 then say("• LSP: nada a instalar (já existe no sistema ou no Mason).") end
  for _, pkg in ipairs(pending) do
    say("• LSP: instalando " .. pkg.name .. "…")
    local done = false
    pkg:install():once("closed", function() done = true end)
    vim.wait(600000, function() return done end, 200)
    say(pkg:is_installed() and ("  ✓ " .. pkg.name) or ("  ! " .. pkg.name .. " falhou (veja :Mason)"))
  end
end

return M
