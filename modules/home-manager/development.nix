{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development;
in {
  options.modules.development = {
    enable = mkEnableOption "enable development tools";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      bc
      bmap-tools
      dterm
      jq
    ];
  };
}
