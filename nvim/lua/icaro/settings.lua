-- Central de controle RF: menu flutuante próprio, sem depender de vim.ui.select.
-- Navegação: j/k ou setas, Enter/Space para alterar, h/Backspace para voltar, q/Esc fecha.
local state = require("icaro.state")
local M = { win = nil, buf = nil, page = "home" }
local ns = vim.api.nvim_create_namespace("icaro_settings")

local function notify(msg)
  vim.notify("RF  •  " .. msg, vim.log.levels.INFO, { title = "Central de configurações" })
end
local function valid() return M.win and vim.api.nvim_win_is_valid(M.win) end
local function close()
  if valid() then pcall(vim.api.nvim_win_close, M.win, true) end
  M.win, M.buf = nil, nil
end
local function bool(v) return v and "● LIGADO" or "○ DESLIGADO" end

local function option_items()
  return {
    {key="number", label="Numeração absoluta", opt="number", default=true},
    {key="relativenumber", label="Numeração relativa", opt="relativenumber", default=true},
    {key="cursorline", label="Realçar linha atual", opt="cursorline", default=true},
    {key="cursorcolumn", label="Realçar coluna atual", opt="cursorcolumn", default=false},
    {key="wrap", label="Quebra automática de linha", opt="wrap", default=false},
    {key="linebreak", label="Quebra em palavras", opt="linebreak", default=true},
    {key="termguicolors", label="Cores 24-bit", opt="termguicolors", default=true},
    {key="showmode", label="Mostrar modo na linha de comando", opt="showmode", default=false},
    {key="spell", label="Correção ortográfica", opt="spell", default=false},
    {key="ignorecase", label="Busca ignora maiúsculas", opt="ignorecase", default=true},
    {key="smartcase", label="Busca inteligente (Smartcase)", opt="smartcase", default=true},
    {key="hlsearch", label="Destacar resultados da busca", opt="hlsearch", default=true},
    {key="incsearch", label="Busca incremental", opt="incsearch", default=true},
    {key="expandtab", label="Usar espaços em vez de TAB", opt="expandtab", default=true},
    {key="smartindent", label="Indentação inteligente", opt="smartindent", default=true},
    {key="autoindent", label="Manter indentação", opt="autoindent", default=true},
    {key="swapfile", label="Arquivo swap de recuperação", opt="swapfile", default=true},
    {key="undofile", label="Histórico persistente de undo", opt="undofile", default=true},
    {key="backup", label="Criar backups automáticos", opt="backup", default=false},
    {key="writebackup", label="Backup antes de sobrescrever", opt="writebackup", default=true},
    {key="confirm", label="Confirmar ações destrutivas", opt="confirm", default=true},
    {key="splitright", label="Divisões verticais à direita", opt="splitright", default=true},
    {key="splitbelow", label="Divisões horizontais abaixo", opt="splitbelow", default=true},
    {key="scrolloff", label="Contexto vertical (0/3/5/8/12)", opt="scrolloff", default=8, values={0,3,5,8,12}},
    {key="signcolumn", label="Coluna de sinais (yes/no/auto)", opt="signcolumn", default="yes", values={"yes","no","auto"}},
    {key="colorcolumn", label="Coluna-guia (0/80/100)", opt="colorcolumn", default="" , values={"","80","100"}},
    {key="timeoutlen", label="Tempo para atalhos (ms)", opt="timeoutlen", default=500, values={200,350,500,800,1000}},
  }
end
local function getopt(it)
  local v = state.get("option_"..it.key, it.default)
  if it.opt == "scrolloff" or it.opt == "timeoutlen" then v = tonumber(v) or it.default end
  vim.opt[it.opt] = v
  return v
end
local function toggle_rows()
  local t = require("icaro.toggles")
  return {
    {"Autocomplete da linguagem atual", function() t.autocomplete() end, function() return t.completion_enabled() end},
    {"Dicas inline / inlay hints", function() t.inlay() end, function() return t.s.inlay end},
    {"Fechar pares e aspas automaticamente", function() t.autopairs() end, function() return t.s.pairs end},
    {"Assinatura e documentação automática", function() t.hints() end, function() return t.s.hints end},
    {"Diagnósticos de erros e avisos", function() t.diagnostics() end, function() return t.s.diag end},
    {"Destaque de parênteses correspondentes", function() t.matchparen() end, function() return t.s.matchparen end},
    {"Header / winbar", function() t.header() end, function() return t.s.header end},
    {"Mensagens de progresso LSP", function() t.lsp_progress() end, function() return vim.g.icaro_lsp_progress end},
    {"Modo silencioso (pausa distrações)", function() t.quiet() end, function() return vim.g.icaro_quiet end},
    {"Mostrar/ocultar árvore de arquivos (Neo-tree)", function() vim.g.icaro_feature_neo_tree = not (vim.g.icaro_feature_neo_tree ~= false); if vim.g.icaro_feature_neo_tree then vim.cmd("Neotree show") else pcall(vim.cmd,"Neotree close") end; state.set("feature_neo_tree",vim.g.icaro_feature_neo_tree) end, function() return vim.g.icaro_feature_neo_tree ~= false end},
    {"Ícones Nerd Font (preferência)", function() local v=not state.get("nerd_font",true); state.set("nerd_font",v); notify("Preferência de ícones salva; reinicie para aplicar em todos os plugins.") end, function() return state.get("nerd_font",true) end},
  }
