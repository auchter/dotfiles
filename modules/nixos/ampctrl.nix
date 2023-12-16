{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ampctrl;
in {
  options.services.ampctrl = {
    enable = mkEnableOption "ampctrl";
    mpdHost = mkOption {
      type = types.str;
      default = "localhost";
      description = "MPD host to control";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ampctrl = {
      description = "ampctrl";
      after = [ "network.target" "mpd.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.ampctrl}/bin/ampctrl --mpd-host ${cfg.mpdHost}
        '';
        Restart = "always";
        SupplementaryGroups = [ "gpio" ];
      };
    };
  };
}

