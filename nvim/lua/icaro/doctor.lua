-- :IcaroDoctor — confere o que a config precisa pra funcionar 100%.
vim.api.nvim_create_user_command("IcaroDoctor", function()
  local paths = require("icaro.paths")
  local out = {}
  local function row(ok, what, hint)
    out[#out + 1] = (ok and "  ✓ " or "  ✗ ") .. what .. ((not ok and hint) and ("  →  " .. hint) or "")
  end
  row(vim.fn.has("nvim-0.11") == 1, "Neovim " .. tostring(vim.version()), "0.11+ recomendado")
  row(vim.fn.executable("git") == 1, "git", "necessário para os plugins")
  row(vim.fn.executable("gcc") == 1 or vim.fn.executable("cc") == 1, "compilador C (Treesitter)", "instale gcc")
  row(vim.fn.executable("g++") == 1, "g++ (F5–F8 em C++)")
  row(vim.fn.executable("javac") == 1, "javac (F5–F8 em Java)")
  row(vim.fn.executable("python3") == 1, "python3 (F7 em Python)")
  row(vim.fn.executable("rg") == 1, "ripgrep (busca <leader>fg)", "instale ripgrep")
  row(vim.fn.executable("npm") == 1, "npm (pyright via Mason)", "opcional")
  row(paths.theme_dir ~= nil, "temas do Vim: " .. tostring(paths.theme_dir))
  row(paths.template_dir ~= nil, "templates: " .. tostring(paths.template_dir))
  local m = vim.fn.stdpath("data") .. "/mason/bin/"
  for _, s in ipairs({ "clangd", "pyright-langserver", "jdtls" }) do
    row(vim.fn.executable(m .. s) == 1 or vim.fn.executable(s) == 1, "servidor LSP: " .. s, ":Mason")
  end
  vim.api.nvim_echo({ { "Ícaro Lira — diagnóstico\n" .. table.concat(out, "\n"), "Normal" } }, true, {})
end, {})
