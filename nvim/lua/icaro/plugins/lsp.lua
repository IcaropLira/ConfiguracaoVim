return {
  {
    "mason-org/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonLog" },
    opts = { ui = { border = "rounded" } },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "mason-org/mason.nvim", "saghen/blink.cmp" },
    config = function() require("icaro.lsp").setup() end,
  },
}
