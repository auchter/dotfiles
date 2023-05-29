{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ampctrl;
in {
  options.services.ampctrl = {
    enable = mkEnableOption "ampctrl";
  };

  config = mkIf cfg.enable {
    systemd.services.ampctrl = {
      description = "ampctrl";
      after = [ "network.target" "mpd.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.ampctrl}/bin/ampctrl
        '';
        Restart = "always";
        SupplementaryGroups = [ "gpio" ];
      };
    };
  };
}

