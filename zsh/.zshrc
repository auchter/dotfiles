export ZSH=$HOME/.zsh/

for config_file ($ZSH/*.zsh) source $config_file

autoload -U compinit
compinit
