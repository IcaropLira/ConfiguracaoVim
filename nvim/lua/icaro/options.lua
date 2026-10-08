local o = vim.opt

o.number = true
o.relativenumber = true
o.cursorline = true
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.signcolumn = "yes"
o.scrolloff = 10
o.sidescrolloff = 8
o.splitright = true
o.splitbelow = true
o.undofile = true
o.swapfile = false
o.ignorecase = true
o.smartcase = true
o.updatetime = 200
o.timeoutlen = 400
o.ttimeoutlen = 20
o.confirm = true
o.showmode = false          -- o modo aparece na statusline
o.laststatus = 3            -- statusline global
o.cmdheight = 1
o.wrap = false
o.linebreak = true
o.breakindent = true
o.expandtab = true
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4
o.smartindent = true
o.completeopt = { "menu", "menuone", "noselect" }
o.winblend = 0
o.pumheight = 14
o.cmdheight = 0
o.showtabline = 2
o.showcmd = false
o.ruler = false
o.pumblend = 10
o.conceallevel = 2
o.smoothscroll = true
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " ", fold = " ", foldopen = "▾", foldclose = "▸", vert = "│" }
o.foldlevel = 99
o.foldlevelstart = 99
o.inccommand = "split"
o.shortmess:append("cI")
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" }
if vim.fn.has("nvim-0.11") == 1 then o.winborder = "rounded" end

vim.g.loaded_netrw = 1       -- o explorer é o neo-tree (F2)
vim.g.loaded_netrwPlugin = 1
