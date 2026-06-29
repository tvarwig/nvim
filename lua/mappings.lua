require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jk", "<ESC>")

-- Laravel category finders (<leader>fl…) + Debugbar goto (<leader>lg)
local lnav = function()
  return require "configs.laravel_nav"
end

-- stylua: ignore start
map("n", "<leader>flv", function() lnav().find_in("resources/views", "Views") end,            { desc = "Find views" })
map("n", "<leader>flc", function() lnav().find_in("app/Http/Controllers", "Controllers") end, { desc = "Find controllers" })
map("n", "<leader>flm", function() lnav().find_in("app/Models", "Models") end,                { desc = "Find models" })
map("n", "<leader>flM", function() lnav().find_in("database/migrations", "Migrations") end,    { desc = "Find migrations" })
map("n", "<leader>flr", function() lnav().find_in("routes", "Routes") end,                     { desc = "Find routes" })
map("n", "<leader>flR", function() lnav().find_in("app/Http/Requests", "Form Requests") end,   { desc = "Find form requests" })
map("n", "<leader>flj", function() lnav().find_in("app/Jobs", "Jobs") end,                     { desc = "Find jobs" })
map("n", "<leader>flf", function() lnav().find_in("database/factories", "Factories") end,      { desc = "Find factories" })
map("n", "<leader>fls", function() lnav().find_in("database/seeders", "Seeders") end,          { desc = "Find seeders" })
map("n", "<leader>flp", function() lnav().find_in("resources/views/components", "Components") end, { desc = "Find blade components" })
map("n", "<leader>flt", function() lnav().find_in("tests", "Tests") end,                       { desc = "Find tests" })
map("n", "<leader>lg",  function() lnav().debugbar_picker() end,                               { desc = "Debugbar goto (latest request)" })
map("n", "<leader>lG",  function() lnav().goto_prompt() end,                                   { desc = "Goto view/controller (paste)" })
-- stylua: ignore end

-- Helper popup listing the curated Laravel / Debug / Navigation commands
map("n", "<leader>?", function()
  require("configs.cheatsheet").open()
end, { desc = "Command cheatsheet" })

-- Label the leader groups in which-key (loads lazily, so guard it)
vim.schedule(function()
  local ok, wk = pcall(require, "which-key")
  if ok then
    wk.add {
      { "<leader>l", group = "Laravel" },
      { "<leader>d", group = "Debug" },
      { "<leader>fl", group = "Find Laravel" },
    }
  end
end)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
