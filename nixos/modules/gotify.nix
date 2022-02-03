{ config, ... }:

{
  services.gotify = {
    enable = true;
    port = 9812;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "gotify.phire.org" = {
        locations."/" = {
          proxyPass = "http://localhost:" + builtins.toString config.services.gotify.port;
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
}
