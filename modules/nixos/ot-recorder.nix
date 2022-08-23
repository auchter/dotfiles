{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ot-recorder;
in {
  options.services.ot-recorder = {
    enable = mkEnableOption "OwnTracks Recorder";

    package = mkOption {
      default = pkgs.ot-recorder;
      defaultText = literalExpression "pkgs.ot-recorder";
      description = "Package to use";
      type = types.package;
    };

    vhost = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "vhost to serve on ";
    };

    reverseGeo = mkOption {
      default = false;
      type = types.bool;
      description = "Enable reverse-geo lookups";
    };

    mqttHost = mkOption {
      default = "localhost";
      description = "MQTT host";
      type = types.str;
    };

    mqttPort = mkOption {
      default = 0;
      description = "MQTT port";
      type = types.port;
    };

    httpHost = mkOption {
      default = "localhost";
      description = "HTTP host to bind to";
      type = types.str;
    };

    httpPort = mkOption {
      default = 8083;
      description = "HTTP port to bind to";
      type = types.port;
    };

    basicAuthFile = mkOption {
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ot-recorder = {
      description = "OwnTracks Recorder";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStartPre = ''
          ${cfg.package}/sbin/ot-recorder --init -S ''${STATE_DIRECTORY}
        '';
        ExecStart = ''
          ${cfg.package}/sbin/ot-recorder \
            -S ''${STATE_DIRECTORY} \
            ${optionalString (cfg.reverseGeo == false) "-G"} \
            --host ${cfg.mqttHost} --port ${toString cfg.mqttPort} \
            --http-host ${cfg.httpHost} --http-port ${toString cfg.httpPort} \
            --doc-root ${cfg.package}/share/htdocs \
        '';
        Type = "simple";
        Restart = "always";
        RestartSec = "30s";
        DynamicUser = true;
        StateDirectory = "ot-recorder";
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts."${cfg.vhost}" = {
	forceSSL = true;
	enableACME = true;
        basicAuthFile = cfg.basicAuthFile;
        locations = {
          "/" = {
            extraConfig = ''
              proxy_set_header Host $host;
              proxy_set_header X-Real-IP $remote_addr;
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header X-Forwarded-Proto $scheme;
            '';
            proxyPass = "http://${cfg.httpHost}:${toString cfg.httpPort}/";
            proxyWebsockets = true;
          };
        };
      };
    };
  };
}

