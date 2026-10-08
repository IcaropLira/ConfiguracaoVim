return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      -- F4 (por linguagem) e o modo silencioso (Shift+F11) desligam aqui.
      enabled = function() return require("icaro.toggles").completion_enabled() end,
      keymap = {
        preset = "none",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
        ["<C-j>"] = { "snippet_forward", "fallback" },
        ["<C-k>"] = { "snippet_backward", "fallback" },
      },
      appearance = { nerd_font_variant = "mono" },
      completion = {
        -- não pré-seleciona: Enter só confirma se você escolheu algo (Tab navega)
        list = { selection = { preselect = false, auto_insert = false } },
        menu = { border = "rounded", draw = { treesitter = { "lsp" } } },
        documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
        ghost_text = { enabled = false },
        accept = { auto_brackets = { enabled = true } },
      },
      signature = { enabled = false }, -- a assinatura é nossa (F10), veja icaro/toggles.lua
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust" },
    },
  },
}
