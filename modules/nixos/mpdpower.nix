{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mpdpower;
in {
  options.services.mpdpower = {
    enable = mkEnableOption "mpdpower";
    mpdHost = mkOption {
      type = types.str;
      default = "localhost";
      description = "MPD host to control";
    };
    mpdPort = mkOption {
      type = types.port;
      default = 6600;
      description = "MPD port";
    };
    btAddr = mkOption {
      type = types.str;
      description = "BT address of the Griffin Powermate";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mpdpower = {
      description = "mpdpower";
      after = [ "network.target" "mpd.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.mpdpower}/bin/mpdpower \
            --mpd-host ${cfg.mpdHost} \
            --mpd-port ${toString cfg.mpdPort} \
            ${cfg.btAddr}
        '';
        Restart = "always";
        DynamicUser = true;
        AmbientCapabilities = [ "CAP_NET_ADMIN" ];
      };
    };
  };
}
