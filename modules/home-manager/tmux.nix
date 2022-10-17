{ config, lib, ... }:

with lib;

let
  cfg = config.modules.tmux;
in {
  options.modules.tmux = {
    enable = mkEnableOption "enable tmux";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-a";
      terminal = "screen-256color";
    };
  };
}
