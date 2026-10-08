-- Descobre onde estão os temas e templates, tanto no modo symlink (a config
-- aponta pro repositório) quanto no modo cópia ou com o Vim já instalado.
local M = {}

local cfg = vim.fn.resolve(vim.fn.stdpath("config"))
M.config = cfg
M.root = vim.fn.fnamemodify(cfg, ":h") -- raiz do repositório (se for symlink)

local function first_dir(list)
  for _, p in ipairs(list) do
    if p and vim.fn.isdirectory(p) == 1 then return p end
  end
end

M.theme_dir = first_dir({
  cfg .. "/theme/icaro-theme",
  M.root .. "/vim/theme/icaro-theme",
  vim.fn.expand("~/.vim/pack/plugins/opt/icaro-theme"),
})
M.template_dir = first_dir({
  cfg .. "/templates",
  M.root .. "/vim/templates",
  vim.fn.expand("~/.vim/templates"),
})

-- Os 45+ temas do Vim são colorschemes .vim comuns; o Neovim os carrega igual.
if M.theme_dir then vim.opt.runtimepath:prepend(M.theme_dir) end

return M
