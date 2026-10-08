local nf = vim.g.icaro_nerd_font
return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make", cond = function() return vim.fn.executable("make") == 1 end },
    },
    keys = {
      { "<leader>ff", "<Cmd>Telescope find_files<CR>", desc = "Arquivos" },
      { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Texto no projeto" },
      { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Recentes" },
      { "<leader>fh", "<Cmd>Telescope help_tags<CR>", desc = "Ajuda" },
      { "<leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "Diagnósticos" },
      { "<leader>ft", "<Cmd>Telescope colorscheme enable_preview=true<CR>", desc = "Temas (com preview)" },
      { "<leader>/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Buscar no arquivo" },
    },
    opts = {
      defaults = {
        prompt_prefix = nf and "  " or "> ",
        selection_caret = nf and " " or "> ",
        sorting_strategy = "ascending",
        layout_config = { prompt_position = "top", width = 0.9, height = 0.85 },
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      },
    },
    config = function(_, opts)
      local t = require("telescope")
      t.setup(opts)
      pcall(t.load_extension, "fzf")
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" }, topdelete = { text = "" }, changedelete = { text = "▎" }, untracked = { text = "▎" } },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local m = function(l, r, d) vim.keymap.set("n", l, r, { buffer = buf, desc = d }) end
        m("]h", function() gs.nav_hunk("next") end, "Próximo hunk")
        m("[h", function() gs.nav_hunk("prev") end, "Hunk anterior")
        m("<leader>hp", gs.preview_hunk, "Ver hunk")
        m("<leader>hb", function() gs.blame_line({ full = true }) end, "Blame da linha")
        m("<leader>hr", gs.reset_hunk, "Desfazer hunk")
      end,
    },
  },

  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<Cmd>Trouble diagnostics toggle<CR>", desc = "Diagnósticos (projeto)" },
      { "<leader>xb", "<Cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnósticos (buffer)" },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = { check_ts = true, fast_wrap = {} },
  },
}
