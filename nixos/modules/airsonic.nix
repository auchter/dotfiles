{ config, ... }:

{
  services.airsonic = {
    enable = true;
    maxMemory = 2048;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "airsonic.phire.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:" + builtins.toString config.services.airsonic.port;
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
