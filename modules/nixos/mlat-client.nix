{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.mlat-client;
in {
  meta.maintainers = with maintainers; [ auchter ];

  options.services.mlat-client = {
    enable = mkEnableOption "Mode S Multilateration Client";

    package = mkOption {
      default = pkgs.mlat-client;
      defaultText = literalExpression "pkgs.mlat-client";
      description = "Package to install";
      type = types.package;
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

    altitude = mkOption {
      description = "Reference/receiver altitude";
      type = types.float;
      default = null;
    };

    privacy = mkOption {
      description = "Set privacy flag. Removes receiver location from coverage maps";
      type = types.bool;
      default = false;
    };

    uuid = mkOption {
      example = "eacb6bab-f444-4ebf-a06a-3f72d7465e41";
      type = types.nullOr types.str;
      description = "UUID to identify instance. Can be generated with uuidgen.";
      default = null;
    };

    host = mkOption {
      type = types.str;
      description = "Multilateration server to connect to";
    };

    port = mkOption {
      type = types.port;
      description = "Port to connect to on multilateration server";
    };

    user = mkOption {
      type = types.str;
      description = "User information to give to server";
    };

    udp = mkOption {
      type = types.bool;
      description = "Offer to use UDP transport for sync/mlat messages";
      default = false;
    };

    input = {
      type = mkOption {
        description = "Sets the receiver input type";
        type = types.enum [
          "auto"
          "dump1090"
          "beast"
          "radarcape_12mhz"
          "radarcape_gps"
          "radarcape"
          "sbs"
          "avrmlat"
        ];
        default = "dump1090";
      };

      host = mkOption {
        description = "Host to connect to for Mode S traffic";
        type = types.str;
        default = "localhost";
      };

      port = mkOption {
        description = "Port to connect to on host for Mode S traffic";
        type = types.port;
        default = 30005;
      };
    };

    results = {
      connect = mkOption {
        description = "Results output connect";
        default = [];
        type = types.listOf (types.submodule {
          options = {
            protocol = mkOption {
              description = "Protocol to use";
              type = types.enum [
                "basestation"
                "beast"
                "ext_basestation"
              ];
            };

            host = mkOption {
              description = "Host to send results to";
              type = types.str;
            };

            port = mkOption {
              description = "Port on host to send results to";
              type = types.port;
            };
          };
        });
      };
      listen = mkOption {
        description = "Results output listener";
        default = [];
        type = types.listOf (types.submodule {
          options = {
            protocol = mkOption {
              description = "Protocol to use";
              type = types.enum [
                "basestation"
                "beast"
                "ext_basestation"
              ];
            };

            port = mkOption {
              description = "Port to listen on";
              type = types.port;
            };
          };
        });
      };
    };
  };

  config = mkIf cfg.enable (
    let
      uuidFile = pkgs.writeText "uuidFile" (toString cfg.uuid);
      mkResultsConnect = x: "--results ${x.protocol},connect,${x.host}:${toString x.port}";
      mkResultsListen = x: "--results ${x.protocol},listen,${toString x.port}";
    in {
      systemd.services.mlat-client = {
        description = "Mode S Multilateration Client";
        after = [ "network.target" ];
        wants = [ "network.target" ];
        wantedBy = [ "default.target" ];
        serviceConfig = {
          ExecStart = ''
            ${cfg.package}/bin/mlat-client \
              --server=${cfg.host}:${toString cfg.port} \
              --user=${cfg.user} \
              ${optionalString (cfg.udp == false) "--no-udp"} \
              --lat=${toString cfg.latitude} \
              --lon=${toString cfg.longitude} \
              ${optionalString (cfg.altitude != null) "--alt=${toString cfg.altitude}"} \
              ${optionalString cfg.privacy "--privacy"} \
              ${optionalString (cfg.uuid != null) "--uuid-file=${uuidFile}"} \
              --input-type ${cfg.input.type} \
              --input-connect ${cfg.input.host}:${toString cfg.input.port} \
              ${concatMapStringsSep " " mkResultsConnect cfg.results.connect} \
              ${concatMapStringsSep " " mkResultsListen cfg.results.listen}
          '';
          Type = "simple";
          Restart = "always";
          RestartSec = "30s";
        };
      };
    });
}
