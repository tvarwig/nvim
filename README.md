# nvim config

Neovim config based on [NvChad v2.5](https://nvchad.com). `<leader>` = `<space>`.

## Install

### Requirements
- Neovim **0.11+**
- `git`, `node`/`npm`, a Nerd Font, `ripgrep` (for Telescope live grep)

### Clone the config
```sh
git clone https://github.com/tvarwig/nvim ~/.config/nvim
```
On first launch, lazy.nvim bootstraps and installs plugins automatically. Treesitter parsers listed in [lua/plugins/init.lua](lua/plugins/init.lua) install on demand.

### Language servers
These are configured in [lua/configs/lspconfig.lua](lua/configs/lspconfig.lua). Install each one globally via npm so it's on your `$PATH`:

```sh
# PHP / Laravel
npm i -g intelephense

# JavaScript / TypeScript (server needs the `typescript` package too)
npm i -g typescript
npm i -g typescript-language-server

# Vue 3
npm i -g @vue/language-server

# HTML / CSS / JSON
npm i -g vscode-langservers-extracted
```

| Server | Filetypes | npm package |
|--------|-----------|-------------|
| `intelephense` | PHP / Laravel | `intelephense` |
| `ts_ls` | JS / TS | `typescript-language-server` (+ `typescript`) |
| `volar` | Vue 3 | `@vue/language-server` |
| `html`, `cssls` | HTML / CSS | `vscode-langservers-extracted` |

After installing, restart Neovim and run `:checkhealth vim.lsp` on a file of the relevant type to verify the server attached.

### Formatters
Used by `conform.nvim` (see [lua/configs/conform.lua](lua/configs/conform.lua)). Install only what you need:

```sh
# JS / TS / Vue / CSS / HTML / JSON
npm install -g @fsouza/prettierd prettier

# Blade
npm install -g blade-formatter

# Lua
brew install stylua

# PHP — pint ships with Laravel projects; php-cs-fixer is the fallback
composer global require friendsofphp/php-cs-fixer
```

### Optional: Mason
`:Mason` is available for LSP/formatter installs as an alternative to the npm/brew path above. The `mason-tool-installer` plugin is wired in [lua/plugins/init.lua](lua/plugins/init.lua) but currently does not auto-install on startup — use `:MasonToolsInstall` manually, or install via the `:Mason` UI.

## Custom Mappings

| Key | Mode | Action |
|-----|------|--------|
| `;` | normal | `:` (command mode) |
| `jk` | insert | Escape |

## Leader Key Reference

### Telescope (searching)
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fa` | Find all files (incl. hidden/ignored) |
| `<leader>fw` | Live grep (search in files) |
| `<leader>fb` | Find buffers |
| `<leader>fh` | Help tags |
| `<leader>fo` | Recent files |
| `<leader>fz` | Fuzzy find in current buffer |
| `<leader>ma` | Marks |
| `<leader>cm` | Git commits |
| `<leader>gt` | Git status |
| `<leader>pt` | Pick terminal |

### LSP
| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `<leader>D` | Go to type definition |
| `<leader>ra` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>wa` | Add workspace folder |
| `<leader>wr` | Remove workspace folder |
| `<leader>wl` | List workspace folders |
| `<leader>ds` | Diagnostic loclist |
| `<leader>fm` | Format buffer |
| `<leader>sh` | Signature help |

### Laravel
| Key | Action |
|-----|--------|
| `<leader>la` | Laravel artisan |
| `<leader>lr` | Laravel routes |
| `<leader>lm` | Laravel related files |

### Buffers & Tabs
| Key | Action |
|-----|--------|
| `<leader>b` | New buffer |
| `<leader>x` | Close buffer |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Prev buffer |

### Toggles
| Key | Action |
|-----|--------|
| `<leader>n` | Toggle line numbers |
| `<leader>rn` | Toggle relative numbers |
| `<leader>ch` | Cheatsheet |
| `<leader>th` | Switch theme |
| `<leader>e` | Focus file tree |
| `<C-n>` | Toggle file tree |
| `<leader>/` | Toggle comment (line) |

### Terminal
| Key | Action |
|-----|--------|
| `<leader>h` | New horizontal terminal |
| `<leader>v` | New vertical terminal |
| `<A-h>` | Toggle horizontal terminal |
| `<A-v>` | Toggle vertical terminal |
| `<A-i>` | Toggle floating terminal |
| `<C-x>` (terminal mode) | Escape terminal |

### Misc
| Key | Action |
|-----|--------|
| `<leader>wK` | Show all keymaps (WhichKey) |
| `<leader>wk` | WhichKey query |
| `<Esc>` | Clear search highlights |
| `<C-s>` | Save file |
| `<C-c>` | Copy entire file |

## Insert Mode Navigation
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Move left/down/up/right |
| `<C-b>` | Move to line start |
| `<C-e>` | Move to line end |

## Window Navigation
| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Switch window left/down/up/right |

## Completion Menu
| Key | Action |
|-----|--------|
| `<C-p/n>` | Select prev/next |
| `<C-d/f>` | Scroll docs |
| `<C-Space>` | Trigger completion |
| `<C-e>` | Close menu |
| `<CR>` | Confirm selection |
| `<Tab>` | Next / expand snippet |
| `<S-Tab>` | Prev / jump back |

## Commands
| Command | Action |
|---------|--------|
| `:NvCheatsheet` | Open cheatsheet |
| `:Nvdash` | Toggle dashboard |
| `:NvimTreeToggle` / `:NvimTreeFocus` | File tree |
| `:Mason` | LSP installer UI |
| `:MasonInstallAll` | Install configured LSPs |
| `:Telescope` | Telescope picker |
| `:Laravel` | Laravel tools |
| `:WhichKey` | Keymap explorer |
| `:TSInstall` | Install treesitter parser |
| `:Huefy` / `:Shades` | Color picker |

## Filetype Detection
- `.blade.php` files are detected as `blade` filetype

## Formatting by Filetype
| Filetype | Formatter |
|----------|-----------|
| Lua | `stylua` |
| PHP | `pint` or `php_cs_fixer` |
| Blade | `blade-formatter` |
| JS / TS / Vue / CSS / HTML / JSON | `prettierd` or `prettier` |
