return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = { "c", "cpp", "java", "python", "lua", "vim", "vimdoc", "bash", "json", "markdown", "markdown_inline", "query" },
      highlight = { enable = true },
      indent = { enable = true },
      auto_install = false,
    },
  },
}
