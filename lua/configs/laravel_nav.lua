-- Laravel navigation helpers:
--  * category finders (find views / controllers / models / …) via telescope
--  * "goto" from a Debugbar-style string:
--      - view dot-notation:   portal.projects.show
--          -> resources/views/portal/projects/show.blade.php
--      - controller action:   App\Http\Controllers\Portal\ProjectController@show
--          -> app/Http/Controllers/Portal/ProjectController.php (jumps to show())
local M = {}

-- Project root (nearest dir with artisan/composer.json), else cwd.
function M.root()
  return vim.fs.root(0, { "artisan", "composer.json", ".git" }) or vim.fn.getcwd()
end

--- Fuzzy-find files within a Laravel subdirectory.
function M.find_in(subdir, title)
  local dir = M.root() .. "/" .. subdir
  if vim.fn.isdirectory(dir) == 0 then
    vim.notify("Laravel: no " .. subdir .. " directory here", vim.log.levels.WARN)
    return
  end
  require("telescope.builtin").find_files { cwd = dir, prompt_title = title or subdir }
end

-- Build the PSR-4 prefix->dir map from composer.json (autoload + autoload-dev),
-- longest prefix first so the most specific namespace wins.
local function psr4_map(root)
  local map = {}
  local composer = root .. "/composer.json"
  if vim.fn.filereadable(composer) == 1 then
    local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(composer), "\n"))
    if ok and type(data) == "table" then
      local function collect(section)
        if type(section) == "table" and type(section["psr-4"]) == "table" then
          for prefix, dir in pairs(section["psr-4"]) do
            if type(dir) == "table" then
              dir = dir[1]
            end
            if type(prefix) == "string" and type(dir) == "string" then
              table.insert(map, { prefix = prefix, dir = dir })
            end
          end
        end
      end
      collect(data.autoload)
      collect(data["autoload-dev"])
    end
  end
  if #map == 0 then
    map = { { prefix = "App\\", dir = "app/" } }
  end
  table.sort(map, function(a, b)
    return #a.prefix > #b.prefix
  end)
  return map
end

