{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mpdcamillamixer;
in {
  options.services.mpdcamillamixer = {
    enable = mkEnableOption "mpdcamillamixer";
    mpdHost = mkOption {
      type = types.str;
      description = "MPD host";
      default = "localhost";
    };
    mpdPort = mkOption {
      type = types.port;
      description = "MPD port";
      default = 6600;
    };
    camillaHost = mkOption {
      type = types.str;
      description = "CamillaDSP Websocket Host";
      default = "localhost";
    };
    camillaPort = mkOption {
      type = types.port;
      description = "CamillaDSP Websocket Port";
      default = config.services.camilladsp.port;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.mpdcamillamixer = {
      description = "mpdcamillamixer";
      after = [ "network.target" "camilladsp.service" "mpd.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.mpdcamillamixer}/bin/mpdcamillamixer \
            --mpd-host ${cfg.mpdHost} \
            --mpd-port ${toString cfg.mpdPort} \
            --camilla-host ${cfg.camillaHost} \
            --camilla-port ${toString cfg.camillaPort}
        '';
        Restart = "always";
      };
    };
  };
}


