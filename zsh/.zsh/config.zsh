
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
REPORTTIME=10
eval `dircolors -b ~/.zsh/dircolors`

setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt CORRECT
setopt COMPLETE_IN_WORD

bindkey '^P' reverse-menu-complete
bindkey '^N' expand-or-complete

export EDITOR="vim"
[[ -e `which firefox-bin 2>/dev/null` ]] && export BROWSER="firefox-bin"
[[ -e `which firefox 2>/dev/null` ]] && export BROWSER="firefox"
export PATH=$PATH:$ZSH/bin
export LC_CTYPE=en_US.UTF8

alias ls="ls --color=auto"
