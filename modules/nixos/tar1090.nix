{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.tar1090;
  pkg = pkgs.tar1090;
in {
  meta.maintainers = with maintainers; [ auchter ];

  options.services.tar1090 = {
    enable = mkEnableOption "tar1090 web interface for ADS-B receivers";

    hostName = mkOption {
      description = "Hostname to serve on";
      type = types.str;
    };

    adsbDir = mkOption {
      default = "/run/readsb";
      description = "ADS-B output directory to read from";
      type = types.path;
    };

    interval = mkOption {
      default = 8;
      description = "Time in seconds between snapshots in the track history";
      type = types.int;
    };

    historySize = mkOption {
      default = 450;
      description = "How many snapshots are stored in the track history";
      type = types.int;
    };

    gzipLevel = mkOption {
      default = 1;
      description = "Compression level to use; 1 is lower CPU usage";
      type = types.int;
    };

    hoursOfTracks = mkOption {
      default = 8;
      description = "Hours of tracks that /?pTracks will show";
      type = types.int;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.tar1090 = {
      description = "Web interface for ADS-B receivers";
      after = [ "network.target" "readsb.service" "dump1090.service" ];
      wants = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkg}/bin/tar1090.sh /run/tar1090 ${cfg.adsbDir}";
        Environment = [
          "INTERVAL=${toString cfg.interval}"
          "HISTORY_SIZE=${toString cfg.historySize}"
          "GZIP_LVL=${toString cfg.gzipLevel}"
          "PTRACKS=${toString cfg.hoursOfTracks}"
          "CHUNK_SIZE=20"
        ];
        Type = "simple";
        Restart = "always";
        RestartSec = 30;
        RuntimeDirectory = "tar1090";
        RuntimeDirectoryMode = "0755";
      };
    };

    services.nginx = {
      enable = mkDefault true;
      virtualHosts."${cfg.hostName}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            root = "${pkg}/share";
          };
          "/data/" = {
            root = "${cfg.adsbDir}";
            extraConfig = ''
              rewrite ^/data/(.*)$ /$1 break;
            '';
          };
          "/chunks/" = {
            root = "/run/tar1090";
            extraConfig = ''
              rewrite ^/chunks/(.*)$ /$1 break;
            '';
          };
        };
      };
    };
  };
}
