{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.miniflux;
in {
  options.modules.miniflux = {
    enable = mkEnableOption "Enable miniflux and proxy";
    vhost = mkOption {
      description = "hostname for miniflux";
      type = types.str;
    };
    port = mkOption {
      description = "Internal port to bind to";
      type = types.port;
      default = 9111;
    };
  };

  config = mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      config = {
        CLEANUP_FREQUENCY_HOURS = "48";
        LISTEN_ADDR = "127.0.0.1:${toString cfg.port}";
        BASE_URL = "http://${cfg.vhost}/";
      };
      adminCredentialsFile = "/etc/nixos/miniflux-admin-credentials";
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.vhost}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://" + config.services.miniflux.config.LISTEN_ADDR;
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

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
