-- Extras opcionais para tornar a configuração mais explorável e produtiva.
return {
  {
    "folke/which-key.nvim",
    enabled = function() return require("icaro.state").get("plugin_which_key", true) end,
    event = "VeryLazy",
    opts = {
      delay = 450,
      preset = "modern",
      spec = {
        { "<leader>f", group = "Arquivos e busca" },
        { "<leader>h", group = "Git / hunks" },
        { "<leader>x", group = "Diagnósticos" },
        { "<leader>u", group = "Interface e configurações" },
      },
      win = { border = "rounded", padding = { 1, 2 } },
    },
  },
  {
    "folke/todo-comments.nvim",
    enabled = function() return require("icaro.state").get("plugin_todo_comments", true) end,
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = true, sign_priority = 8, highlight = { keyword = "wide", after = "fg" }, search = { command = "rg" } },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Próximo TODO" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "TODO anterior" },
      { "<leader>ft", "<Cmd>TodoTelescope<CR>", desc = "Buscar TODO/FIXME" },
    },
  },
  {
    "echasnovski/mini.indentscope",
    enabled = function() return require("icaro.state").get("plugin_indent_scope", true) end,
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      draw = { delay = 80 },
      symbol = "│",
      options = { try_as_border = true, border = "both" },
    },
  },
}
