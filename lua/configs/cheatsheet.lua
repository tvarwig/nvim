-- Self-contained floating cheatsheet of the curated Laravel / Debug / Nav
-- commands. No deps beyond Neovim core. Open with require("configs.cheatsheet").open()
local M = {}

-- Each section: { title, { { keys, desc }, ... } }
local SECTIONS = {
  {
    "Laravel  (<leader>l)",
    {
      { "<leader>la", "Artisan command (popup + args)" },
      { "<leader>lr", "Routes" },
      { "<leader>lm", "Related files (controller↔view↔model)" },
      { "<leader>ln", "make:* generators" },
      { "<leader>lc", "Composer" },
      { "<leader>lh", "Command history (re-run)" },
      { "<leader>lR", "Resources" },
      { "<leader>lt", "Tinker (terminal)" },
      { "<leader>ld", "Debugbar goto — pick latest request's controller/views" },
      { "<leader>lG", "Goto from pasted string (view / Controller@method)" },
    },
  },
  {
    "Find Laravel  (<leader>fl)",
    {
      { "<leader>flv", "Views" },
      { "<leader>flc", "Controllers" },
      { "<leader>flm", "Models" },
      { "<leader>flM", "Migrations" },
      { "<leader>flr", "Routes" },
      { "<leader>flR", "Form requests" },
      { "<leader>flj / flf / fls", "Jobs / Factories / Seeders" },
      { "<leader>flp / flt", "Components / Tests" },
    },
  },
  {
    "Git  (<leader>g)",
    {
      { "<leader>gu", "Uncommitted files — pick + jump to change" },
      { "<leader>gt", "Git status (Telescope)" },
      { "<leader>cm", "Git commits" },
    },
  },
  {
    "Debug  (<leader>d  /  F-keys)",
    {
      { "<leader>db / <F9>", "Toggle breakpoint" },
      { "<leader>dB", "Conditional breakpoint" },
      { "<leader>dc / <F5>", "Continue / start session" },
      { "<leader>di / <F11>", "Step into" },
      { "<leader>do / <F10>", "Step over" },
      { "<leader>dO / <F12>", "Step out" },
      { "<leader>dr", "Toggle REPL" },
      { "<leader>dl", "Run last" },
      { "<leader>de", "Eval expression (n/v)" },
      { "<leader>du", "Toggle debugger UI" },
      { "<leader>dx", "Terminate" },
    },
  },
  {
    "Xdebug workflow (Herd)",
    {
      { "1.", "Set a breakpoint (<leader>db)" },
      { "2.", "<leader>dc → \"Listen for Xdebug (Herd)\"" },
      { "3.", "Load the page, or run: herd debug artisan …" },
    },
  },
  {
    "Navigation & Search",
    {
      { "gd", "Go to definition" },
      { "gr", "References" },
      { "K", "Hover docs" },
      { "gf", "Goto view/component/route (blade-nav)" },
      { "<leader>ff", "Find files" },
      { "<leader>fw", "Live grep" },
      { "<leader>fb", "Buffers" },
      { "<leader>wk", "Which-key: search all mappings" },
      { "<leader>?", "This cheatsheet" },
    },
  },
}

local ns = vim.api.nvim_create_namespace "cheatsheet"

local function add_hl(buf, group, line, col_start, col_end)
  if vim.hl and vim.hl.range then
    vim.hl.range(buf, ns, group, { line, col_start }, { line, col_end == -1 and 9999 or col_end })
  else
    vim.api.nvim_buf_add_highlight(buf, ns, group, line, col_start, col_end)
  end
end

local function ensure_hl()
  vim.api.nvim_set_hl(0, "CheatHeader", { link = "Title", default = true })
  vim.api.nvim_set_hl(0, "CheatKey", { link = "String", default = true })
  vim.api.nvim_set_hl(0, "CheatDesc", { link = "Comment", default = true })
end

function M.open()
  -- Toggle: pressing the key again closes it instead of stacking another popup.
  if M._win and vim.api.nvim_win_is_valid(M._win) then
    vim.api.nvim_win_close(M._win, true)
    M._win = nil
    return
  end
  ensure_hl()

  local key_w = 8
  for _, sec in ipairs(SECTIONS) do
    for _, row in ipairs(sec[2]) do
      key_w = math.max(key_w, #row[1])
    end
  end

  local lines, marks = {}, {}
  for si, sec in ipairs(SECTIONS) do
    if si > 1 then
      table.insert(lines, "")
    end
    table.insert(lines, "  " .. sec[1])
    marks[#lines] = { group = "CheatHeader", from = 0, to = -1 }
    for _, row in ipairs(sec[2]) do
      local key, pad = row[1], string.rep(" ", key_w - #row[1])
      table.insert(lines, string.format("    %s%s  %s", key, pad, row[2]))
      local kstart, kend = 4, 4 + #key
      marks[#lines] = {
        { group = "CheatKey", from = kstart, to = kend },
        { group = "CheatDesc", from = kend + #pad + 2, to = -1 },
      }
    end
  end

  local content_w = 0
  for _, l in ipairs(lines) do
    content_w = math.max(content_w, vim.fn.strdisplaywidth(l))
  end
  -- Never exceed the screen (handles very narrow/short terminals gracefully).
  local width = math.max(1, math.min(content_w + 2, vim.o.columns - 2))
  local height = math.max(1, math.min(#lines, vim.o.lines - 2))

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  for lnum1, m in pairs(marks) do
    local l = lnum1 - 1
    if m.group then
      add_hl(buf, m.group, l, m.from, m.to)
    else
      for _, part in ipairs(m) do
        add_hl(buf, part.group, l, part.from, part.to)
      end
    end
  end
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].filetype = "cheatsheet"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.max(0, math.floor((vim.o.lines - height) / 2 - 1)),
    col = math.max(0, math.floor((vim.o.columns - width) / 2)),
    style = "minimal",
    border = "rounded",
    title = " Commands ",
    title_pos = "center",
    footer = " q / <Esc> to close ",
    footer_pos = "right",
    noautocmd = true,
  })
  vim.wo[win].cursorline = true
  M._win = win

  local function close()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
    M._win = nil
  end
  for _, key in ipairs { "q", "<Esc>" } do
    vim.keymap.set("n", key, close, { buffer = buf, nowait = true, silent = true })
  end
  vim.api.nvim_create_autocmd("WinLeave", { buffer = buf, once = true, callback = close })
end

return M
