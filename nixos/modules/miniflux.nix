{ config, pkgs, ... }:

let
  vhost = "miniflux.phire.org";
in
{
  environment.systemPackages = with pkgs; [
    miniflux
  ];

  services.miniflux = {
    enable = true;
    config = {
      CLEANUP_FREQUENCY_HOURS = "48";
      LISTEN_ADDR = "127.0.0.1:9111";
      BASE_URL = "http://${vhost}/";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "${vhost}" = {
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
}
