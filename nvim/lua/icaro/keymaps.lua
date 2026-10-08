local map = vim.keymap.set

map({ "n", "i", "v" }, "<C-s>", "<Cmd>write<CR><Esc>", { desc = "Salvar" })
map("n", "<leader>w", "<Cmd>write<CR>", { desc = "Salvar" })
map("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Sair" })
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { silent = true })

-- janelas (também a partir do terminal)
for _, k in ipairs({ "h", "j", "k", "l" }) do
  map("n", "<C-" .. k .. ">", "<C-w>" .. k, { desc = "Janela " .. k })
  map("t", "<C-" .. k .. ">", "<C-\\><C-n><C-w>" .. k, { desc = "Janela " .. k })
end

-- buffers
map("n", "<Tab>", "<Cmd>bnext<CR>", { silent = true, desc = "Próximo buffer" })
map("n", "<S-Tab>", "<Cmd>bprevious<CR>", { silent = true, desc = "Buffer anterior" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Fechar buffer" })

-- mover linhas
map("n", "<A-j>", "<Cmd>m .+1<CR>==", { silent = true })
map("n", "<A-k>", "<Cmd>m .-2<CR>==", { silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- clipboard
-- Ctrl+C copia a seleção visual para a área de transferência do sistema.
-- No modo normal, Ctrl+C continua livre para o comportamento padrão do Neovim.
map("v", "<C-c>", '"+y', { silent = true, desc = "Copiar para área de transferência" })

-- indentação mantendo a seleção
map("v", "<", "<gv")
map("v", ">", ">gv")

-- scroll centralizado
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Shift+BS / Ctrl+BS apagam um par vazio () [] {} "" '' de uma vez
map("i", "<S-BS>", "<BS><Del>", { desc = "Apaga par vazio" })
map("i", "<C-BS>", "<BS><Del>", { desc = "Apaga par vazio" })

-- sair do modo terminal
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Sair do modo terminal" })
