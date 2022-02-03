{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./base.nix
      ./users.nix
      ./modules/acme.nix
    ];

  networking.hostName = "ipos";
  networking.useDHCP = false;
  networking.interfaces.enp0s4.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial
    terminal_output serial
  '';

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  environment.systemPackages = with pkgs; [
    miniflux
  ];

  services.miniflux = {
    enable = true;
    config = {
      CLEANUP_FREQUENCY_HOURS = "48";
      LISTEN_ADDR = "127.0.0.1:9111";
      BASE_URL = "http://phire.org/miniflux/";
    };
  };

  services.grocy = {
    enable = true;
    hostName = "grocy.phire.org";
  };

  services.gotify = {
    enable = true;
    port = 9812;
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "auchter.phire.org" = {
        forceSSL = true;
        enableACME = true;
        root = "/var/www/auchter.phire.org";
      };
      "phire.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/phire.org";
        };
        locations."/miniflux/" = {
          proxyPass = "http://" + config.services.miniflux.config.LISTEN_ADDR;
          proxyWebsockets = true;
          extraConfig =
            "proxy_redirect off;" +
            "proxy_set_header Host $host;" +
            "proxy_set_header X-Real-IP $remote_addr;" +
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
            "proxy_set_header X-Forwarded-Proto $scheme;";
        };
        locations."/gotify/" = {
          proxyPass = "http://localhost:" + builtins.toString config.services.gotify.port;
          proxyWebsockets = true;
          extraConfig =
            "proxy_redirect off;" +
            "rewrite ^/gotify(/.*) $1 break;" +
            "proxy_set_header Host $host;" +
            "proxy_set_header X-Real-IP $remote_addr;" +
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
            "proxy_set_header X-Forwarded-Proto $scheme;";
        };
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
