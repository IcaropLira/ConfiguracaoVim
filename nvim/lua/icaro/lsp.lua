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

-- executável que cada servidor precisa
local exe = { clangd = "clangd", pyright = "pyright-langserver", jdtls = "jdtls" }

-- Os binários instalados pelo Mason ficam aqui. Colocamos no PATH já na abertura, SEM
-- carregar o Mason (que é pesado e baixava o registro do GitHub a cada abertura).
local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
if vim.fn.isdirectory(mason_bin) == 1 and not vim.env.PATH:find(mason_bin, 1, true) then
  vim.env.PATH = mason_bin .. (vim.fn.has("win32") == 1 and ";" or ":") .. vim.env.PATH
end
local function have(server) return vim.fn.executable(exe[server]) == 1 end

-- Devolve a lista de pacotes do Mason que ainda valem a pena instalar.
function M.missing(reg)
  local list = {}
  for server, info in pairs(packages) do
    -- se já existe no sistema (apt etc.) ou no Mason, não baixa de novo
    if not have(server) and info.ok() then
      local gok, pkg = pcall(reg.get_package, info.pkg)
      if gok and not pkg:is_installed() then list[#list + 1] = pkg end
    end
  end
  return list
end

-- Só mexe no Mason se REALMENTE faltar algum servidor instalável, e no máximo 1x a cada
-- 12h (sem internet/lab bloqueado: não fica tentando a cada abertura).
function M.ensure_installed(on_installed)
  local need = false
  for server, info in pairs(packages) do
    if not have(server) and info.ok() then need = true end
  end
  if not need then return end
  local state = require("icaro.state")
  if os.time() - state.get("mason_try", 0) < 12 * 3600 then return end
  state.set("mason_try", os.time())

  local ok, reg = pcall(require, "mason-registry")
  if not ok then return end
  reg.refresh(function(success)
    if not success then return end -- sem internet / limite da API do GitHub: tenta de novo mais tarde
    for _, pkg in ipairs(M.missing(reg)) do
      vim.schedule(function() vim.notify("Mason: instalando " .. pkg.name .. "…", vim.log.levels.INFO) end)
      pkg:install():once("closed", function()
        if on_installed then vim.schedule(function() on_installed(pkg.name) end) end
      end)
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
  -- vim.diagnostic.jump só existe no Neovim 0.11+; na 0.10 usa goto_prev/goto_next
  local function jump(n)
    if vim.diagnostic.jump then vim.diagnostic.jump({ count = n, float = true })
    else (n < 0 and vim.diagnostic.goto_prev or vim.diagnostic.goto_next)({ float = true }) end
  end
  m("n", "[d", function() jump(-1) end, "Diagnóstico anterior")
  m("n", "]d", function() jump(1) end, "Próximo diagnóstico")
  m("i", "<C-k>", function() require("icaro.signature").show(true) end, "Assinatura (compacta)")
  m("n", "<leader>s", function() require("icaro.signature").show(true) end, "Assinatura do método")
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
      -- só liga se o servidor existe (senão aparecia erro "failed to spawn" a cada arquivo)
      if have(name) then vim.lsp.enable(name) end
    end
  else -- Neovim 0.10
    local lspconfig = require("lspconfig")
    for name, cfg in pairs(servers) do
      if not have(name) then goto continue end
      cfg = vim.deepcopy(cfg)
      cfg.capabilities = caps
      if name == "jdtls" then
        local util = require("lspconfig.util")
        cfg.root_dir = function(fname)
          return util.root_pattern(".git", "mvnw", "gradlew", "pom.xml", "build.gradle")(fname) or vim.fs.dirname(fname)
        end
      end
      lspconfig[name].setup(cfg)
      ::continue::
    end
  end

  -- depois que o Mason instalar um servidor, liga ele na hora (sem reabrir o nvim)
  M.ensure_installed(function(pkg_name)
    for name, info in pairs(packages) do
      if info.pkg == pkg_name and have(name) then
        if vim.lsp.enable and vim.lsp.config then vim.lsp.enable(name)
        else pcall(function() require("lspconfig")[name].setup({ capabilities = caps }) end) end
        vim.cmd("silent! doautoall FileType")
      end
    end
  end)
end

return M
