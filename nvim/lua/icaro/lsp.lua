-- LSP nativo do Neovim: clangd (C++), pyright (Python) e jdtls (Java),
-- instalados pelo Mason só se faltarem e se o ambiente aguentar (npm / java).
local M = {}
local nf = vim.g.icaro_nerd_font

local function root_fallback(markers)
  -- 0.11+: root_dir(bufnr, on_dir). Sem marcador de projeto, usa a pasta do arquivo
  -- (essencial pra programação competitiva: um .cpp solto também ganha LSP).
  return function(bufnr, on_dir)
    local name = vim.api.nvim_buf_get_name(bufnr)
    on_dir(vim.fs.root(bufnr, markers) or vim.fs.dirname(name))
  end
end

local servers = {
  clangd = {
    cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=iwyu",
      "--completion-style=detailed", "--function-arg-placeholders", "--fallback-style=llvm" },
    init_options = { fallbackFlags = { "-std=c++17", "-Wall", "-Wextra" } },
  },
  pyright = {
    settings = { python = { analysis = { typeCheckingMode = "basic", autoSearchPaths = true, useLibraryCodeForTypeInfo = true } } },
  },
  jdtls = {
    root_dir = root_fallback({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "build.gradle.kts", "settings.gradle" }),
  },
}

-- pacote do Mason + pré-condição para tentar instalar
local packages = {
  clangd = { pkg = "clangd", ok = function() return true end },
  pyright = { pkg = "pyright", ok = function() return vim.fn.executable("npm") == 1 end },
  jdtls = { pkg = "jdtls", ok = function() return vim.fn.executable("java") == 1 end },
}

M.packages = packages

-- Devolve a lista de pacotes do Mason que ainda valem a pena instalar.
function M.missing(reg)
  local list = {}
  for server, info in pairs(packages) do
    -- se já existe no sistema (apt etc.) ou no Mason, não baixa de novo
    local has = vim.fn.executable(server == "pyright" and "pyright-langserver" or server) == 1
    if not has and info.ok() then
      local gok, pkg = pcall(reg.get_package, info.pkg)
      if gok and not pkg:is_installed() then list[#list + 1] = pkg end
    end
  end
  return list
end

function M.ensure_installed()
  local ok, reg = pcall(require, "mason-registry")
  if not ok then return end
  reg.refresh(function(success)
    if not success then return end -- sem internet / limite da API do GitHub: tenta de novo na próxima vez
    for _, pkg in ipairs(M.missing(reg)) do
      vim.schedule(function() vim.notify("Mason: instalando " .. pkg.name .. "…", vim.log.levels.INFO) end)
      pkg:install()
    end
  end)
end

local function on_attach(client, bufnr)
  local m = function(mode, l, r, d) vim.keymap.set(mode, l, r, { buffer = bufnr, silent = true, desc = d }) end
  m("n", "gd", vim.lsp.buf.definition, "Definição")
  m("n", "gD", vim.lsp.buf.declaration, "Declaração")
  m("n", "gr", vim.lsp.buf.references, "Referências")
  m("n", "gi", vim.lsp.buf.implementation, "Implementação")
  m("n", "gy", vim.lsp.buf.type_definition, "Definição do tipo")
  m("n", "K", function() vim.lsp.buf.hover({ border = "rounded" }) end, "Documentação")
  m("n", "<leader>rn", vim.lsp.buf.rename, "Renomear")
  m({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Ações de código")
  m("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, "Formatar")
  m("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Diagnóstico anterior")
  m("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Próximo diagnóstico")
  m("i", "<C-k>", vim.lsp.buf.signature_help, "Assinatura")
  m("n", "<leader>s", vim.lsp.buf.signature_help, "Assinatura do método")
  m("n", "<leader>oi", function()
    vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" }, diagnostics = {} }, apply = true })
  end, "Organizar imports")

  -- destaca as outras ocorrências do símbolo sob o cursor (some no modo silencioso)
  if client.server_capabilities.documentHighlightProvider then
    local g = vim.api.nvim_create_augroup("icaro_lsp_hl_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", { group = g, buffer = bufnr, callback = function()
      if not vim.g.icaro_quiet then vim.lsp.buf.document_highlight() end
    end })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter" }, { group = g, buffer = bufnr, callback = vim.lsp.buf.clear_references })
  end
end

function M.setup()
  vim.diagnostic.config({
    virtual_text = { spacing = 2, prefix = "●", source = "if_many" },
    signs = nf and { text = { [vim.diagnostic.severity.ERROR] = "", [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "", [vim.diagnostic.severity.HINT] = "󰌵" } } or true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = { border = "rounded", source = true },
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("icaro_lsp_attach", { clear = true }),
    callback = function(ev)
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client then on_attach(client, ev.buf) end
    end,
  })

  local caps = vim.lsp.protocol.make_client_capabilities()
  local okb, blink = pcall(require, "blink.cmp")
  if okb then caps = blink.get_lsp_capabilities(caps) end

  if vim.lsp.config and vim.lsp.enable then -- Neovim 0.11+
    for name, cfg in pairs(servers) do
      cfg.capabilities = caps
      vim.lsp.config(name, cfg)
      vim.lsp.enable(name)
    end
  else -- Neovim 0.10
    local lspconfig = require("lspconfig")
    for name, cfg in pairs(servers) do
      cfg = vim.deepcopy(cfg)
      cfg.capabilities = caps
      if name == "jdtls" then
        local util = require("lspconfig.util")
        cfg.root_dir = function(fname)
          return util.root_pattern(".git", "mvnw", "gradlew", "pom.xml", "build.gradle")(fname) or vim.fs.dirname(fname)
        end
      end
      lspconfig[name].setup(cfg)
    end
  end

  M.ensure_installed()
end

return M