-- Fully-qualified class name -> file path (PSR-4 aware).
function M.class_to_path(root, fqcn)
  fqcn = fqcn:gsub("^\\", "")
  for _, e in ipairs(psr4_map(root)) do
    if fqcn:sub(1, #e.prefix) == e.prefix then
      local rest = fqcn:sub(#e.prefix + 1):gsub("\\", "/")
      local dir = e.dir:gsub("/$", "")
      return root .. "/" .. dir .. "/" .. rest .. ".php"
    end
  end
  -- Fallback: App\ -> app/, otherwise namespace mapped 1:1.
  local rest = fqcn:gsub("^App\\", "app/"):gsub("\\", "/")
  return root .. "/" .. rest .. ".php"
end

-- View dot-notation -> blade path. Handles `package::view.name` best-effort.
function M.view_to_path(root, name)
  name = name:gsub("^.-::", "") -- drop a "package::" namespace prefix
  return root .. "/resources/views/" .. (name:gsub("%.", "/")) .. ".blade.php"
end

local function open_at(path, method)
  if vim.fn.filereadable(path) == 0 then
    vim.notify("Laravel: file not found\n" .. path, vim.log.levels.WARN)
    return false
  end
  vim.cmd "normal! m'" -- jumplist, so <C-o> returns
  vim.cmd("edit " .. vim.fn.fnameescape(path))
  if method and #method > 0 then
    vim.fn.cursor(1, 1)
    if vim.fn.search("\\<function\\s\\+" .. method .. "\\>", "cW") > 0 then
      vim.cmd "normal! zz"
    end
  end
  return true
end

--- Resolve a Debugbar-style string and jump to the target.
function M.goto(str)
  if not str then
    return
  end
  str = vim.trim(str):match "^%S+" or "" -- first token, drop trailing junk
  if str == "" then
    return
  end
  local root = M.root()

  -- Controller / FQCN: has a namespace separator or @method
  if str:find "\\" or str:find "@" then
    local class, method = str:match "^(.-)@(.+)$"
    class = class or str
    return open_at(M.class_to_path(root, class), method)
  end

  -- View dot-notation
  if str:find "%." then
    if open_at(M.view_to_path(root, str)) then
      return
    end
  end

  -- Fallback: fuzzy find with the text prefilled
  require("telescope.builtin").find_files { cwd = root, default_text = str }
end

-- ── Debugbar request picker ────────────────────────────────────────────────
-- Laravel Debugbar persists each request to storage/debugbar/<id>.json. We read
-- the most recent one, pull the controller (route collector) + rendered views
-- (views collector), and offer them in a Telescope list to jump to.

-- Resolve a Debugbar view template name to a blade path. Handles dot-notation
-- ("portal.projects.show"), bare/relative paths, "name (path)" forms, and
-- "package::view" namespaces (via view_to_path).
local function resolve_view(root, name)
  name = vim.trim(name)
  -- "portal.projects.show (resources/views/...)" -> prefer the path in parens
  local paren = name:match "%((.-)%)%s*$"
  if paren and paren:find "%.blade%.php$" then
    name = vim.trim(paren)
  else
    name = vim.trim((name:gsub("%s*%(.-%)%s*$", "")))
  end
  if name:find "/" or name:find "%.blade%.php$" then
    if name:sub(1, 1) == "/" then
      return name
    end
    return root .. "/" .. name
  end
  return M.view_to_path(root, name)
end

-- Build the jump-target list from a decoded Debugbar request payload.
local function collect_targets(root, data)
  local items, seen = {}, {}
  local function push(item)
    local key = item.path .. ":" .. (item.method or item.line or "")
    if not seen[key] then
      seen[key] = true
      table.insert(items, item)
    end
  end

  -- Resolve a Debugbar xdebug_link ({ path = "/app/…", line = "61" }) to an
  -- absolute path + line number. Returns nil when the link is absent.
  local function xdebug_target(xl)
    if type(xl) ~= "table" or type(xl.path) ~= "string" or xl.path == "" then
      return nil, nil
    end
    local p = xl.path:sub(1, 1) == "/" and (root .. xl.path) or (root .. "/" .. xl.path)
    return p, tonumber(xl.line)
  end

  -- A Debugbar request field may be a bare string or { value =, xdebug_link = }.
  local function field(v)
    if type(v) == "table" then
      return v.value, v.xdebug_link
    end
    return v, nil
  end

  -- Controller. Newer Debugbar exposes it on the Symfony request collector:
  --   request.data.controller = { value = "Class@method", xdebug_link = {…} }
  --   request.data.file       = { value = "app/…/X.php:start-end", … }
  -- Older builds used a flat route collector (data.route.controller / .file).
  local req = (type(data.request) == "table" and type(data.request.data) == "table" and data.request.data)
    or (type(data.route) == "table" and data.route)
    or {}
  local action, action_xl = field(req.controller)
  local file_val, file_xl = field(req.file)

  local has_action = type(action) == "string" and action ~= "" and action:lower() ~= "closure"
  if has_action or (type(file_val) == "string" and file_val ~= "") then
    local class, method = (action or ""):match "^(.-)@(.+)$"
    -- Prefer the path/line Debugbar already resolved; else parse the
    -- "X.php:start-end" file string; else resolve the class via PSR-4.
    local path, line = xdebug_target(action_xl or file_xl)
    if not path and type(file_val) == "string" and file_val ~= "" then
      local rel, ln = file_val:match "^(.-):(%d+)"
      rel = rel or file_val
      path = rel:sub(1, 1) == "/" and rel or (root .. "/" .. rel)
      line = ln and tonumber(ln) or nil
    end
    if not path and has_action then
      path = M.class_to_path(root, class or action)
    end
    if path then
      local label = has_action and action or (file_val:gsub(":%d+%-?%d*$", ""))
      push {
        kind = "controller",
        display = "  " .. label,
        ordinal = "controller " .. label,
        path = path,
        method = (not line) and method or nil,
        line = line,
      }
    end
  end

  -- Views (views collector). `templates` is an array of { name = ... }.
  local views = type(data.views) == "table" and data.views or {}
  local templates = views.templates
  if type(templates) == "table" then
    if type(templates.templates) == "table" then -- some versions nest it
      templates = templates.templates
    end
    for _, t in ipairs(templates) do
      local name = type(t) == "table" and (t.name or t.value) or t
      local ttype = type(t) == "table" and t.type or nil
      -- Keep only real blade views. Skip Blade's internal anonymous-component
      -- renders (__components::…) and any controller row a collector may inject
      -- here (it's a PHP class, not a view — already sourced from the request
      -- collector above; resolving it as a view yields a bogus blade path).
      local is_view = type(name) == "string"
        and name ~= ""
        and not name:find("__components", 1, true)
        and ttype ~= "controller"
        and not name:find "@"
        and not name:find("\\", 1, true)
      if is_view then
        -- When Debugbar groups repeated renders it prefixes the name with a
        -- count ("11x portal.projects.show"). Drop it for display, and resolve
        -- the file from the xdebug_link Debugbar already computed (falling back
        -- to the cleaned dot-name) so the count never leaks into the path.
        local clean = (name:gsub("^%d+x%s+", ""))
        local path, line = xdebug_target(type(t) == "table" and t.xdebug_link or nil)
        push {
          kind = "view",
          display = "  " .. clean,
          ordinal = "view " .. clean,
          path = path or resolve_view(root, clean),
          line = line,
        }
      end
    end
  end

  return items
end

-- Open a collected target (controller method / blade view) in the jumplist.
local function jump(item)
  if not item or not item.path then
    return
  end
  if vim.fn.filereadable(item.path) == 0 then
    vim.notify("Laravel: file not found\n" .. item.path, vim.log.levels.WARN)
    return
  end
  vim.cmd "normal! m'" -- jumplist, so <C-o> returns
  vim.cmd("edit " .. vim.fn.fnameescape(item.path))
  if item.line then
    vim.fn.cursor(item.line, 1)
    vim.cmd "normal! zz"
  elseif item.method and #item.method > 0 then
    vim.fn.cursor(1, 1)
    if vim.fn.search("\\<function\\s\\+" .. item.method .. "\\>", "cW") > 0 then
      vim.cmd "normal! zz"
    end
  end
end

--- Pick the controller / views of the latest Debugbar request and jump to one.
--- Falls back to the manual goto prompt when there's no stored request data.
function M.debugbar_picker()
  local root = M.root()
  local dir = root .. "/storage/debugbar"
  local files = vim.fn.isdirectory(dir) == 1 and vim.fn.glob(dir .. "/*.json", true, true) or {}
  if vim.tbl_isempty(files) then
    vim.notify("Laravel: no Debugbar request data (enable Debugbar storage) — paste instead", vim.log.levels.WARN)
    return M.goto_prompt()
  end

  -- Most recently written request file.
  local latest, latest_t = nil, -1
  for _, f in ipairs(files) do
    local t = vim.fn.getftime(f)
    if t > latest_t then
      latest, latest_t = f, t
    end
  end

  local ok, data = pcall(vim.json.decode, table.concat(vim.fn.readfile(latest), "\n"))
  if not ok or type(data) ~= "table" then
    vim.notify("Laravel: could not parse Debugbar data\n" .. latest, vim.log.levels.WARN)
    return
  end

  local items = collect_targets(root, data)
  if vim.tbl_isempty(items) then
    vim.notify("Laravel: no controller/views in latest Debugbar request", vim.log.levels.WARN)
    return
  end

  local meta = type(data.__meta) == "table" and data.__meta or {}
  local title = "Debugbar"
  if meta.method or meta.uri then
    title = "Debugbar: " .. vim.trim((meta.method or "") .. " " .. (meta.uri or ""))
  end

  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table {
        results = items,
        entry_maker = function(item)
          return {
            value = item,
            display = item.display,
            ordinal = item.ordinal,
            path = item.path, -- drives the file preview
            lnum = item.line,
          }
        end,
      },
      sorter = conf.generic_sorter {},
      previewer = conf.file_previewer {},
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if entry and entry.value then
            jump(entry.value)
          end
        end)
        return true
      end,
    })
    :find()
end

--- Run a laravel.nvim picker by name, guarding the global (nil outside a project).
function M.picker(name)
  if not _G.Laravel then
    return vim.notify("laravel.nvim: open a Laravel project first", vim.log.levels.WARN)
  end
  local ok, p = pcall(function()
    return Laravel.pickers[name]
  end)
  if ok and type(p) ~= "nil" then
    p()
  end
end

--- Prompt then goto. Starts empty (so there's nothing to delete); submitting it
--- blank falls back to the system clipboard for a quick paste-free jump.
function M.goto_prompt()
  vim.ui.input({ prompt = "Goto (view or Controller@method): " }, function(input)
    if not input then
      return
    end
    input = vim.trim(input)
    if input == "" then
      input = vim.trim((vim.fn.getreg "+" or ""):gsub("[\r\n]", ""))
    end
    if input ~= "" then
      M.goto(input)
    end
  end)
end

return M
