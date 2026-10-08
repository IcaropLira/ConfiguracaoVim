-- Preferência de ícones: Nerd Font (padrão do kitty desta config) ou ASCII.
local state = require("icaro.state")
local env = vim.env.ICARO_NERD_FONT
vim.g.icaro_nerd_font = (env ~= "0") and state.get("nerd_font", true)
