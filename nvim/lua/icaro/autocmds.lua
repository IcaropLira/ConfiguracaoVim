local aug = vim.api.nvim_create_augroup("icaro_autocmds", { clear = true })
local au = function(ev, opts) opts.group = aug; vim.api.nvim_create_autocmd(ev, opts) end

-- Neovim 0.10 chama de vim.highlight; a partir da 0.11 é vim.hl.
vim.hl = vim.hl or vim.highlight
au("TextYankPost", { callback = function() pcall(vim.hl.on_yank, { timeout = 150 }) end })

au("BufReadPost", { callback = function(ev)
  local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
  local lines = vim.api.nvim_buf_line_count(ev.buf)
  if mark[1] > 0 and mark[1] <= lines then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
end })

au("VimResized", { callback = function() vim.cmd("tabdo wincmd =") end })
au({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })

au("FileType", { pattern = { "help", "qf", "man", "lspinfo", "checkhealth" }, callback = function(ev)
  vim.keymap.set("n", "q", "<Cmd>close<CR>", { buffer = ev.buf, silent = true })
end })

-- Competitiva: tamanho de indentação por linguagem
au("FileType", { pattern = { "cpp", "c", "java", "python" }, callback = function()
  vim.bo.shiftwidth = 4; vim.bo.tabstop = 4; vim.bo.softtabstop = 4; vim.bo.expandtab = true
end })

-- Auto-indentação confiável em C/C++/Java: o `cindent` é nativo do Vim, não depende de
-- parser do Treesitter, de compilador nem de internet. (Era isso que falhava nos PCs do
-- lab: sem o parser, o indent do Treesitter não faz nada e o `{` não indenta a linha.)
-- Assim `if (x) {` + Enter indenta sozinho, e digitar `}` realinha a linha.
au("FileType", { pattern = { "c", "cpp", "java" }, callback = function()
  vim.bo.indentexpr = ""
  vim.bo.cindent = true
  vim.bo.cinoptions = ":0,l1,g0,j1,(s,m1"
end })

-- números relativos só no modo normal
au("InsertEnter", { callback = function() if vim.wo.number then vim.wo.relativenumber = false end end })
au("InsertLeave", { callback = function() if vim.wo.number and vim.bo.buftype == "" then vim.wo.relativenumber = true end end })
