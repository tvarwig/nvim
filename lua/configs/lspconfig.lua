require("nvchad.configs.lspconfig").defaults()

-- Vue 3 hybrid mode: ts_ls handles <script> via @vue/typescript-plugin, vue_ls
-- handles the SFC template. The plugin ships inside the Mason vue server.
local vue_ls_path = vim.fn.stdpath "data"
  .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"

vim.lsp.config("ts_ls", {
  init_options = {
    plugins = {
      { name = "@vue/typescript-plugin", location = vue_ls_path, languages = { "vue" } },
    },
  },
  -- Setting filetypes REPLACES the default list, so relist js/ts/react + add vue.
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "vue",
  },
})

-- vue_ls (Volar 3.x) already forwards tsserver requests to ts_ls via its bundled
-- on_init, so no extra config is needed here.
vim.lsp.config("vue_ls", {})

local servers = {
  "html",
  "cssls",
  "intelephense", -- PHP / Laravel
  "ts_ls",        -- TS / JS / React (jsx, tsx) + Vue <script>
  "vue_ls",       -- Vue 3 SFC template (replaces deprecated "volar")
  "svelte",       -- Svelte
}

vim.lsp.enable(servers)

-- Treat .blade.php (and Livewire v4 single-file component extensions) as blade.
vim.filetype.add {
  pattern = {
    [".*%.blade%.php"] = "blade",
    [".*%.wire%.php"] = "blade", -- Livewire v4 SFC (beta extension)
    [".*%.livewire%.php"] = "blade",
  },
}

local M = {}

-- Choose a single jump target from LSP definition results.
-- intelephense returns BOTH the class declaration and the constructor for
-- `new Foo()`, which makes plain `gd` open a quickfix list of the same file.
-- When every result is in one file we collapse to a single jump (preferring the
-- type declaration); only genuinely multi-file results fall back to a list.
-- Returns the target item, or nil to mean "let the caller show the list".
function M.resolve(items)
  if not items or #items == 0 then
    return nil
  end

  local files = {}
  for _, it in ipairs(items) do
    files[it.filename] = true
  end

  if #items == 1 or vim.tbl_count(files) == 1 then
    for _, it in ipairs(items) do
      local t = it.text or ""
      if t:find "%f[%a]class%f[%A]"
        or t:find "%f[%a]interface%f[%A]"
        or t:find "%f[%a]trait%f[%A]"
        or t:find "%f[%a]enum%f[%A]"
      then
        return it
      end
    end
    return items[1]
  end

  return nil -- multiple files: ambiguous, show the picker
end

local function smart_definition()
  vim.lsp.buf.definition {
    on_list = function(result)
      local items = result.items or {}
      if #items == 0 then
        return
      end

      local target = M.resolve(items)
      if target then
        vim.cmd "normal! m'" -- record origin so <C-o> jumps back
        local cur = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p")
        if vim.fn.fnamemodify(target.filename, ":p") ~= cur then
          vim.cmd("edit " .. vim.fn.fnameescape(target.filename))
        end
        vim.api.nvim_win_set_cursor(0, { target.lnum, math.max(0, (target.col or 1) - 1) })
        vim.cmd "normal! zz"
      else
        -- Genuinely ambiguous (multiple files): let the user pick from a
        -- Telescope list — like find-files — instead of a raw quickfix window.
        local pickers = require "telescope.pickers"
        local finders = require "telescope.finders"
        local conf = require("telescope.config").values
        local make_entry = require "telescope.make_entry"
        pickers
          .new({}, {
            prompt_title = "Definitions",
            finder = finders.new_table {
              results = items,
              entry_maker = make_entry.gen_from_quickfix {},
            },
            sorter = conf.generic_sorter {},
            previewer = conf.qflist_previewer {},
          })
          :find()
      end
    end,
  }
end

-- Override NvChad's gd (its LspAttach autocmd runs first, so this wins).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "gd", smart_definition, { buffer = args.buf, desc = "LSP go to definition" })
  end,
})

-- read :h vim.lsp.config for changing options of lsp servers
return M
