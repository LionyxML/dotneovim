# Lionyx Neovim Config

My personal Neovim configuration. This is in constant change — things break,
get rewritten, or disappear without notice.

Single-file config using the built-in `vim.pack` package manager (Neovim
0.12+). Plugins load eagerly via `vim.pack.add()`, with a custom `later()`
helper that defers setup after the first screen draw — our own lazy loading, no
external plugin manager needed.

## Features

- **mini.nvim everywhere** — statusline, diff/git gutter, file explorer, picker
  (fuzzy finder), surround, indent scope, icons, notifications, clue
  (which-key), and highlight patterns
- **LSP + Mason** — auto-installed language servers for Lua, TypeScript,
  Python, Go, Rust, Ruby, and more
- **Autocompletion** — nvim-cmp with LSP, snippets (LuaSnip +
  friendly-snippets), path, and cmdline sources
- **Treesitter** — syntax highlighting, context, rainbow delimiters, autotag,
  and textobjects
- **Formatting** — conform.nvim with format-on-save (Prettier, Stylua, Ruff,
  gofmt, etc.)
- **Git** — mini.diff for gutter signs, diffview.nvim for side-by-side diffs,
  gitlineage for line history, and a custom `git annotate` with scrollbind
- **Catppuccin Mocha** — the one and only theme, with transparent background
- **Oil.nvim** — dired-like file manager alongside mini.files
- **Tmux integration** — seamless pane navigation with `C-h/j/k/l`
- **Custom tabline** — pill-style tab indicators
- **GPG encryption** — transparent read/write of `.gpg` files
- **Extras** — orgmode, yanky (yank history with sqlite), undotree, spectre
  (search & replace), ccc (color picker), image.nvim, cloak (hide secrets in
  `.env`), Codeium AI completion, 0x0.st paste
