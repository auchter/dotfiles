{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.soulseek;
in {
  options.modules.soulseek = {
    enable = mkEnableOption "enable soulseek";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 2234 ];
    environment.systemPackages = with pkgs; [
      nicotine-plus
    ];
  };
}

