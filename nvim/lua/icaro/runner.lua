-- Compilar/executar em um terminal embutido (F5–F8), igual ao do Vim:
--  • enquanto o programa roda, Enter vai pro stdin;
--  • depois que termina, Enter (ou q) fecha o terminal.
local M = {}

local function shq(s) return vim.fn.shellescape(s) end
local start_term = (vim.fn.has("nvim-0.11") == 1)
    and function(cmd, opts) opts.term = true; return vim.fn.jobstart(cmd, opts) end
    or function(cmd, opts) return vim.fn.termopen(cmd, opts) end

local function finished(buf) return vim.b[buf].icaro_done == true end

local function close(buf)
  if vim.api.nvim_buf_is_valid(buf) then pcall(vim.cmd, "bwipeout! " .. buf) end
end

function M.run(cmd)
  vim.cmd.stopinsert()
  -- fecha o terminal anterior do runner, se existir
  if M.buf and vim.api.nvim_buf_is_valid(M.buf) then close(M.buf) end

  vim.cmd("botright 14new")
  local buf = vim.api.nvim_get_current_buf()
  M.buf = buf
  local wrapped = cmd .. '; icaro_ec=$?; echo; echo "[Código de saída: $icaro_ec]  —  Enter ou q fecha"'
  vim.b[buf].icaro_done = false
  start_term({ "sh", "-c", wrapped }, {
    cwd = vim.fn.getcwd(),
    on_exit = function()
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(buf) then
          vim.b[buf].icaro_done = true
          if vim.api.nvim_get_current_buf() == buf then vim.cmd.stopinsert() end
        end
      end)
    end,
  })
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "icaro-runner"
  for _, opt in ipairs({ "number", "relativenumber", "cursorline", "list" }) do vim.wo[opt] = false end
  vim.wo.signcolumn = "no"
  vim.wo.winfixheight = true

  -- Terminal-Job mode: Enter vai pro programa; se ele já acabou, fecha.
  vim.keymap.set("t", "<CR>", function()
    if finished(buf) then
      vim.schedule(function() close(buf) end)
      return "<C-\\><C-n>"
    end
    return "<CR>"
  end, { buffer = buf, expr = true, silent = true })
  -- Terminal-Normal mode (onde o Neovim fica depois que o processo acaba / após Esc).
  vim.keymap.set("n", "<CR>", function()
    if finished(buf) then close(buf) else vim.cmd("normal! j") end
  end, { buffer = buf, silent = true })
  vim.keymap.set("n", "q", function() if finished(buf) then close(buf) end end, { buffer = buf, silent = true })
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = buf, silent = true })
  vim.cmd.startinsert()
end

-- ---------- comandos por linguagem ----------
local function cpp_compile(file)
  local out = vim.fn.fnamemodify(file, ":p:r")
  return "g++ -std=c++17 -O2 -Wall -Wextra " .. shq(file) .. " -o " .. shq(out), out
end

local function java_class(file)
  local base = vim.fn.fnamemodify(file, ":t:r")
  return base:match("_cp$") and "Main" or base
end
local function java_compile(file)
  return "javac -d " .. shq(vim.fn.fnamemodify(file, ":p:h")) .. " " .. shq(file)
end
local function java_run(file)
  return "java -cp " .. shq(vim.fn.fnamemodify(file, ":p:h")) .. " " .. java_class(file)
end

local function input_ok()
  if vim.fn.filereadable("input.txt") == 1 then return true end
  vim.notify("input.txt não encontrado", vim.log.levels.ERROR)
  return false
end

local langs = {
  cpp = {
    compile = function(f) return (cpp_compile(f)) end,
    run = function(f)
      local out = vim.fn.fnamemodify(f, ":p:r")
      if vim.fn.filereadable(out) == 0 then vim.notify("Executável não encontrado. Use F5 ou F7 primeiro.", vim.log.levels.ERROR); return end
      return shq(out)
    end,
    build_run = function(f) local c, out = cpp_compile(f); return c .. " && " .. shq(out) end,
    test = function(f) if not input_ok() then return end local c, out = cpp_compile(f); return c .. " && " .. shq(out) .. " < input.txt" end,
  },
  java = {
    compile = java_compile,
    run = java_run,
    build_run = function(f) return java_compile(f) .. " && " .. java_run(f) end,
    test = function(f) if not input_ok() then return end return java_compile(f) .. " && " .. java_run(f) .. " < input.txt" end,
  },
  python = {
    build_run = function(f) return (vim.fn.executable("python3") == 1 and "python3 " or "python ") .. shq(f) end,
    test = function(f)
      if not input_ok() then return end
      return (vim.fn.executable("python3") == 1 and "python3 " or "python ") .. shq(f) .. " < input.txt"
    end,
  },
}

-- action: compile | run | build_run | test
function M.dispatch(action)
  local lang = langs[vim.bo.filetype]
  if not lang or not lang[action] then
    vim.notify(("Sem '%s' para o filetype '%s'"):format(action, vim.bo.filetype), vim.log.levels.INFO)
    return
  end
  if vim.bo.buftype == "" and vim.bo.modifiable then pcall(vim.cmd, "silent write") end
  local file = vim.fn.expand("%:p")
  local cmd = lang[action](file)
  if cmd then M.run(cmd) end
end

-- terminal comum (F9)
function M.terminal()
  vim.cmd.stopinsert()
  vim.cmd("botright 14split")
  vim.cmd.terminal()
  for _, opt in ipairs({ "number", "relativenumber" }) do vim.wo[opt] = false end
  vim.cmd.startinsert()
end

-- templates de arquivo novo (.cpp / .java)
function M.setup_templates()
  local paths = require("icaro.paths")
  local dir = paths.template_dir
  if not dir then return end
  local function read(name)
    local f = dir .. "/" .. name
    if vim.fn.filereadable(f) == 1 then return vim.fn.readfile(f) end
  end
  vim.api.nvim_create_autocmd("BufNewFile", {
    group = vim.api.nvim_create_augroup("icaro_templates", { clear = true }),
    pattern = { "*.cpp", "*.java" },
    callback = function(ev)
      local ext = ev.file:match("%.(%w+)$")
      local lines
      if ext == "cpp" then
        lines = read("cpp.cpp")
      else
        local base = vim.fn.fnamemodify(ev.file, ":t:r")
        if base:match("_cp$") then
          lines = read("java_cp.java")
        else
          lines = read("java_main.java")
          if lines then
            for i, l in ipairs(lines) do lines[i] = l:gsub("__CLASSNAME__", base) end
          end
        end
      end
      if lines then
        vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, lines)
        vim.api.nvim_win_set_cursor(0, { 1, 0 })
      end
    end,
  })
end

return M
