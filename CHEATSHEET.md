# Laravel Neovim — Command Reference

**Leader key = `Space`** · NvChad + laravel.nvim + nvim-dap
Open `nvim` with no file for the splash screen · press `<leader>?` anytime for the popup.

## Code Navigation (LSP)

| Key | Action |
| --- | --- |
| `gd` | Go to definition (smart — skips duplicate class/constructor) |
| `gD` | Go to declaration |
| `gf` | Go to Blade view / component / route under cursor |
| `K` | Hover documentation |
| `grr` | Find references |
| `gri` | Go to implementations |
| `grn` | Rename symbol |
| `gra` | Code action |
| `gO` | Document symbols |
| `<leader>D` | Type definition |
| `<leader>ra` | Rename (NvChad UI) |
| `<C-s>` (insert) | Signature help |

## Laravel (`<leader>l`)

| Key | Action |
| --- | --- |
| `<leader>la` | Artisan command (popup + args) |
| `<leader>lr` | Routes |
| `<leader>lm` | Related files (model ↔ controller ↔ view) |
| `<leader>ln` | make:* generators |
| `<leader>lc` | Composer |
| `<leader>lh` | Command history (re-run) |
| `<leader>lR` | Resources |
| `<leader>lt` | Tinker (terminal) |
| `<leader>ld` | Debugbar picker — latest request's controller + views |
| `<leader>lG` | Goto from pasted string (view / Controller@method) |

## Find Laravel Files (`<leader>fl`)

| Key | Action | | Key | Action |
| --- | --- | --- | --- | --- |
| `<leader>flv` | Views | | `<leader>flf` | Factories |
| `<leader>flc` | Controllers | | `<leader>fls` | Seeders |
| `<leader>flm` | Models | | `<leader>flp` | Blade components |
| `<leader>flM` | Migrations | | `<leader>flt` | Tests |
| `<leader>flr` | Route files | | `<leader>flR` | Form requests |
| `<leader>flj` | Jobs | | | |

## Git (`<leader>g`)

| Key | Action |
| --- | --- |
| `<leader>gu` | Uncommitted files — pick + jump to first change |
| `<leader>gt` | Git status (Telescope) |
| `<leader>cm` | Git commits |

## Debugging (`<leader>d` / function keys)

| Key | Action |
| --- | --- |
| `<leader>dc` / `F5` | Continue / start session |
| `<leader>db` / `F9` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>di` / `F11` | Step into |
| `<leader>do` / `F10` | Step over |
| `<leader>dO` / `F12` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>de` | Evaluate expression (normal / visual) |
| `<leader>du` | Toggle debugger UI |
| `<leader>dx` | Terminate |

## Files & Search

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep |
| `<leader>fb` | Open buffers |
| `<leader>fo` | Recent files |
| `<leader>fa` | Find all files (incl. hidden) |
| `<leader>fz` | Fuzzy find in current buffer |
| `<leader>fh` | Help tags |
| `<C-n>` | Toggle file tree |
| `<leader>fm` | Format buffer (Pint / Blade / Prettier) |
| `<leader>?` | Command cheatsheet popup |
| `<leader>wk` | Which-key: search all mappings |
| `jk` (insert) | Escape |

## Xdebug Workflow (Herd)

Xdebug 3 on port **9003** — Herd ships it, no install needed.

1. Set a breakpoint — `<leader>db`
2. Start the listener — `<leader>dc` → **"Listen for Xdebug (Herd)"**
3. Trigger it — load the page in the browser, **or** run a CLI command under Xdebug:
   `herd debug artisan queue:work` · `herd debug artisan tinker`

## Debugbar Navigation

Laravel Debugbar persists each request to `storage/debugbar/`. Two ways to jump from it:

**`<leader>ld` — picker.** Reads the **latest** request and lists its controller (from the request collector) plus every rendered Blade view. Pick one to jump — the controller opens on its method, views open at the file. Debugbar's grouping count prefix (`11x portal.projects.show`) is stripped automatically, and paths come from Debugbar's own `xdebug_link` so they resolve even for components in non-standard locations.

**`<leader>lG` — paste.** Copy any Debugbar string and press it (the prompt pre-fills from your clipboard):

| Pasted value | Opens |
| --- | --- |
| `portal.projects.show` | `resources/views/portal/projects/show.blade.php` |
| `App\Http\Controllers\Portal\ProjectController@show` | the controller, cursor on `show()` |

## Git "Uncommitted" (`<leader>gu`)

Lists everything `git status` reports — staged, unstaged, and untracked. Pick a file to open it; the cursor lands on the first changed hunk (new/untracked files open at the top).
