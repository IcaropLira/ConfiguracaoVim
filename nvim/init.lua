-- ============================================================
-- Neovim — Configuração Ícaro Lira
-- Versão Neovim da config do Vim: mesmos atalhos (F1–F12), mesmos
-- aliases (:Th :Pv :Nt ...), mesmos temas, mas com LSP nativo,
-- Treesitter, completion moderno e uma interface mais caprichada.
-- ============================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Abertura rápida: cache em disco dos módulos Lua compilados (Neovim 0.9+).
if vim.loader and vim.loader.enable then vim.loader.enable() end

-- Provedores externos (python/node/ruby/perl) que o Neovim procura na abertura
-- e que esta config não usa: desligar economiza dezenas de ms em PCs lentos.
for _, p in ipairs({ "python3", "node", "ruby", "perl" }) do vim.g["loaded_" .. p .. "_provider"] = 0 end

if vim.fn.has("nvim-0.10") == 0 then
  vim.api.nvim_echo({ { "Esta config precisa do Neovim 0.10 ou mais novo. Rode o install.sh da pasta nvim/.", "ErrorMsg" } }, true, {})
  return
end

require("icaro.paths")
require("icaro.options")
require("icaro.lazy")      -- instala/carrega os plugins
require("icaro.core").setup() -- temas, toggles, runner, atalhos, comandos
