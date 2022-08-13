{ config, pkgs, options, lib, ... }:

{
  imports = [
    ./fail2ban.nix
    ./users.nix
    ./sops.nix
  ];

  time.timeZone = "UTC";

  networking = {
    domain = "phire.org";
    search = [ config.networking.domain ];
  };

  security = {
    acme = {
      acceptTerms = true;
      defaults.email = "michael.auchter@gmail.com";
    };
  };

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "google-chrome"
    "obsidian"
    "plexmediaserver"
    "roomeqwizard"
    "unifi-controller"
  ];

  networking.useDHCP = false;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
