{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.panopticon;
in {
  options.services.panopticon = {
    enable = mkEnableOption "enable panopticon";
    package = mkOption {
      default = pkgs.panopticon;
      type = types.package;
    };

    vhost = mkOption {
      type = types.str;
    };

    port = mkOption {
      type = types.int;
      default = 1292;
    };
  };

  config = mkIf (cfg.enable) {
    systemd.services.panopticon = {
      description = "Panopticon";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/panopticon --port ${toString cfg.port}
        '';
        Type = "simple";
        Restart = "always";
        RestartSec = 300;
        DynamicUser = true;
      };
    };

    services.nginx = {
      enable = true;
      virtualHosts = {
        "${cfg.vhost}" = {
          forceSSL = true;
          enableACME = true;
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString cfg.port}";
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
  };
}
