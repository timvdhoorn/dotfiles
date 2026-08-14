# dotfiles

Cross-platform dotfiles for macOS and Debian/Ubuntu with Zsh, Powerlevel10k (Catppuccin Mocha), tmux, and modern CLI tools.

## Quick Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/timvdhoorn/dotfiles/main/install.sh)
```

## What's Included

| File | Description |
|------|-------------|
| `.zshrc` | Zsh config with OS detection, modern CLI aliases, Oh My Zsh |
| `.p10k.zsh` | Powerlevel10k theme (Catppuccin Mocha, lean style) |
| `.tmux.conf` | Tmux config with Catppuccin-inspired status bar |
| `install.sh` | Unified installer for macOS + Debian/Ubuntu |

## Packages Installed

### Both Platforms
- Zsh + Oh My Zsh
- Powerlevel10k
- Plugins: fast-syntax-highlighting, zsh-autosuggestions, zsh-autocomplete
- tmux + TPM (Tmux Plugin Manager)

### Modern CLI Tools (with graceful degradation)
- **eza** - modern `ls` with icons
- **bat** - modern `cat` with syntax highlighting
- **fzf** - fuzzy finder
- **zoxide** - smarter `cd`

### macOS (via Homebrew)
All packages installed via Homebrew.

### Linux (via apt + git clone)
Base packages via `apt`, Zsh plugins and Powerlevel10k via git clone. Only missing apt packages are installed on repeat runs.

## Update

```bash
cd ~/.dotfiles && git pull
```

## Prerequisites

- A [Nerd Font](https://www.nerdfonts.com/font-downloads) (e.g., JetBrainsMono Nerd Font)
- Terminal configured to use the Nerd Font

## Troubleshooting

### Icons not showing
Install a Nerd Font and set it as your terminal font.

### Tmux plugins not loading
Press `` ` + I `` (prefix + Shift-i) inside tmux to install plugins.

### Powerlevel10k prompt looks wrong
Run `p10k configure` to reconfigure the prompt.

### T3 or SSH input is duplicated, cursor keys fail, or backspace inserts spaces
Ghostty uses `TERM=xterm-ghostty`, but some remote hosts do not ship that terminfo entry yet. The zsh profile detects this before loading prompt or ZLE plugins and falls back to the widely supported `xterm-256color` entry.
