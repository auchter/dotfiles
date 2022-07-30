{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.readsb;
in {
  meta.maintainers = with maintainers; [ auchter ];

  options.services.readsb = {
    enable = mkEnableOption "readsb ADS-B Receiver";

    package = mkOption {
      default = pkgs.readsb;
      defaultText = literalExpression "pkgs.readsb";
      description = "Package to install.";
      type = types.package;
    };

    deviceType = mkOption {
      description = "SDR type to use";
      type = types.enum [
        "rtlsdr"
        "bladerf"
        "ubladerf"
        "plutosdr"
        "modesbeast"
        "gnshulc"
        "ifile"
        "none"
      ];
    };

    latitude = mkOption {
      description = "Reference/receiver surface latitude";
      type = types.nullOr types.float;
      default = null;
    };

    longitude = mkOption {
      description = "Reference/receiver surface longitude";
      type = types.nullOr types.float;
      default = null;
    };

    uuid = mkOption {
      example = "eacb6bab-f444-4ebf-a06a-3f72d7465e41";
      type = types.nullOr types.str;
      description = "UUID to identify instance. Can be generated with uuidgen.";
      default = null;
    };

    network = {
      bindAddress = mkOption {
        description = "Address to bind to";
        type = types.str;
        default = "localhost";
      };

      beastOutputPort = mkOption {
        description = "Port to output beast data on";
        type = types.nullOr types.port;
        default = null;
      };

      beastInputPort = mkOption {
        description = "Port to input beast data on";
        type = types.nullOr types.port;
        default = null;
      };
    };

    connections = mkOption {
      description = "Network connections to make";
      type = types.listOf (types.submodule {
        options = {
          host = mkOption {
            description = "Host to connect to";
            type = types.str;
          };

          port = mkOption {
            description = "Port to connect to on host";
            type = types.port;
          };

          protocol = mkOption {
            description = "Protocol to use";
            type = types.enum [
              "beast_out"
              "beast_reduce_out"
              "beast_in"
              "raw_out"
              "raw_in"
              "sbs_in"
              "sbs_in_jaero"
              "sbs_out"
              "sbs_out_jaero"
              "vrs_out"
              "json_out"
              "gpsd_in"
              "uat_in"
            ];
          };

          failover_host = mkOption {
            description = "Host to connect to";
            type = types.nullOr types.str;
            default = null;
          };

          failover_port = mkOption {
            description = "Port to connect to on host";
            type = types.nullOr types.port;
            default = null;
          };
        };
      });
    };
  };

  config = mkIf cfg.enable (
    let
      uuidFile = pkgs.writeText "uuidFile" (toString cfg.uuid);
      mkConnection = conn: "--net-connector=${conn.host},${toString conn.port},${conn.protocol}" +
        (optionalString (conn.failover_host != null) ",${conn.failover_host},${toString conn.failover_port}");
    in { systemd.services.readsb = {
      description = "readsb ADS-B Receiver";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/readsb \
            --net \
            --quiet \
            --write-json /run/readsb \
            --device-type ${cfg.deviceType} \
            --net-bind-address ${cfg.network.bindAddress} \
            ${optionalString (cfg.network.beastOutputPort != null) "--net-bo-port=${toString cfg.network.beastOutputPort}"} \
            ${optionalString (cfg.network.beastInputPort != null) "--net-bi-port=${toString cfg.network.beastInputPort}"} \
            ${optionalString (cfg.latitude != null) "--lat=${toString cfg.latitude}"} \
            ${optionalString (cfg.longitude != null) "--lon=${toString cfg.longitude}"} \
            ${optionalString (cfg.uuid != null) "--uuid-file=${uuidFile}"} \
            ${concatMapStringsSep " " mkConnection cfg.connections}
        '';
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "30s";
        DynamicUser = true;
        SupplementaryGroups = [ "plugdev" ];
        RuntimeDirectory = "readsb";
        RuntimeDirectoryMode = "0755";
      };
    };

#    services.nginx = {
#      enable = mkDefault true;
#      virtualHosts."${cfg.hostName}" = {
#        locations = {
#          "/" = {
#            root = "${cfg.package}/share/dump1090";
#          };
#          "/data/" = {
#            root = "${cfg.writeJsonDir}";
#            extraConfig = ''
#              rewrite ^/data/(.*)$ /$1 break;
#            '';
#          };
#        };
#      };
#    };
  });
}
