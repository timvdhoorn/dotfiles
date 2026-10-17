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
    export CLAUDE_CODE_BLOCKING_LIMIT_OVERRIDE=1000000
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

# === HELP ===
_show_help() {
  local c=$'\033[38;2;137;180;250m' b=$'\033[1;38;2;203;166;247m' d=$'\033[38;2;127;132;156m' r=$'\033[0m'
  local w=32 hl="${d}$(printf '─%.0s' {1..32})" hr="$(printf '─%.0s' {1..32})" he="$(printf '─%.0s' {1..28})${r}"
  local lt="${hl}┬${hr}┬${he}" lm="${hl}┼${hr}┼${he}" lb="${hl}┴${hr}┴${he}"
  _hp() {
    local strip=$(printf '%s' "$1" | command sed $'s/\033\\[[0-9;]*m//g')
    local pad=$(( w - ${#strip} ))
    (( pad < 0 )) && pad=0
    printf '%s%*s' "$1" "$pad" ""
  }
  _hr() {
    local sep="${d}│${r}"
    if [[ $# -ge 3 ]]; then
      printf '%s%s%s%s%s\n' "$(_hp "$1")" "$sep" "$(_hp "$2")" "$sep" "$3"
    elif [[ $# -ge 2 ]]; then
      printf '%s%s%s%s\n' "$(_hp "$1")" "$sep" "$(_hp "$2")" "$sep"
    else
      printf '%s\n' "$1"
    fi
  }
  printf '\n%s\n' "$lt"
  _hr "  ${b}Navigation${r}" "  ${b}Files${r}" "  ${b}Search & Shell${r}"
  _hr "    ${c}z <query>${r}  ${d}Smart cd${r}" "    ${c}ls${r}        ${d}eza icons${r}" "    ${c}ctrl-r${r}    ${d}History${r}"
  _hr "    ${c}zi${r}         ${d}Dir picker${r}" "    ${c}ll${r}        ${d}Long format${r}" "    ${c}ctrl-t${r}    ${d}File search${r}"
  _hr "    ${c}.. ... ....${r} ${d}Go up${r}" "    ${c}la${r}        ${d}All files${r}" "    ${c}alt-c${r}     ${d}Cd subdir${r}"
  _hr "    ${c}d${r}          ${d}Dir stack${r}" "    ${c}tree${r}      ${d}Tree view${r}" "    ${c}→/ctrl-e${r}  ${d}Accept hint${r}"
  _hr "" "    ${c}cat${r}       ${d}bat${r}" "    ${c}tab${r}       ${d}Autocomplete${r}"
  printf '%s\n' "$lm"
  _hr "  ${b}Git${r}" "  ${b}Tmux${r}" "  ${b}AI${r}"
  _hr "    ${c}gst${r}        ${d}status${r}" "    ${c}t / tmux${r}  ${d}Session picker${r}" "    ${c}cc${r}        ${d}claude${r}"
  _hr "    ${c}ga${r}         ${d}add${r}" "    ${c}tl${r}        ${d}List sessions${r}" "    ${c}ccg${r}       ${d}claude-glm${r}"
  _hr "    ${c}gc${r}         ${d}commit${r}" "    ${c}ta${r}        ${d}Attach${r}" "    ${c}ccf${r}       ${d}glm-fast${r}"
  _hr "    ${c}gco${r}        ${d}checkout${r}" "    ${c}prefix: \`${r} ${d}(backtick)${r}" "    ${c}cs${r}        ${d}statusbar${r}"
  _hr "    ${c}gcm${r}        ${d}checkout main${r}" "    ${c}\` + r${r}     ${d}Rename session${r}" "    ${c}ccs${r}       ${d}claude ccs${r}"
  _hr "    ${c}gb${r}         ${d}branch${r}" "    ${c}\` + e${r}     ${d}Session tree${r}" "    ${c}gemini${r}    ${d}gemini cli${r}"
  _hr "    ${c}gd${r}         ${d}diff${r}" "    ${c}\` + d${r}     ${d}Detach${r}" "    ${c}codex${r}     ${d}codex cli${r}"
  _hr "    ${c}gl${r}         ${d}pull${r}" "    ${c}\` + h / |${r} ${d}Split horiz${r}"
  _hr "    ${c}gp${r}         ${d}push${r}" "    ${c}\` + v / -${r} ${d}Split vert${r}"
  _hr "    ${c}glog${r}       ${d}log --graph${r}" "    ${c}\` + w${r}     ${d}Kill pane${r}"
  _hr "" "    ${c}\` + q${r}     ${d}Kill session${r}"
  _hr "" "    ${c}\` + f${r}     ${d}Zoom pane${r}"
  _hr "" "    ${c}\` + WASD${r}  ${d}Resize pane${r}"
  _hr "" "    ${c}\` + arrows${r} ${d}Select pane${r}"
  _hr "" "    ${c}M-wasd${r}    ${d}Nav panes${r}"
  _hr "" "    ${c}M-f${r}       ${d}Zoom pane${r}"
  _hr "" "    ${c}M-1..9${r}    ${d}Switch window${r}"
  _hr "" "    ${c}ctrl-tab${r}  ${d}Next window${r}"
  _hr "" "    ${c}ctrl-S-tab${r} ${d}Prev window${r}"
  printf '%s\n' "$lm"
  _hr "  ${b}Tools${r}" "  ${b}Brew${r}" "  ${b}1Password CLI${r}"
  _hr "    ${c}jq${r}         ${d}JSON${r}" "    ${c}brew install${r} ${d}Install${r}" "    ${c}op item list${r} ${d}List items${r}"
  _hr "    ${c}htmlq${r}      ${d}HTML${r}" "    ${c}brew upgrade${r} ${d}Upgrade${r}" "    ${c}op item get${r}  ${d}Get item${r}"
  _hr "    ${c}rg${r}         ${d}ripgrep${r}" "    ${c}brew search${r} ${d}Search${r}" "    ${c}op read${r}      ${d}Read secret${r}"
  _hr "    ${c}gh${r}         ${d}GitHub CLI${r}" "    ${c}brew list${r}   ${d}Installed${r}" "    ${c}op inject${r}    ${d}Inject${r}"
  _hr "    ${c}shellcheck${r} ${d}Shell lint${r}" "    ${c}brew info${r}   ${d}Pkg info${r}" "    ${c}op signin${r}    ${d}Sign in${r}"
  _hr "    ${c}xleak${r}      ${d}xlsx viewer${r}" "    ${c}brew cleanup${r} ${d}Clean old${r}"
  _hr "    ${c}mas${r}        ${d}App Store${r}" "" ""
  printf '%s\n' "$lm"
  _hr "  ${b}Network${r}" "  ${b}Media${r}" "  ${b}Other${r}"
  _hr "    ${c}ip a${r}       ${d}IP addresses${r}" "    ${c}ffmpeg${r}    ${d}Video/audio${r}" "    ${c}lzd${r}       ${d}lazydocker${r}"
  _hr "    ${c}speedtest${r}  ${d}Speed test${r}" "    ${c}convert${r}   ${d}ImageMagick${r}" "    ${c}nvim${r}      ${d}neovim${r}"
  _hr "    ${c}tailscale status${r} ${d}Status${r}" "    ${c}exiftool${r}  ${d}EXIF data${r}" "    ${c}ngrok${r}     ${d}Expose local${r}"
  _hr "    ${c}tailscale up${r} ${d}Connect${r}" "    ${c}tesseract${r} ${d}OCR${r}" "    ${c}mackup${r}    ${d}App backup${r}"
  _hr "    ${c}tailscale down${r} ${d}Disconnect${r}" "    ${c}qrencode${r}  ${d}QR codes${r}" "    ${c}websocat${r}  ${d}WebSocket CLI${r}"
  _hr "    ${c}tailscale ip${r} ${d}TS IP${r}" "" ""
  printf '%s\n' "$lm"
  _hr "  ${b}Docker${r}" "" ""
  _hr "    ${c}docker ps${r}  ${d}Containers${r}" "    ${c}docker build${r} ${d}Build image${r}" "    ${c}docker logs${r} ${d}View logs${r}"
  _hr "    ${c}docker ps -a${r} ${d}All contrs${r}" "    ${c}docker pull${r} ${d}Pull image${r}" "    ${c}docker exec -it${r} ${d}Shell in${r}"
  _hr "    ${c}docker images${r} ${d}List imgs${r}" "    ${c}docker push${r} ${d}Push image${r}" "    ${c}docker cp${r}   ${d}Copy files${r}"
  _hr "    ${c}docker run${r} ${d}Run contr${r}" "    ${c}docker compose up${r} ${d}Start${r}" "    ${c}docker system prune${r} ${d}Clean${r}"
  _hr "    ${c}docker stop${r} ${d}Stop contr${r}" "    ${c}docker compose down${r} ${d}Stop${r}" "    ${c}docker stats${r} ${d}Resources${r}"
  _hr "    ${c}docker rm${r}  ${d}Remove contr${r}" "    ${c}docker compose logs${r} ${d}Logs${r}" "    ${c}lzd${r}       ${d}lazydocker TUI${r}"
  printf '%s\n\n' "$lb"
  unfunction _hp _hr
}
alias '?'='_show_help'

# === TMUX ===
tmux() {
  if [[ $# -eq 0 ]]; then
    local sessions
    sessions=$(command tmux list-sessions -F '#{session_name}' 2>/dev/null)

    # No sessions → create new
    if [[ -z "$sessions" ]]; then
      command tmux new-session -s "$(basename "$PWD")"
      return
    fi

    # 1 session → auto-attach
    if [[ $(echo "$sessions" | wc -l) -eq 1 ]]; then
      command tmux attach-session -t "$sessions"
      return
    fi

    # Multiple sessions → fzf picker (flat list with windows)
    local result
    result=$(
      tmux-session-list |
      fzf --prompt='tmux > ' \
          --height=~50% \
          --layout=reverse \
          --ansi \
          --delimiter='\t' \
          --with-nth=2 \
          --bind 'ctrl-x:execute-silent(command tmux kill-session -t $(echo {1} | cut -d: -f1) 2>/dev/null)+reload(tmux-session-list)' \
          --info-command='printf "  %s  ctrl-x: kill" "$FZF_INFO"'
    )

    [[ -z "$result" ]] && return

    local key="${result%%$'\t'*}"
    if [[ "$key" == "+" ]]; then
      command tmux new-session -s "$(basename "$PWD")"
    else
      command tmux attach-session -t "$key"
    fi
  else
    command tmux "$@"
  fi
}
alias t='tmux'
alias tl='tmux list-sessions'
alias ta='tmux attach-session'

# Auto-rename tmux session to current directory
_tmux_rename_session() {
  if [[ -n "$TMUX" ]]; then
    tmux rename-session "$(basename "$PWD")" 2>/dev/null
  fi
}
chpwd_functions+=(_tmux_rename_session)
_tmux_rename_session

# === OTHER ===
alias lzd='lazydocker'
