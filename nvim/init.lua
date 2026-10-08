-- ============================================================
-- Neovim — Configuração Ícaro Lira
-- Versão Neovim da config do Vim: mesmos atalhos (F1–F12), mesmos
-- aliases (:Th :Pv :Nt ...), mesmos temas, mas com LSP nativo,
-- Treesitter, completion moderno e uma interface mais caprichada.
-- ============================================================
vim.g.mapleader = " "
vim.g.maplocalleader = " "

if vim.fn.has("nvim-0.10") == 0 then
  vim.api.nvim_echo({ { "Esta config precisa do Neovim 0.10 ou mais novo. Rode o install.sh da pasta nvim/.", "ErrorMsg" } }, true, {})
  return
end

require("icaro.paths")
require("icaro.options")
require("icaro.lazy")      -- instala/carrega os plugins
require("icaro.core").setup() -- temas, toggles, runner, atalhos, comandos
