{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./base.nix
      ./users.nix
      ./miniflux.nix
    ];

  networking.hostName = "ipos";
  networking.domain = "phire.org";
  networking.useDHCP = false;
  networking.interfaces.enp0s4.useDHCP = true;
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  boot.kernelParams = [ "console=ttyS0,19200n8" ];
  boot.loader.grub.extraConfig = ''
    serial --speed=19200 --unit=0 --word=8 --parity=no --stop=1;
    terminal_input serial
    terminal_output serial
  '';

  boot.loader.grub.device = "nodev";
  boot.loader.timeout = 10;

  security.acme.acceptTerms = true;
  security.acme.email = "michael.auchter@gmail.com";
  services.nginx = {
    enable = true;
    virtualHosts = {
      "phire.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www/phire.org";
        };
      };
    };
  };
}
