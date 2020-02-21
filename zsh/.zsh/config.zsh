
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
REPORTTIME=10
which dircolors >/dev/null && eval `dircolors -b ~/.zsh/dircolors`

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
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
