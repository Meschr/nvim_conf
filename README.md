# nvim_conf

My Neovim config, managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Prerequisites

| Tool | Why |
| --- | --- |
| [bob](https://github.com/MordechaiHadad/bob) + **Neovim ≥ 0.11** (stable) | Neovim version manager; plugins (mason-lspconfig, lspconfig) require 0.11+ |
| git, curl, unzip, tar, gzip | lazy.nvim / mason downloads |
| gcc / make (`build-essential` / `base-devel`) | telescope-fzf-native, LuaSnip jsregexp, treesitter parsers |
| [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter) | compiling parsers for nvim-treesitter (main branch) |
| ripgrep, fd | telescope live grep / file search |
| node + npm | LSP servers like pyright, prettier |
| python3 + venv | Python-based mason packages |
| [lazygit](https://github.com/jesseduffield/lazygit) | lazygit.nvim |
| [delta](https://github.com/dandavison/delta) | nicer diffs in lazygit (config written to `~/.config/lazygit/config.yml`) |
| xclip (X11) or wl-clipboard (Wayland) | system clipboard |
| **MesloLGS Nerd Font** set as terminal font | icons in nvim-tree, lualine, bufferline, … |

## Automatic setup

On Ubuntu/Debian or Arch:

```bash
git clone git@github.com:<username>/nvim_conf.git ~/.config/nvim
~/.config/nvim/setup.sh
```

The script installs the packages above, bob + Neovim stable, lazygit + delta, the tree-sitter CLI and
the MesloLGS Nerd Font, puts bob's `nvim-bin` on your `PATH` and syncs the plugins.
It can be re-run safely. Use another Neovim version with `NVIM_VERSION=v0.11.4 ./setup.sh`.

Afterwards:
1. Restart the shell.
2. Set your terminal font to **MesloLGS Nerd Font**
   (GNOME Terminal: Preferences → Profile → Custom font;
   VS Code: `"terminal.integrated.fontFamily": "MesloLGS Nerd Font"`).
3. Start `nvim` and run `:checkhealth`.

## Manual setup notes

### bob / Neovim

```bash
bob use stable
```

Put bob's shim directory on your `PATH` — **not** a specific version directory
(e.g. `~/.local/share/bob/v0.10.4/bin`), otherwise `bob use` has no effect:

```bash
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
```

### MesloLGS Nerd Font

```bash
mkdir -p ~/.local/share/fonts/Meslo
curl -LO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz
tar -xf Meslo.tar.xz -C ~/.local/share/fonts/Meslo
fc-cache -f
```

## SSH key for pushing

```bash
git remote set-url origin git@github.com:<username>/<repository>.git
```
