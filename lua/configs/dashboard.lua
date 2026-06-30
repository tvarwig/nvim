-- Startup splash (NvChad nvdash): a general launcher + command reference.
-- Every entry is shown and runnable (press its key, or move with j/k + Enter).
local function btn(txt, keys, cmd)
  return { txt = "  " .. txt, keys = keys, cmd = cmd, hl = "NvDashButtons", no_gap = true }
end

local function run(txt, cmd) -- Enter-only entry (no shortcut key shown)
  return { txt = "  " .. txt, cmd = cmd, hl = "NvDashButtons", no_gap = true }
end

local function header(title)
  return { txt = "  " .. title, hl = "NvDashAscii", no_gap = true }
end

local function note(txt)
  return { txt = "  " .. txt, hl = "NvDashFooter", no_gap = true }
end

local sep = { txt = "─", hl = "NvDashFooter", no_gap = true, rep = true }

local L = "lua require('configs.laravel_nav').picker"
local FIND = "lua require('configs.laravel_nav').find_in"
-- Lazy-load nvim-dap (nvdash overrides the lazy `keys`, so trigger it ourselves).
local DAP = "lua require('lazy').load({plugins={'nvim-dap'}}) require('dap')"

return {
  load_on_startup = true,

  header = {
    "",
    "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
    "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
    "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
    "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
    "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
    "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
    "",
  },

  buttons = {
    header "Project",
    btn("Artisan command", "<leader>la", L .. "('artisan')"),
    btn("Routes", "<leader>lr", L .. "('routes')"),
    btn("Related files", "<leader>lm", L .. "('related')"),
    btn("Make generators", "<leader>ln", L .. "('make')"),
    btn("Tinker", "<leader>lt", "botright split | resize 15 | terminal php artisan tinker"),
    btn("Goto from Debugbar", "<leader>lg", "lua require('configs.laravel_nav').debugbar_picker()"),

    sep,
    header "Find",
    btn("Views", "<leader>flv", FIND .. "('resources/views','Views')"),
    btn("Controllers", "<leader>flc", FIND .. "('app/Http/Controllers','Controllers')"),
    btn("Models", "<leader>flm", FIND .. "('app/Models','Models')"),
    btn("Migrations", "<leader>flM", FIND .. "('database/migrations','Migrations')"),
    btn("Route files", "<leader>flr", FIND .. "('routes','Routes')"),
    note "… and more under <leader>fl",

    sep,
    header "Debug",
    btn("Continue / start", "<leader>dc", DAP .. ".continue()"),
    btn("Toggle breakpoint", "<leader>db", DAP .. ".toggle_breakpoint()"),
    btn("Step into", "<leader>di", DAP .. ".step_into()"),
    btn("Toggle debug UI", "<leader>du", "lua require('lazy').load({plugins={'nvim-dap'}}) require('dapui').toggle()"),

    sep,
    header "Files & Git",
    btn("Find file", "<leader>ff", "Telescope find_files"),
    btn("Live grep", "<leader>fw", "Telescope live_grep"),
    btn("Recent files", "<leader>fo", "Telescope oldfiles"),
    btn("Git uncommitted", "<leader>gu", "lua require('configs.laravel_nav').git_picker()"),
    btn("Git status", "<leader>gt", "Telescope git_status"),
    btn("Git commits", "<leader>cm", "Telescope git_commits"),

    sep,
    header "Editor",
    btn("File tree", "<C-n>", "NvimTreeToggle"),
    btn("Themes", "<leader>th", "lua require('nvchad.themes').open()"),
    btn("Toggle line numbers", "<leader>n", "set nu!"),
    btn("Format file", "<leader>fm", "lua require('conform').format({ lsp_fallback = true })"),
    btn("Marks", "<leader>ma", "Telescope marks"),

    sep,
    header "System",
    btn("New buffer", "<leader>b", "enew"),
    btn("Command cheatsheet", "<leader>?", "lua require('configs.cheatsheet').open()"),
    btn("Search all mappings", "<leader>wk", "WhichKey"),
    run("Plugins  (Lazy)", "Lazy"),
    run("LSP / tools  (Mason)", "Mason"),

    sep,
    {
      txt = function()
        local stats = require("lazy").stats()
        return "  Loaded "
          .. stats.loaded
          .. "/"
          .. stats.count
          .. " plugins in "
          .. math.floor(stats.startuptime)
          .. " ms"
      end,
      hl = "NvDashFooter",
      no_gap = true,
      content = "fit",
    },
  },
}
