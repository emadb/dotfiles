#!/usr/bin/env zsh

# One-time install of the plugins (all cloned into ~/.zsh/plugins):
#   mkdir -p ~/.zsh/plugins
#   git clone https://github.com/zsh-users/zsh-completions         ~/.zsh/plugins/zsh-completions
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/plugins/zsh-syntax-highlighting
# To update later: cd into each dir and `git pull` (or loop over them).

# ----------------------------------------------------------------------------
# Plugin directory (cloned repos)
# ----------------------------------------------------------------------------
ZSH_PLUGIN_DIR="$HOME/.zsh/plugins"

# ----------------------------------------------------------------------------
# Environment
# ----------------------------------------------------------------------------
export LANG=en_US.UTF-8
export EDITOR='zed'

export ERL_AFLAGS="-kernel shell_history enabled"
export HOMEBREW_NO_AUTO_UPDATE=1

# PATH
export PATH="/usr/local/sbin:$PATH"
export PATH="/usr/local/opt/libpq/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Colored output for ls and friends (OMZ used to enable this)
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# ----------------------------------------------------------------------------
# Completion system
# ----------------------------------------------------------------------------
# Add extra completion directories to fpath BEFORE compinit runs.
fpath=("$ZSH_PLUGIN_DIR/zsh-completions/src" $fpath)
fpath=(/Users/ema/.docker/completions $fpath)
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)

autoload -Uz compinit
# Rebuild the completion cache at most once a day for faster startup.
# The glob expands to args only when ~/.zcompdump is older than 24h, in which
# case we run a full (security-checked) compinit; otherwise the fast path.
() {
  if (( $# > 0 )); then compinit; else compinit -C; fi
} ${HOME}/.zcompdump(N.mh+24)

# OMZ-like completion behaviour
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'

# ----------------------------------------------------------------------------
# History (mirrors the OMZ defaults you were relying on)
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_historys
HISTSIZE=10000
SAVEHIST=10000

setopt share_history          # share history across sessions
setopt append_history         # append rather than overwrite
setopt inc_append_history     # write as commands are entered
setopt extended_history       # record timestamps
setopt hist_expire_dups_first
setopt hist_ignore_dups       # don't record consecutive duplicates
setopt hist_ignore_space      # ignore commands starting with a space
setopt hist_verify            # show before running history expansion

# ----------------------------------------------------------------------------
# Shell options
# ----------------------------------------------------------------------------
setopt auto_cd                # `dir` instead of `cd dir`
setopt auto_pushd             # cd pushes onto the dir stack
setopt pushd_ignore_dups
setopt interactive_comments   # allow # comments in interactive shell
setopt no_beep

# ----------------------------------------------------------------------------
# Key bindings (emacs mode + prefix history search)
# ----------------------------------------------------------------------------
bindkey -e

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search     # Up
bindkey '^[[B' down-line-or-beginning-search   # Down

# ----------------------------------------------------------------------------
# dotenv: auto-source a .env file when entering a directory
# (lightweight replacement for the OMZ `dotenv` plugin, with a prompt)
# ----------------------------------------------------------------------------
ZSH_DOTENV_FILE=.env
_dotenv_autoload() {
  [[ -f "$ZSH_DOTENV_FILE" ]] || return
  # Confirm before sourcing, for safety.
  printf 'dotenv: source %s/%s? [Y/n] ' "$PWD" "$ZSH_DOTENV_FILE"
  read -k 1 -r reply; printf '\n'
  [[ "$reply" == [nN] ]] && return
  set -a; source "$ZSH_DOTENV_FILE"; set +a
}
autoload -Uz add-zsh-hook
add-zsh-hook chpwd _dotenv_autoload
_dotenv_autoload   # also run for the initial directory

# ----------------------------------------------------------------------------
# Plugins (third-party)
# ----------------------------------------------------------------------------

# npm completion (replaces the OMZ `npm` plugin)
command -v npm >/dev/null && source <(npm completion 2>/dev/null)

# ----------------------------------------------------------------------------
# Aliases (your personal ones)
# ----------------------------------------------------------------------------
alias rm_ds="find . -name '*.DS_Store' -type f -delete"
alias gti='git'
alias www='python3 -m http.server --cgi 8000 --bind 127.0.0.1'
alias yt='yt-dlp -x --audio-format wav --audio-quality 0'
alias ttop='top -ocpu -R -F -s 2 -n30'
alias zed='open -a /Applications/Zed.app -n'
alias l='ls -la'
alias bearcli='/Applications/Bear.app/Contents/MacOS/bearcli'
# ----------------------------------------------------------------------------
# Functions
# ----------------------------------------------------------------------------
# yazi: cd into the directory you quit yazi in
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# ----------------------------------------------------------------------------
# Tool initialisation
# ----------------------------------------------------------------------------
# Starship prompt
eval "$(starship init zsh)"

# fzf key bindings and fuzzy completion
command -v fzf >/dev/null && source <(fzf --zsh)

# VS Code shell integration for Copilot
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  unset RPROMPT
  unset RPS1
  [[ -f "$(code --locate-shell-integration-path zsh)" ]] && \
    . "$(code --locate-shell-integration-path zsh)"
fi

# ----------------------------------------------------------------------------
# zsh-syntax-highlighting — MUST be sourced last
# ----------------------------------------------------------------------------
[[ -f "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && \
  source "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
