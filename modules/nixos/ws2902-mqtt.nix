{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ws2902-mqtt;
in {
  meta.maintainers = with maintainers; [ auchter ];

  options.services.ws2902-mqtt = {
    enable = mkEnableOption "enable ws2902-mqtt service";

    package = mkOption {
      description = "ws2902-mqtt package to use";
      default = pkgs.ws2902-mqtt;
      defaultText = literalExpression "pkgs.ws2902-mqtt";
      type = types.package;
    };

    mqttHost = mkOption {
      description = "mqtt broker host to connect to";
      default = "localhost";
      type = types.str;
    };

    mqttPort = mkOption {
      description = "mqtt broker port to connect to";
      default = 1883;
      type = types.port;
    };

    httpPort = mkOption {
      description = "port to serve http endpoint on";
      default = 8543;
      type = types.port;
    };
  };

  config = mkIf (cfg.enable) {
    systemd.services.ws2902-mqtt = {
      description = "MQTT bridge for WS-2902";
      after = [ "network.target" "mosquitto.service" ];
      wants = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/ws2902-mqtt \
            --mqtt-host ${cfg.mqttHost} \
            --mqtt-port ${toString cfg.mqttPort} \
            --port ${toString cfg.httpPort} \
        '';
        Type = "simple";
        Restart = "always";
        RestartSec = 30;
        DynamicUser = true;
      };
    };
  };
}
