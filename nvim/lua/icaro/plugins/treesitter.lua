-- Parsers que queremos. Só tentamos instalar o que FALTA, e só se houver compilador:
-- sem isso, em PC sem gcc/internet o Treesitter tentava baixar/compilar TODA vez que
-- um arquivo abria (e era uma das causas da abertura lenta).
local WANT = { "c", "cpp", "java", "python", "lua", "vim", "vimdoc", "bash", "json", "markdown", "markdown_inline", "query" }

local function missing_parsers()
  local has_cc = false
  for _, c in ipairs({ "gcc", "cc", "clang", "zig" }) do
    if vim.fn.executable(c) == 1 then has_cc = true; break end
  end
  if not has_cc then return {} end
  local list = {}
  for _, lang in ipairs(WANT) do
    if #vim.api.nvim_get_runtime_file("parser/" .. lang .. ".*", false) == 0 then list[#list + 1] = lang end
  end
  if #list == 0 then return {} end
  -- no máximo uma tentativa a cada 12h (se falhar por falta de internet, não insiste)
  local state = require("icaro.state")
  local last = state.get("ts_try", 0)
  if os.time() - last < 12 * 3600 then return {} end
  state.set("ts_try", os.time())
  return list
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall" },
    main = "nvim-treesitter.configs",
    opts = function()
      return {
        ensure_installed = missing_parsers(),
        highlight = { enable = true },
        -- C/C++/Java usam o `cindent` nativo e Python o indent do runtime (ver autocmds.lua):
        -- funcionam mesmo sem parser instalado.
        indent = { enable = true, disable = { "c", "cpp", "java", "python" } },
        auto_install = false,
      }
    end,
  },
}
