require("nvchad.configs.lspconfig").defaults()

local servers = {
  "html",
  "cssls",
  "intelephense", -- PHP / Laravel
  "ts_ls",        -- TypeScript / JavaScript
  "volar",        -- Vue 3
}

vim.lsp.enable(servers)

-- Treat .blade.php files as blade for filetype-specific tooling
vim.filetype.add {
  pattern = { [".*%.blade%.php"] = "blade" },
}

-- read :h vim.lsp.config for changing options of lsp servers
