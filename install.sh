#!/bin/bash

set -e

# === Colors ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# === OS Detection ===
OS="unknown"
if [[ "$OSTYPE" == darwin* ]]; then
  OS="macos"
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
  if [[ "$ID" == "debian" || "$ID" == "ubuntu" || "$ID_LIKE" == *"debian"* ]]; then
    OS="linux"
  fi
fi

if [[ "$OS" == "unknown" ]]; then
  error "Unsupported OS. This script supports macOS and Debian/Ubuntu."
fi

info "Detected OS: $OS"

# === Configuration ===
DOTFILES_DIR="$HOME/.dotfiles"
BACKUP_SUFFIX=".backup.$(date +%Y%m%d_%H%M%S)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# === Helper: backup and symlink ===
link_file() {
  local src="$1"
  local dst="$2"

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    info "Backing up $dst -> ${dst}${BACKUP_SUFFIX}"
    mv "$dst" "${dst}${BACKUP_SUFFIX}"
  elif [[ -L "$dst" ]]; then
    rm "$dst"
  fi

  ln -s "$src" "$dst"
  ok "Linked $src -> $dst"
}

# === Step 1: Clone or update dotfiles ===
if [[ -d "$DOTFILES_DIR" ]]; then
  info "Updating existing dotfiles..."
  git -C "$DOTFILES_DIR" pull --rebase --quiet
  ok "Dotfiles updated"
else
  info "Cloning dotfiles..."
  git clone https://github.com/timvdhoorn/dotfiles.git "$DOTFILES_DIR"
  ok "Dotfiles cloned to $DOTFILES_DIR"
fi

# Re-exec from local copy to ensure latest version runs
if [[ "${DOTFILES_BOOTSTRAPPED:-}" != "1" ]]; then
  export DOTFILES_BOOTSTRAPPED=1
  exec bash "$DOTFILES_DIR/install.sh" "$@"
fi

# === Step 2: Install packages ===
if [[ "$OS" == "macos" ]]; then
  if ! command -v brew &> /dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  info "Installing packages via Homebrew..."
  brew install zsh git eza bat fzf zoxide tmux tpm powerlevel10k 2>/dev/null || true

  # zsh plugins via Homebrew
  brew install zsh-autosuggestions zsh-autocomplete fast-syntax-highlighting 2>/dev/null || true
  ok "Homebrew packages installed"

elif [[ "$OS" == "linux" ]]; then
  info "Installing packages via apt..."
  sudo apt update -qq
  sudo apt install -y -qq zsh git curl tmux

  # Optional modern CLI tools (may not be in default repos)
  for pkg in eza bat fzf zoxide; do
    if ! command -v "$pkg" &> /dev/null; then
      sudo apt install -y -qq "$pkg" 2>/dev/null || warn "$pkg not available in apt, skipping"
    fi
  done
  ok "Apt packages installed"
fi

# === Step 3: Oh My Zsh ===
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "Oh My Zsh installed"
else
  ok "Oh My Zsh already installed"
fi

# === Step 4: Zsh plugins (Linux only, macOS uses Homebrew) ===
if [[ "$OS" == "linux" ]]; then
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  declare -A plugins=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-autocomplete]="https://github.com/marlonrichert/zsh-autocomplete"
    [fast-syntax-highlighting]="https://github.com/zdharma-continuum/fast-syntax-highlighting"
  )

  for name in "${!plugins[@]}"; do
    dest="$ZSH_CUSTOM/plugins/$name"
    if [[ ! -d "$dest" ]]; then
      info "Installing plugin: $name"
      git clone --depth=1 "${plugins[$name]}" "$dest"
    fi
  done

  # Powerlevel10k theme
  if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    info "Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
  fi
  ok "Zsh plugins installed"
fi

# === Step 5: TPM (Tmux Plugin Manager) ===
if [[ "$OS" == "linux" && ! -d "$HOME/.tmux/plugins/tpm" ]]; then
  info "Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  ok "TPM installed"
fi

# === Step 6: Symlinks ===
info "Creating symlinks..."
link_file "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"
link_file "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# === Step 7: Set zsh as default shell ===
if [[ "$SHELL" != *"zsh"* ]]; then
  info "Setting zsh as default shell..."
  chsh -s "$(which zsh)"
  warn "Log out and back in for the shell change to take effect"
fi

# === Step 8: Install TPM plugins ===
if command -v tmux &> /dev/null; then
  if [[ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
    info "Installing tmux plugins..."
    "$HOME/.tmux/plugins/tpm/bin/install_plugins" 2>/dev/null || true
  elif [[ "$OS" == "macos" && -f "/opt/homebrew/opt/tpm/share/tpm/bin/install_plugins" ]]; then
    info "Installing tmux plugins..."
    /opt/homebrew/opt/tpm/share/tpm/bin/install_plugins 2>/dev/null || true
  fi
fi

# === Done ===
echo ""
ok "Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Install a Nerd Font (e.g., JetBrainsMono Nerd Font)"
echo "     https://www.nerdfonts.com/font-downloads"
echo "  2. Set your terminal font to the installed Nerd Font"
echo "  3. Start a new terminal or run: exec zsh"
echo "  4. Start tmux and press prefix + I to install plugins"
echo ""
echo "To update later: cd ~/.dotfiles && git pull"
