local util = require "conform.util"

local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    php = { "pint", "php_cs_fixer", stop_after_first = true },
    blade = { "blade-formatter" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    vue = { "prettierd", "prettier", stop_after_first = true },
    -- svelte: no prettierd entry — prettier needs prettier-plugin-svelte, so
    -- formatting falls back to the Svelte LSP (svelte-language-server).
    css = { "prettierd", "prettier", stop_after_first = true },
    html = { "prettierd", "prettier", stop_after_first = true },
    json = { "prettierd", "prettier", stop_after_first = true },
    markdown = { "prettierd", "prettier", stop_after_first = true },
  },

  formatters = {
    -- Prefer the project's pint, then a mason/global pint.
    pint = {
      command = util.find_executable(
        { "vendor/bin/pint", vim.fn.stdpath "data" .. "/mason/bin/pint" },
        "pint"
      ),
    },
  },

  -- format_on_save = {
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return options
