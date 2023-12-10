{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ttctrl;
in {
  options.services.ttctrl = {
    enable = mkEnableOption "ttctrl";
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
  };

  config = mkIf cfg.enable {
    systemd.services.ttctrl = {
      description = "ttctrl";
      after = [ "network.target" "mpd.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.ttctrl}/bin/ttctrl \
            --mpd-host ${cfg.mpdHost} \
            --mpd-port ${toString cfg.mpdPort}
        '';
        Restart = "always";
        DynamicUser = true;
        SupplementaryGroups = [ "pipewire" ];
      };
    };
  };
}
