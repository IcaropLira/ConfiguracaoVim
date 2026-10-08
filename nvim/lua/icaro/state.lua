-- Estado persistente (tema, toggles, autocomplete por linguagem...) em JSON.
local M = {}
local file = vim.fn.stdpath("state") .. "/icaro.json"
local cache

local function load()
  if cache then return cache end
  cache = {}
  local f = io.open(file, "r")
  if f then
    local ok, data = pcall(vim.json.decode, f:read("*a"))
    f:close()
    if ok and type(data) == "table" then cache = data end
  end
  return cache
end

function M.get(key, default)
  local v = load()[key]
  if v == nil then return default end
  return v
end

function M.set(key, value)
  load()[key] = value
  vim.fn.mkdir(vim.fn.fnamemodify(file, ":h"), "p")
  local f = io.open(file, "w")
  if f then
    f:write(vim.json.encode(cache))
    f:close()
  end
end

return M
