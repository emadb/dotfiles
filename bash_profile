# aliases
alias cd..="cd .."
alias iwork09="rm Library/Preferences/com.apple.iWork09.plist"
alias remove_all_gems="gem list | cut -d' ' -f1 | xargs gem uninstall -aIx"
alias redis_server="redis-server /usr/local/etc/redis.conf"

BLUE="\[\033[0;34m\]"
GREEN="\[\033[0;32m\]"
GRAY="\[\033[1;34m\]"

export LS_OPTIONS='--color=auto'
export CLICOLOR='Yes'
export LSCOLORS='BxFxCxDxBxegedabagacad'

#rvm
cd .
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

#paths
PATH=$PATH
source ~/.git-completion.sh

#prompt
PS1="$BLUE\w$GREEN\$(__git_ps1)$GRAY \$ "



