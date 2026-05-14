return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    opts = {
      auto_install = true,
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css",
        "php", "phpdoc",
        "javascript", "typescript", "tsx", "vue",
        "json", "yaml",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },

  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      ensure_installed = {
        "intelephense",
        "typescript-language-server",
        "vue-language-server",
        "pint",
        "blade-formatter",
        "prettierd",
      },
      auto_update = false,
      run_on_start = true,
    },
  },

  {
    "adalessa/laravel.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "tpope/vim-dotenv",
      "MunifTanjim/nui.nvim",
      "kevinhwang91/promise-async",
      "nvim-neotest/nvim-nio",
    },
    event = { "VeryLazy" },
    opts = {
      lsp_server = "intelephense",
      features = { null_ls = { enable = false } },
    },
    keys = {
      { "<leader>la", function() Laravel.pickers.artisan() end, desc = "Laravel artisan" },
      { "<leader>lr", function() Laravel.pickers.routes() end,  desc = "Laravel routes" },
      { "<leader>lm", function() Laravel.pickers.related() end, desc = "Laravel related" },
    },
  },

  -- Blade syntax highlighting (pairs with blade TS parser)
  {
    "jwalton512/vim-blade",
    ft = "blade",
  },
}