end
local function themes()
  local t = require("icaro.themes")
  local out = {}
  for i, th in ipairs(t.list) do out[#out+1] = {label=th.title.." ["..th.short.."]", run=function()
    for n,x in ipairs(t.list) do if x.id==th.id then t.index=n; break end end
    local ok, err = pcall(vim.cmd.colorscheme, th.id)
    if ok then state.set("theme",th.id); notify("Tema aplicado: "..th.title) else notify("Falha ao aplicar tema: "..tostring(err)) end
  end, active=function() return t.current().id==th.id end} end
  return out
end
local function plugins()
  local optional = {
    {key="which_key", label="Which-key: ajuda visual de atalhos"},
    {key="todo_comments", label="TODO-comments: marca TODO/FIXME"},
    {key="indent_scope", label="Mini Indentscope: guia visual de blocos"},
  }
  local out = {}
  for _,p in ipairs(optional) do
    out[#out+1] = {label=p.label, state=function() return state.get("plugin_"..p.key,true) end,
      run=function() local v=not state.get("plugin_"..p.key,true); state.set("plugin_"..p.key,v); notify(p.label..(v and " habilitado" or " desabilitado").." — reinicie o Neovim para aplicar.") end}
  end
  local maintenance = {
    {label="Abrir gerenciador de plugins (:Lazy)", run=function() vim.cmd("Lazy") end},
    {label="Instalar/atualizar plugins (:Lazy sync)", run=function() vim.cmd("Lazy sync") end},
    {label="Verificar saúde da configuração (:checkhealth)", run=function() vim.cmd("checkhealth") end},
    {label="Diagnóstico RF (:IcaroDoctor)", run=function() vim.cmd("IcaroDoctor") end},
    {label="Nota: plugins são gerenciados pelo Lazy; mudanças de instalação exigem reinício", run=function() notify("Use :Lazy para instalar/atualizar. Os três extras acima podem ser habilitados nesta central; reinicie para aplicar.") end},
  }
  for _,item in ipairs(maintenance) do out[#out+1]=item end
  return out
end
local function entries()
  if M.page == "home" then return {
    {label="TEMAS  ›", page="themes", icon="◈"},
    {label="RECURSOS: ligar / desligar  ›", page="features", icon="◉"},
    {label="PREFERÊNCIAS do editor  ›", page="options", icon="⚙"},
    {label="PLUGINS, manutenção e diagnóstico  ›", page="plugins", icon="✦"},
    {label="Restaurar preferências gerais", action="reset", icon="↺"},
    {label="Fechar central", action="close", icon="×"},
  } elseif M.page == "features" then
    local out={}
    for _,r in ipairs(toggle_rows()) do out[#out+1]={label=r[1], state=function() local ok,v=pcall(r[3]); return ok and v or false end, run=r[2]} end
    out[#out+1]={label="‹ Voltar", page="home"}; return out
  elseif M.page == "options" then
    local out={}
    for _,it in ipairs(option_items()) do out[#out+1]={label=it.label, option=it} end
    out[#out+1]={label="‹ Voltar", page="home"}; return out
  elseif M.page == "themes" then
    local out={}
    for _,it in ipairs(themes()) do out[#out+1]=it end
    out[#out+1]={label="‹ Voltar", page="home"}; return out
  elseif M.page == "plugins" then
    local out=plugins(); for _,it in ipairs(out) do it.icon="✦" end; out[#out+1]={label="‹ Voltar",page="home"}; return out
  end
  return {}
end
local function render()
  if not (M.buf and vim.api.nvim_buf_is_valid(M.buf)) then return end
  local es=entries(); M.entries=es
  local lines={"  RF  /  CENTRAL DE CONFIGURAÇÕES", "  j/k ou ↑/↓ navegar   Enter/Space selecionar   q/Esc fechar", "  ─────────────────────────────────────────────────────"}
  local marks={}
  for i,e in ipairs(es) do
    local suffix=""
    if e.state then suffix="   "..bool(e.state())
    elseif e.option then local v=getopt(e.option); suffix="   [ "..tostring(v==true and "Ligado" or v==false and "Desligado" or v).." ]"
    elseif e.active then suffix=e.active() and "   ◀ atual" or ""
    end
    lines[#lines+1]="  "..(e.icon or (e.page and "›" or "•")).."  "..e.label..suffix
    marks[i]=#lines
  end
  lines[#lines+1]=""
  lines[#lines+1]="  Dica: opções com valores abrem uma lista; opções booleanas alternam imediatamente."
  vim.bo[M.buf].modifiable=true
  vim.api.nvim_buf_set_lines(M.buf,0,-1,false,lines)
  vim.bo[M.buf].modifiable=false
  vim.api.nvim_buf_clear_namespace(M.buf,ns,0,-1)
  vim.api.nvim_buf_add_highlight(M.buf,ns,"Title",0,0,-1)
  vim.api.nvim_buf_add_highlight(M.buf,ns,"Comment",1,0,-1)
  vim.api.nvim_buf_add_highlight(M.buf,ns,"Comment",2,0,-1)
  for i,e in ipairs(es) do
    local line=marks[i]-1
    vim.api.nvim_buf_add_highlight(M.buf,ns,e.page and "Directory" or "Normal",line,0,-1)
    if e.state then vim.api.nvim_buf_add_highlight(M.buf,ns,e.state() and "DiagnosticOk" or "DiagnosticError",line,0,-1)
    elseif e.active and e.active() then vim.api.nvim_buf_add_highlight(M.buf,ns,"DiagnosticOk",line,0,-1) end
  end
  vim.api.nvim_win_set_cursor(M.win,{math.min((M.selected or 1)+3,#lines-1),0})
end
local function cycle_value(it)
  local current=getopt(it)
  local idx=1
  for i,v in ipairs(it.values) do if tostring(v)==tostring(current) then idx=i; break end end
  local nextv=it.values[(idx % #it.values)+1]
  state.set("option_"..it.key,nextv); vim.opt[it.opt]=nextv
  notify(it.label..": "..(tostring(nextv)=="" and "desligado" or tostring(nextv)))
  render()
end
local function activate()
  local e=M.entries and M.entries[M.selected]
  if not e then return end
  if e.page then M.page=e.page; M.selected=1; render(); return end
  if e.action=="close" then close(); return end
  if e.action=="reset" then
    for _,it in ipairs(option_items()) do state.set("option_"..it.key,it.default); vim.opt[it.opt]=it.default end
    notify("Preferências gerais restauradas."); render(); return
  end
  if e.option then
    local it=e.option
    if it.values then cycle_value(it) else
      local v=not getopt(it); state.set("option_"..it.key,v); vim.opt[it.opt]=v; notify(it.label..(v and " ligado" or " desligado")); render()
    end
    return
  end
  if e.run then e.run(); if valid() then render() end end
end
function M.open()
  if valid() then close(); return end
  M.page="home"; M.selected=1
  M.buf=vim.api.nvim_create_buf(false,true)
  vim.bo[M.buf].buftype="nofile"; vim.bo[M.buf].bufhidden="wipe"; vim.bo[M.buf].swapfile=false; vim.bo[M.buf].filetype="icaro-config"
  local width=math.min(88,math.max(54,vim.o.columns-8)); local height=math.min(30,math.max(12,vim.o.lines-6))
  M.win=vim.api.nvim_open_win(M.buf,true,{relative="editor",style="minimal",border="rounded",title=" RF • CONFIG ",title_pos="center",footer=" Enter: selecionar  •  q: fechar ",footer_pos="center",width=width,height=height,row=math.floor((vim.o.lines-height)/2)-1,col=math.floor((vim.o.columns-width)/2)})
  vim.wo[M.win].cursorline=true; vim.wo[M.win].number=false; vim.wo[M.win].relativenumber=false; vim.wo[M.win].wrap=false
  local function move(delta) M.selected=math.max(1,math.min(#(M.entries or {}),M.selected+delta)); render() end
  local function map(k,fn) vim.keymap.set("n",k,fn,{buffer=M.buf,silent=true,nowait=true}) end
  map("j",function() move(1) end); map("<Down>",function() move(1) end)
  map("k",function() move(-1) end); map("<Up>",function() move(-1) end)
  map("<CR>",activate); map("<Space>",activate); map("l",activate)
  map("q",close); map("<Esc>",close); map("<C-c>",close)
  map("h",function() if M.page~="home" then M.page="home"; M.selected=1; render() else close() end end)
  map("<BS>",function() M.page="home"; M.selected=1; render() end)
  map("g",function() M.selected=1; render() end); map("G",function() M.selected=#(M.entries or {}); render() end)
  map("<2-LeftMouse>",function() local row=vim.api.nvim_win_get_cursor(M.win)[1]-3; if row>0 then M.selected=row; activate() end end)
  render()
end
function M.setup()
  for _,it in ipairs(option_items()) do getopt(it) end
  vim.g.icaro_feature_neo_tree=state.get("feature_neo_tree",true)
  vim.api.nvim_create_user_command("ConfigMenu",M.open,{desc="Abrir/fechar central de configurações RF"})
  vim.api.nvim_create_user_command("ConfigReset",function() for _,it in ipairs(option_items()) do state.set("option_"..it.key,it.default); vim.opt[it.opt]=it.default end; notify("Preferências restauradas.") end,{desc="Restaurar preferências do editor"})
  vim.keymap.set("n","<S-F12>",M.open,{desc="Abrir/fechar central de configurações RF",silent=true})
  vim.keymap.set("n","<F24>",M.open,{desc="Abrir/fechar central de configurações RF (compatibilidade)",silent=true})
  -- Atalho secundário útil, sem depender do leader.
  vim.keymap.set("n","<leader>uc",M.open,{desc="Central de configurações RF",silent=true})
end
return M
