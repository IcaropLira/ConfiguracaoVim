-- Bootstrap do lazy.nvim (gerenciador de plugins).
local path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(path) then
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", path })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Falha ao baixar o lazy.nvim (git/internet?):\n" .. out, "ErrorMsg" } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(path)

require("lazy").setup({
  spec = { { import = "icaro.plugins" } },
  defaults = { lazy = true },
  install = { colorscheme = { "habamax" } },
  checker = { enabled = false },
  change_detection = { notify = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      -- o lazy.nvim reseta o runtimepath; sem isso os temas do Vim somem
      paths = { require("icaro.paths").theme_dir or nil },
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin", "netrwPlugin" } },
  },
})
