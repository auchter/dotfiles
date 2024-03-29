{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.radicale;
in {
  options.modules.radicale = {
    enable = mkEnableOption "enable radicale and https proxy";
    vhost = mkOption {
      type = types.str;
      description = "vhost for radicale";
    };
    port = mkOption {
      type = types.port;
      description = "internal port to use";
      default = 5232;
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.radicale_htpasswd = {
      owner = config.users.users.radicale.name;
    };

    services.radicale = {
      enable = true;
      settings = {
        auth = {
          type = "htpasswd";
          htpasswd_filename = config.sops.secrets.radicale_htpasswd.path;
          htpasswd_encryption = "plain";
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
            proxyPass = "http://localhost:${toString cfg.port}/";
            extraConfig =
              "proxy_redirect off;" +
              "proxy_set_header Host $host;" +
              "proxy_set_header X-Script-Name /;" +
              "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
              "proxy_set_header X-Forwarded-Proto $scheme;" +
              "proxy_pass_header Authorization;";
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
  };
}
