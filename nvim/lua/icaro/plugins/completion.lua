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
        -- Janela de documentação ao lado das sugestões: só automática com as "dicas" ligadas
        -- (Shift+F3; começa desligada). Desligada, Ctrl+Space ainda abre sob demanda. Ligada, fica discreta:
        -- atraso maior e tamanho limitado pela largura da tela.
        documentation = {
          auto_show = require("icaro.state").get("hints", false), -- Shift+F3 muda em tempo real (toggles.lua)
          auto_show_delay_ms = 400,
          window = {
            border = "rounded",
            max_width = math.max(40, math.min(70, math.floor(vim.o.columns * 0.4))),
            max_height = 12,
          },
        },
        ghost_text = { enabled = false },
        accept = { auto_brackets = { enabled = true } },
      },
      signature = { enabled = false }, -- a assinatura é nossa (F10), veja icaro/toggles.lua
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust" },
    },
  },
}
