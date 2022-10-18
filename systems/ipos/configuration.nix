{ pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/miniflux.nix
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  modules.sshd.enable = true;

  modules.wireguard.server = {
    enable = true;
    externalInterface = "enp0s4";
  };

  modules.gocodes = {
    enable = true;
    vhost = "go.phire.org";
    siteMap = {
      hn = "https://news.ycombinator.com";
      liveoak = "https://liveoakbrewing.com/taproom/";
      pinthouse = "https://pinthouse.com/burnet/beer/beer-on-tap";
      zilker = "https://zilkerbeer.com/?v=47e5dceea252#seasonals-beer";
      spicyboys = "https://spicyboyschicken.square.site/?location=11eb52928bec852a8648ac1f6bbbd01e";
      cuantos = "https://www.cuantostacosaustin.com/s/order";
      betterhalf = "https://www.betterhalfbar.com/menu";
      dh = "https://www.draughthouse.com/drinks";
      workhorse = "https://workhorsebar.e-tab.com/workhorsebar/venue/5ea0812fad8074513197d76a/menu";
      chinafamily = "https://chinafamilytx.com/menu/64123353";
      holdout = "https://holdoutbrewing.com/menus";
      tlocs = "https://tlocs-hotdogs-103892-107872.square.site/";
      deedee = "https://deedeeatx.square.site/";
      oddwood = "https://www.oddwoodales.com/take-out-menu";
      batch = "https://www.toasttab.com/batch-craft-beer-kolaches/v3";
      bummer = "https://www.toasttab.com/little-brother-bar/v3/";
      meanwhile = "https://www.meanwhilebeer.com/beer";
    };
  };

  networking.interfaces.enp0s4.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial
    terminal_output serial
  '';

  services.soju = {
    enable = true;
    listen = [ "irc+insecure://10.100.0.1:6667" ];
    # Can remove once https://github.com/NixOS/nixpkgs/pull/184845 is merged
    tlsCertificate = null;
  };

  services.panopticon = {
    enable = true;
    vhost = "panopticon.phire.org";
  };

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

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
      };
      "tmp.phire.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/tmp.phire.org";
        };
      };
      "michau.ch" = {
        forceSSL = true;
        enableACME = true;
        locations."/".root = pkgs.writeTextDir "index.html" ''
          <!doctype html>
          <html lang="en">
            <head>
              <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
              <title>mich auch</title>
              <style>
                body {
                  font-family: monospace;
                  text-align: center;
                }
                .t {
                  font-variant: small-caps;
                }
                span svg {
                  float: center;
                  width: 30%;
                }
              </style>
            </head>
            <body>
              <span>
                <svg viewBox="0 0 190 60" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
                  <!-- main outline -->
                  <rect fill="#000" x="0" y="0" width="190" height="10" />
                  <rect fill="#000" x="0" y="10" width="10" height="40" />
                  <rect fill="#000" x="180" y="10" width="10" height="40" />
                  <rect fill="#000" x="0" y="50" width="190" height="10" />

                  <!-- m | -->
                  <rect fill="#000" x="20" y="20" width="10" height="30" />
                  <rect fill="#000" x="40" y="20" width="10" height="30" />
                  <rect fill="#000" x="60" y="10" width="10" height="40" />

                  <!-- m | -->
                  <rect fill="#000" x="80" y="20" width="10" height="30" />
                  <rect fill="#000" x="100" y="20" width="10" height="30" />
                  <rect fill="#000" x="120" y="10" width="10" height="40" />

                  <!-- a -->
                  <rect fill="#000" x="140" y="20" width="30" height="10" />
                  <rect fill="#000" x="140" y="40" width="30" height="10" />
                </svg>
              </span>
            </body>
          </html>
        '';
      };
    };
  };

  modules.logo-site.logo = ../../logos/ipos.png;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
