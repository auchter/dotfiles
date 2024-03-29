{ config, lib, ... }:

with lib;

let
  cfg = config.modules.zsh;
in {
  options.modules.zsh = {
    enable = mkEnableOption "enable zsh";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        plugins = [ ];
      };
      initExtra = ''
        setopt prompt_subst
        autoload colors
        colors
        autoload -Uz vcs_info
        zstyle ':vcs_info:*' formats '%F{green}%s%F{7} %F{2}(%F{blue}%b%F{2})%f '
        zstyle ':vcs_info:*' enable git

        PS1=' ''${vcs_info_msg_0_}%F{green}%n@%m%k %F{blue}%1~ %# %b%f%k'
        RPROMPT='''

        precmd() {
           title "zsh" "%m" "%55<...<%~"
           vcs_info 'prompt'
        }

        bindkey '^P' reverse-menu-complete
        bindkey '^N' expand-or-complete

        setopt CORRECT
        setopt COMPLETE_IN_WORD
      '';
      shellAliases = {
        f="fg";
        ls="ls --color=auto";

        fixssh="eval $(tmux showenv -s SSH_AUTH_SOCK)";
        rebuild-system = "sudo nixos-rebuild switch --flake '.#'";
      };
    };
  };
}
