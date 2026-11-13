#!/usr/bin/env bash
# Sets up everything this Neovim config needs on Ubuntu/Debian (apt) or Arch (pacman):
#   system packages, bob + Neovim stable, lazygit + delta, tree-sitter CLI, MesloLGS Nerd Font.
# Safe to re-run: already installed things are skipped.
set -euo pipefail

BIN_DIR="$HOME/.local/bin"
FONT_DIR="$HOME/.local/share/fonts"
BOB_NVIM_BIN="$HOME/.local/share/bob/nvim-bin"
NVIM_VERSION="${NVIM_VERSION:-stable}"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
skip() { printf '\033[1;33m--> %s\033[0m\n' "$*"; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
mkdir -p "$BIN_DIR" "$FONT_DIR"
export PATH="$BIN_DIR:$BOB_NVIM_BIN:$PATH"

case "$(uname -m)" in
	x86_64) ARCH=x86_64 ;;
	aarch64 | arm64) ARCH=arm64 ;;
	*) echo "Unsupported architecture: $(uname -m)" >&2 && exit 1 ;;
esac

# --- System packages ----------------------------------------------------------
info "Installing system packages"
if command -v apt-get >/dev/null; then
	sudo apt-get update
	sudo apt-get install -y git curl wget unzip tar gzip xz-utils build-essential \
		ripgrep fd-find nodejs npm python3 python3-venv python3-pip fontconfig xclip
	# Ubuntu ships fd as "fdfind"
	if ! command -v fd >/dev/null && command -v fdfind >/dev/null; then
		ln -sf "$(command -v fdfind)" "$BIN_DIR/fd"
	fi
elif command -v pacman >/dev/null; then
	sudo pacman -Syu --needed --noconfirm git curl wget unzip tar gzip xz base-devel \
		ripgrep fd nodejs npm python python-pip fontconfig xclip
else
	echo "No apt-get or pacman found, install the packages from the README manually." >&2
	exit 1
fi

# --- bob + Neovim -------------------------------------------------------------
if command -v bob >/dev/null; then
	skip "bob already installed ($(bob --version))"
else
	info "Installing bob"
	BOB_ARCH=$([ "$ARCH" = arm64 ] && echo arm || echo x86_64)
	curl -fsSL -o "$TMP/bob.zip" \
		"https://github.com/MordechaiHadad/bob/releases/latest/download/bob-linux-${BOB_ARCH}.zip"
	unzip -q "$TMP/bob.zip" -d "$TMP"
	install -m 755 "$TMP/bob-linux-${BOB_ARCH}/bob" "$BIN_DIR/bob"
fi

info "Installing Neovim $NVIM_VERSION via bob"
bob use "$NVIM_VERSION"

# --- lazygit ------------------------------------------------------------------
if command -v lazygit >/dev/null; then
	skip "lazygit already installed ($(lazygit --version | grep -o 'version=[^,]*'))"
else
	info "Installing lazygit"
	LG_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
		grep -Po '"tag_name": *"v\K[^"]*')
	curl -fsSL -o "$TMP/lazygit.tar.gz" \
		"https://github.com/jesseduffield/lazygit/releases/download/v${LG_VERSION}/lazygit_${LG_VERSION}_linux_${ARCH}.tar.gz"
	tar -xzf "$TMP/lazygit.tar.gz" -C "$TMP" lazygit
	install -m 755 "$TMP/lazygit" "$BIN_DIR/lazygit"
fi

# --- delta (nicer diffs in lazygit / git) ------------------------------------
if command -v delta >/dev/null; then
	skip "delta already installed ($(delta --version))"
else
	info "Installing delta"
	DELTA_VERSION=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest |
		grep -Po '"tag_name": *"\K[^"]*')
	DELTA_ARCH=$([ "$ARCH" = arm64 ] && echo aarch64 || echo x86_64)
	DELTA_NAME="delta-${DELTA_VERSION}-${DELTA_ARCH}-unknown-linux-gnu"
	curl -fsSL -o "$TMP/delta.tar.gz" \
		"https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/${DELTA_NAME}.tar.gz"
	tar -xzf "$TMP/delta.tar.gz" -C "$TMP"
	install -m 755 "$TMP/${DELTA_NAME}/delta" "$BIN_DIR/delta"
fi

LG_CONFIG="$HOME/.config/lazygit/config.yml"
if [ -s "$LG_CONFIG" ]; then
	skip "lazygit config exists, not touching it"
else
	info "Writing lazygit config (delta as diff renderer)"
	mkdir -p "$(dirname "$LG_CONFIG")"
	cat >"$LG_CONFIG" <<'EOF'
git:
  # cycle between them with | inside lazygit
  diffRenderers:
    - command: delta --{{colorScheme}} --paging=never {{if gt .width 160}}--side-by-side{{end}}
      name: delta
    - command: delta --{{colorScheme}} --paging=never --side-by-side
      name: delta side-by-side
    - type: rawGit
      name: default
EOF
fi

# --- tree-sitter CLI (needed by nvim-treesitter main branch) -----------------
if command -v tree-sitter >/dev/null; then
	skip "tree-sitter already installed ($(tree-sitter --version))"
else
	info "Installing tree-sitter CLI"
	TS_ARCH=$([ "$ARCH" = arm64 ] && echo arm64 || echo x64)
	curl -fsSL -o "$TMP/tree-sitter.gz" \
		"https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-${TS_ARCH}.gz"
	gunzip "$TMP/tree-sitter.gz"
	install -m 755 "$TMP/tree-sitter" "$BIN_DIR/tree-sitter"
fi

# --- MesloLGS Nerd Font -------------------------------------------------------
if fc-list | grep -qi "MesloLGS Nerd Font"; then
	skip "MesloLGS Nerd Font already installed"
else
	info "Installing MesloLGS Nerd Font"
	curl -fsSL -o "$TMP/Meslo.tar.xz" \
		https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.tar.xz
	mkdir -p "$FONT_DIR/Meslo"
	tar -xf "$TMP/Meslo.tar.xz" -C "$FONT_DIR/Meslo"
	fc-cache -f "$FONT_DIR"
fi

# --- PATH ---------------------------------------------------------------------
RC="$HOME/.bashrc"
[ -n "${ZSH_VERSION:-}" ] || [ "$(basename "${SHELL:-}")" = zsh ] && RC="$HOME/.zshrc"
touch "$RC"
# Remove hard-coded bob version paths, they break `bob use`
if grep -qE '\.local/share/bob/v[0-9][^/]*/bin' "$RC"; then
	info "Removing hard-coded bob version path from $RC"
	sed -i.bak -E '/\.local\/share\/bob\/v[0-9][^\/]*\/bin/d' "$RC"
fi
if ! grep -q 'bob/nvim-bin' "$RC"; then
	info "Adding bob and ~/.local/bin to PATH in $RC"
	printf '\n# Neovim (bob) and local binaries\nexport PATH="$HOME/.local/share/bob/nvim-bin:$HOME/.local/bin:$PATH"\n' >>"$RC"
fi

# --- Plugins ------------------------------------------------------------------
info "Installing Neovim plugins (lazy.nvim sync)"
nvim --headless "+Lazy! sync" +qa || true

info "Done!"
cat <<EOF
  1. Restart your shell (or run: source $RC)
  2. Set your terminal font to "MesloLGS Nerd Font"
  3. Run nvim and check :checkhealth
EOF
