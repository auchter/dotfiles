{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    beets
    fcgiwrap
    spawn_fcgi
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      "a.phire.org" = {
        forceSSL = true;
        enableACME = true;
        root = "/srv/a.phire.org";
        locations = {
          "/ikiwiki.cgi" = {
            extraConfig = ''
              fastcgi_pass  unix:/tmp/ikiwiki.socket;
              fastcgi_index ikiwiki.cgi;
              fastcgi_param SCRIPT_FILENAME   /srv/a.phire.org/ikiwiki.cgi;
              fastcgi_param DOCUMENT_ROOT      /srv/a.phire.org;
              include ${pkgs.nginx}/conf/fastcgi_params;
            '';
          };
        };
      };
    };
  };

  systemd.services.ikiwiki = {
    description = "ikiwiki";
    documentation = [ "" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      User = "nginx";
      Group = "nginx";
      ExecStart = ''
        ${pkgs.spawn_fcgi}/bin/spawn-fcgi -s /tmp/ikiwiki.socket -n -- ${pkgs.fcgiwrap}/bin/fcgiwrap
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
