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
        "php", "phpdoc", "blade",
        "javascript", "typescript", "tsx", "vue", "svelte",
        "markdown", "markdown_inline",
        "json", "yaml",
      },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    },
    config = function(_, opts)
      -- Register the community Blade parser (not in the default registry).
      -- Highlight/injection queries already ship with nvim-treesitter.
      local parsers = require "nvim-treesitter.parsers"
      local configs = parsers.get_parser_configs and parsers.get_parser_configs() or parsers
      configs.blade = {
        install_info = {
          url = "https://github.com/EmranMR/tree-sitter-blade",
          files = { "src/parser.c" },
          branch = "main",
        },
        filetype = "blade",
      }
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
  },

  -- Auto-installs the LSPs/formatters below. Must NOT be lazy: the plugin
  -- registers its install-on-start hook from its plugin/ file at load time,
  -- so it has to load during startup (before VimEnter) to actually fire.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    lazy = false,
    opts = {
      ensure_installed = {
        "intelephense",
        "typescript-language-server",
        "vue-language-server",
        "pint",
        "php-cs-fixer",
        "blade-formatter",
        "prettierd",
        "php-debug-adapter",
        "svelte-language-server",
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
      { "<leader>la", function() Laravel.pickers.artisan() end,  desc = "Laravel artisan (popup)" },
      { "<leader>lr", function() Laravel.pickers.routes() end,   desc = "Laravel routes" },
      { "<leader>lm", function() Laravel.pickers.related() end,  desc = "Laravel related files" },
      { "<leader>ln", function() Laravel.pickers.make() end,     desc = "Laravel make:*" },
      { "<leader>lc", function() Laravel.pickers.composer() end, desc = "Laravel composer" },
      { "<leader>lh", function() Laravel.pickers.history() end,  desc = "Laravel command history" },
      { "<leader>lR", function() Laravel.pickers.resources() end, desc = "Laravel resources" },
      {
        "<leader>lt",
        function() vim.cmd "botright split | resize 15 | terminal php artisan tinker" end,
        desc = "Laravel tinker",
      },
    },
  },

  -- `gf` navigation between Blade views, components, route/config helpers,
  -- and Livewire components. Also adds a cmp source for view/route names.
  {
    "ricardoramirezr/blade-nav.nvim",
    dependencies = { "hrsh7th/nvim-cmp", "nvim-treesitter/nvim-treesitter" },
    ft = { "blade", "php" },
    opts = { close_tag_on_complete = true },
    config = function(_, opts)
      -- blade-nav parses a `php` treesitter query at load time; make sure the
      -- php language is registered first or setup() errors on some load orders.
      pcall(vim.treesitter.language.add, "php")
      require("blade-nav").setup(opts)
    end,
  },

  -- Blade indent + commentstring (`{{-- --}}`). Highlighting comes from the
  -- treesitter parser above; nvim-treesitter disables the regex syntax.
  {
    "jwalton512/vim-blade",
    ft = "blade",
  },

  -- Step debugging (PHP/Xdebug via Herd). See lua/configs/dap.lua.
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input "Condition: ") end, desc = "DAP conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "DAP continue / start" },
      { "<leader>di", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "DAP step out" },
      { "<leader>dr", function() require("dap").repl.toggle() end, desc = "DAP REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "DAP run last" },
      { "<leader>dx", function() require("dap").terminate() end, desc = "DAP terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "DAP toggle UI" },
      { "<leader>de", function() require("dapui").eval(nil, { enter = true }) end, mode = { "n", "v" }, desc = "DAP eval" },
      { "<F5>", function() require("dap").continue() end, desc = "DAP continue" },
      { "<F9>", function() require("dap").toggle_breakpoint() end, desc = "DAP breakpoint" },
      { "<F10>", function() require("dap").step_over() end, desc = "DAP step over" },
      { "<F11>", function() require("dap").step_into() end, desc = "DAP step into" },
      { "<F12>", function() require("dap").step_out() end, desc = "DAP step out" },
    },
    config = function()
      require("configs.dap").setup()
    end,
  },
}
