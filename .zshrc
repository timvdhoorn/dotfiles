# Ghostty advertises xterm-ghostty, but older remote hosts may not ship its
# terminfo entry yet. Fall back before any prompt or ZLE plugin reads terminfo.
if [[ "$TERM" == "xterm-ghostty" ]] && ! infocmp xterm-ghostty &>/dev/null; then
  export TERM=xterm-256color
fi

# Suppress instant prompt warnings (output from plugins is expected)
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# === OS DETECTION ===
if [[ "$OSTYPE" == darwin* ]]; then
  IS_MACOS=true
else
  IS_MACOS=false
fi

# === PATH ===
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/usr/local/bin"

if $IS_MACOS; then
  export PATH="/opt/homebrew/bin:$PATH"
  export PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# === OH-MY-ZSH ===
export ZSH="$HOME/.oh-my-zsh"
plugins=(git fast-syntax-highlighting zsh-autosuggestions zsh-autocomplete colored-man-pages command-not-found)

# Docker CLI completions (must be before oh-my-zsh sources compinit)
if [[ -d "$HOME/.docker/completions" ]]; then
  fpath=("$HOME/.docker/completions" $fpath)
fi

source "$ZSH/oh-my-zsh.sh"

# === HISTORY ===
HISTSIZE=50000
SAVEHIST=50000
HIST_STAMPS="yyyy-mm-dd"
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS

# === SHELL OPTIONS ===
unsetopt CORRECT
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# === EDITOR ===
if $IS_MACOS; then
  export EDITOR='code --wait'
else
  export EDITOR='vim'
fi

# === POWERLEVEL10K ===
if $IS_MACOS; then
  source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
else
  source "$ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
fi
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# === MODERN CLI TOOLS ===
# eza (modern ls) - graceful degradation
if command -v eza &> /dev/null; then
  alias ls='eza --icons'
  alias ll='eza -la --icons'
  alias la='eza -a --icons'
  alias tree='eza --tree --icons'
fi

# bat (modern cat)
if command -v bat &> /dev/null; then
  alias cat='bat'
fi

# zoxide (smart cd)
if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# fzf (fuzzy finder)
if command -v fzf &> /dev/null; then
  source <(fzf --zsh)
fi

# === DIRECTORY NAVIGATION ===
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias d='dirs -v'

# === COLORS ===
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Colored less
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# GRC (colored output for common commands)
if command -v grc &> /dev/null; then
  alias ifconfig="grc ifconfig"
  alias ip="grc ip"
  alias netstat="grc netstat"
  alias ping="grc ping"
fi

# === NOCORRECT ALIASES ===
alias cp='nocorrect cp'
alias mv='nocorrect mv'
alias mkdir='nocorrect mkdir'
alias npx='nocorrect npx'
alias expo='nocorrect expo'
alias git='nocorrect git'
alias ccs='nocorrect ccs'
alias claude='nocorrect claude'
alias config='nocorrect config'

# === PLATFORM-SPECIFIC ===
if $IS_MACOS; then
  # Xcode fix
  alias xcodebuild='PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin xcodebuild'

  # Homebrew
  export HOMEBREW_NO_ENV_HINTS=1

  # Claude Code
  if command -v claude &> /dev/null; then
    export ENABLE_EXPERIMENTAL_MCP_CLI=true
    alias cc='claude'
    alias ccg='claude-glm'
    alias ccg45='claude-glm-4.5'
    alias ccf='claude-glm-fast'
    alias cs='claude-statusbar'
    alias cstatus='claude-statusbar'
    alias claude-mem='bun "$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
  fi
else
  # Linux: apt aliases
  alias update='sudo apt update && sudo apt upgrade -y'
  alias install='sudo apt install'
  alias search='apt search'
  alias remove='sudo apt remove'
fi

# === BUN ===
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# === ZSH-AUTOCOMPLETE ===
zstyle ':autocomplete:*' insert-unambiguous yes
zmodload -i zsh/complist 2>/dev/null
if [[ -n "${terminfo[kcub1]}" ]]; then
  bindkey -M menuselect '^[[D' .backward-char '^[OD' .backward-char 2>/dev/null
  bindkey -M menuselect '^[[C' .forward-char '^[OC' .forward-char 2>/dev/null
fi

# === TMUX ===
tn() { tmux new-session -s "${1:-$(basename "$PWD")}" }
alias tl='tmux list-sessions'
alias ta='tmux attach-session'

# Auto-rename tmux session to current directory
_tmux_rename_session() {
  if [[ -n "$TMUX" ]]; then
    tmux rename-session "$(basename "$PWD")" 2>/dev/null
  fi
}
chpwd_functions+=(_tmux_rename_session)

# === OTHER ===
alias lzd='lazydocker'

# Grok Build (when installed)
export PATH="$HOME/.grok/bin:$PATH"
if [[ -d "$HOME/.grok/completions/zsh" ]]; then
  fpath=("$HOME/.grok/completions/zsh" $fpath)
  autoload -Uz compinit && compinit -C
fi

# Shared user-local development toolchain (when installed)
[[ -r "$HOME/.config/agent-paths.zsh" ]] && source "$HOME/.config/agent-paths.zsh"
