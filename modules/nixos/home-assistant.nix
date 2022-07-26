{ config, lib, ... }:

with lib;

let
  cfg = config.modules.home-assistant;
in {
  options.modules.home-assistant = {
    enable = mkEnableOption "home-assistant";
    vhost = mkOption {
      type = types.str;
      description = "vhost for nginx proxy";
    };
    configDir = mkOption {
      type = types.str;
      description = "config dir for home-assistant";
    };
    appdaemon = {
      enable = mkEnableOption "enable appdaemon";
    };
    zwavejs = {
      enable = mkEnableOption "enable zwave";
      adapter = mkOption {
        type = types.str;
        description = "Path of zwave adapter";
      };
      configDir = mkOption {
        type = types.str;
        description = "zwavejs config dir";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.oci-containers = {
      containers = {
        hass = {
          image = "homeassistant/home-assistant:2022.6.0";
          volumes = [
            "${cfg.configDir}:/config"
            "/etc/localtime:/etc/localtime:ro"
          ];
          extraOptions = [
            "--net=host"
          ];
        };
        zwavejs2mqtt = mkIf cfg.zwavejs.enable {
          image = "zwavejs/zwavejs2mqtt:6.10.0";
          volumes = [
            "${cfg.zwavejs.configDir}:/usr/src/app/store"
          ];
          ports = [
            "8091:8091"
            "3000:3000"
          ];
          extraOptions = [
            "--device=${cfg.zwavejs.adapter}:/dev/zwave"
          ];
        };
        appdaemon = mkIf cfg.appdaemon.enable {
          image = "acockburn/appdaemon:4.2.1";
          volumes = [ "${cfg.configDir}/appdaemon:/conf" ];
          ports = [ "5050:5050" ];
        };
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.vhost}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:8123";
            proxyWebsockets = true;
            extraConfig =
              "proxy_redirect off;" +
              "proxy_set_header Host $host;" +
              "proxy_set_header X-Real-IP $remote_addr;" +
              "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
              "proxy_set_header X-Forwarded-Proto $scheme;";
            };
          };
        };
      };

      networking.firewall.allowedTCPPorts = [
        80 443 # nginx
        8123 # home-assistant
        1400 # home-assistant / sonos
        5050 # appdaemon
      ];
    };
}
