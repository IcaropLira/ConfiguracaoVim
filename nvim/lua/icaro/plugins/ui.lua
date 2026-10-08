require("icaro.ui")
local nf = vim.g.icaro_nerd_font

return {
  { "nvim-lua/plenary.nvim", lazy = true },
  { "MunifTanjim/nui.nvim", lazy = true },
  { "nvim-tree/nvim-web-devicons", lazy = true, enabled = nf },

  -- Statusline + header (winbar). O header some/volta com Shift+F12.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local themes = require("icaro.themes")
      local toggles = require("icaro.toggles")
      -- Powerline: com Nerd Font usamos os separadores clássicos; sem ela,
      -- caímos para caracteres ASCII seguros.
      local sep = nf and { left = "", right = "" } or { left = "|", right = "|" }
      local sec = nf and { left = "", right = "" } or { left = ">", right = "<" }
      local function lsp_names()
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do names[#names + 1] = c.name end
        return #names > 0 and ((nf and " " or "LSP ") .. table.concat(names, ",")) or ""
      end
      local no_quiet = function() return not vim.g.icaro_quiet end
      local winbar_off = { "neo-tree", "dashboard", "icaro-runner", "icaro-cheatsheet", "lazy", "mason",
        "TelescopePrompt", "trouble", "qf", "help", "snacks_dashboard" }
      local file_cond = function() return vim.bo.buftype == "" end
      return {
        options = {
          theme = "auto",
          globalstatus = true,
          component_separators = sep,
          section_separators = sec,
          disabled_filetypes = { statusline = { "dashboard" }, winbar = winbar_off },
        },
        sections = {
          lualine_a = {
            { "mode", fmt = function(s) return s:sub(1, 1) .. s:sub(2):lower() end },
          },
          lualine_b = {
            { "branch", icon = nf and " " or "git:" },
            { "diff", symbols = nf and { added = " ", modified = " ", removed = " " } or { added = "+", modified = "~", removed = "-" } } },
          lualine_c = { { "diagnostics", cond = no_quiet,
            symbols = nf and { error = " ", warn = " ", info = " ", hint = "󰌵 " } or { error = "E:", warn = "W:", info = "I:", hint = "H:" } } },
          lualine_x = { { toggles.ac_label, color = function()
            return { fg = (not vim.g.icaro_quiet and toggles.completion_enabled()) and "#7ec16e" or "#d0707a" }
          end }, lsp_names, "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location", { function() return os.date("%H:%M") end } },
        },
        winbar = {
          lualine_a = { { function() return themes.badge() end, cond = file_cond } },
          lualine_b = { { "filename", path = 1, cond = file_cond, symbols = { modified = " ●", readonly = " ", unnamed = "[sem nome]" } } },
          lualine_c = { { function() return (themes.current().subtitle or "") end, cond = file_cond } },
          lualine_y = { { "branch", icon = nf and "" or "git:", cond = file_cond } },
          lualine_z = { { function() return "Config: Ícaro Lira" end, cond = file_cond } },
        },
        inactive_winbar = {
          lualine_b = { { "filename", path = 1, cond = file_cond } },
          lualine_z = { { function() return "Config: Ícaro Lira" end, cond = file_cond } },
        },
        extensions = { "neo-tree", "lazy", "mason", "quickfix", "trouble" },
      }
    end,
  },

  -- Notificações modernas + command line flutuante.
  -- Isso substitui mensagens que costumavam poluir o rodapé por uma UI
  -- muito mais limpa, especialmente em compilação/LSP.
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      timeout = 2500,
      stages = "fade_in_slide_out",
      render = "compact",
      max_width = 70,
      max_height = 12,
      top_down = false,
      background_colour = "#09090b",
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = {
      lsp = {
        progress = { enabled = true },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = true,
      },
      views = {
        cmdline_popup = {
          position = { row = "30%", col = "50%" },
          size = { width = 70, height = "auto" },
          border = { style = "rounded" },
        },
      },
    },
  },

  -- Indentação com uma linha de escopo animada ao redor do bloco atual.
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      symbol = "│",
      draw = { delay = 60, animation = function() return 1 end },
      options = { try_as_border = true },
    },
  },

  -- Barra de scrollbar lateral com diagnóstico e posição no arquivo.
  {
    "petertriho/nvim-scrollbar",
    event = "VeryLazy",
    opts = {
      handlers = { cursor = true, diagnostic = true, gitsigns = true, search = true },
      marks = {
        Cursor = { text = "▎", priority = 0 },
        Search = { text = { "▎", "▎" }, priority = 10 },
        Error = { text = { "▎", "▎" }, priority = 11 },
        Warn = { text = { "▎", "▎" }, priority = 12 },
        Info = { text = { "▎", "▎" }, priority = 13 },
        Hint = { text = { "▎", "▎" }, priority = 14 },
        Misc = { text = { "▎", "▎" }, priority = 15 },
      },
      excluded_filetypes = { "prompt", "TelescopePrompt", "neo-tree", "dashboard" },
    },
  },

  -- Destaca referências do símbolo sob o cursor.
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      delay = 100,
      large_file_cutoff = 2000,
      min_count_to_highlight = 2,
      filetypes_denylist = { "neo-tree", "dashboard", "TelescopePrompt", "lazy", "mason", "help", "qf" },
    },
    -- vim-illuminate NÃO usa setup(); a API correta é configure().
    -- Sem isso, o lazy.nvim tenta require("illuminate").setup() e gera:
    -- "loader.lua:... attempt to call field 'setup' (a nil value)".
    config = function(_, opts)
      require("illuminate").configure(opts)
    end,
  },

  -- TODO/FIXME/NOTE ficam visíveis e pesquisáveis.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- Abas de buffers
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    version = "*",
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim",
        always_show_bufferline = true,
        separator_style = nf and "slant" or "thin",
        show_buffer_close_icons = false,
        show_close_icon = false,
        offsets = { { filetype = "neo-tree", text = "Explorer", highlight = "Directory", text_align = "left", separator = true } },
      },
    },
  },

  -- Explorer (F2 / :Nt)
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", nf and "nvim-tree/nvim-web-devicons" or nil },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = { with_expanders = true },
        git_status = { symbols = nf and nil or { added = "+", modified = "~", deleted = "x", renamed = "r", untracked = "?", ignored = "i", unstaged = "u", staged = "s", conflict = "!" } },
      },
      window = { width = 32, mappings = { ["<space>"] = "none", ["l"] = "open", ["h"] = "close_node" } },
      filesystem = {
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = "open_default",
        filtered_items = { visible = false, hide_dotfiles = false, hide_gitignored = true },
      },
    },
    init = function()
      -- `nvim .` ou `nvim pasta/` abre o explorer
      vim.api.nvim_create_autocmd("BufEnter", {
        once = true,
        callback = function()
          local a = vim.fn.argv(0)
          if a ~= "" and vim.fn.isdirectory(a) == 1 then require("neo-tree") end
        end,
      })
    end,
  },

  -- Guias de indentação
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│", tab_char = "│" }, scope = { show_start = false, show_end = false } },
  },

  -- Cursor e seleção com pequenos detalhes visuais, sem animações pesadas.
  {
    "echasnovski/mini.cursorword",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    opts = { delay = 150 },
  },

  -- Dica de atalhos ao apertar <leader>
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
      spec = {
        { "<leader>f", group = "buscar" }, { "<leader>h", group = "git" }, { "<leader>x", group = "diagnósticos" },
        { "<leader>b", group = "buffers" }, { "<leader>c", group = "código" },
      },
    },
  },

  -- Tela inicial
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function()
      local header = {
        "",
        "  ██╗ ██████╗ █████╗ ██████╗  ██████╗     ██╗     ██╗██████╗  █████╗  ",
        "  ██║██╔════╝██╔══██╗██╔══██╗██╔═══██╗    ██║     ██║██╔══██╗██╔══██╗ ",
        "  ██║██║     ███████║██████╔╝██║   ██║    ██║     ██║██████╔╝███████║ ",
        "  ██║██║     ██╔══██║██╔══██╗██║   ██║    ██║     ██║██╔══██╗██╔══██║ ",
        "  ██║╚██████╗██║  ██║██║  ██║╚██████╔╝    ███████╗██║██║  ██║██║  ██║ ",
        "  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝     ╚══════╝╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ",
        "",
      }
      local function item(icon, desc, key, action)
        return { icon = (nf and icon or "") .. " ", desc = desc .. string.rep(" ", 24 - #desc), key = key, key_format = " %s", action = action, group = "Identifier" }
      end
      return {
        theme = "doom",
        hide = { statusline = false, tabline = false, winbar = false },
        config = {
          header = header,
          center = {
            item("", "Novo arquivo", "n", "enew"),
            item("", "Buscar arquivo", "f", "Telescope find_files"),
            item("", "Arquivos recentes", "r", "Telescope oldfiles"),
            item("", "Buscar texto", "g", "Telescope live_grep"),
            item("", "Escolher tema", "t", "ThemeList"),
            item("", "Atalhos (F12)", "k", "Cs"),
            item("󰒲", "Plugins (Lazy)", "l", "Lazy"),
            item("", "Sair", "q", "qa"),
          },
          footer = function() return { "", "Config: Ícaro Lira  •  F1 troca o tema  •  F12 mostra os atalhos" } end,
        },
      }
    end,
  },
}
