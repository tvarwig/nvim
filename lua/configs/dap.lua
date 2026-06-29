-- PHP / Laravel step-debugging via nvim-dap + the vscode-php-debug adapter
-- (mason package "php-debug-adapter"), wired for Laravel Herd's Xdebug 3.
local M = {}

-- Resolve the adapter entrypoint from mason, surviving version/layout bumps.
local function php_debug_path()
  local ok, registry = pcall(require, "mason-registry")
  if ok and registry.is_installed "php-debug-adapter" then
    local pkg = registry.get_package "php-debug-adapter"
    local base = pkg.get_install_path and pkg:get_install_path()
      or (vim.fn.stdpath "data" .. "/mason/packages/php-debug-adapter")
    return base .. "/extension/out/phpDebug.js"
  end
  return vim.fn.stdpath "data" .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js"
end

-- base46 ships a dap integration but doesn't compile it by default here, so set
-- theme-aware fallbacks. default = true → base46's own groups win if present.
local function define_highlights()
  local set = function(name, opts)
    opts.default = true
    vim.api.nvim_set_hl(0, name, opts)
  end
  set("DapBreakpoint", { link = "DiagnosticError" })
  set("DapBreakpointCondition", { link = "DiagnosticWarn" })
  set("DapLogPoint", { link = "DiagnosticInfo" })
  set("DapStopped", { link = "DiagnosticOk" })
  set("DapStoppedLine", { link = "Visual" })
  pcall(dofile, vim.g.base46_cache .. "dap")
end

function M.setup()
  local dap = require "dap"
  local dapui = require "dapui"

  define_highlights()
  dapui.setup()
  require("nvim-dap-virtual-text").setup {}

  -- Open/close the debugger UI automatically with the session.
  dap.listeners.before.attach.dapui_config = function() dapui.open() end
  dap.listeners.before.launch.dapui_config = function() dapui.open() end
  dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
  dap.listeners.before.event_exited.dapui_config = function() dapui.close() end

  vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DapBreakpointCondition" })
  vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DapLogPoint" })
  vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine" })

  -- The adapter is a Node program; resolve node absolutely (Herd's nvm node may
  -- not be on a minimal PATH when nvim spawns the job).
  local node = vim.fn.exepath "node"
  dap.adapters.php = {
    type = "executable",
    command = node ~= "" and node or "node",
    args = { php_debug_path() },
  }

  local herd_php = vim.fn.expand "~/Library/Application Support/Herd/bin/php"
  local herd_debug_ini = vim.fn.expand "~/Library/Application Support/Herd/config/php/84/debug/debug.ini"

  dap.configurations.php = {
    -- 95% case: listen for Xdebug from web requests, queue workers, artisan, tinker.
    -- vscode-php-debug uses request="launch" even when only listening (no "attach").
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug (Herd)",
      port = 9003, -- Xdebug 3 default; Herd's debug.ini sets no custom port
    },
    -- Step-debug a standalone PHP script using Herd's debug-enabled php binary.
    {
      type = "php",
      request = "launch",
      name = "Launch current script (Herd php)",
      program = "${file}",
      cwd = "${fileDirname}",
      port = 9003,
      runtimeExecutable = herd_php,
      runtimeArgs = { "-c", herd_debug_ini },
      -- stopOnEntry = true, -- uncomment to break on the first line
    },
  }
end

return M
