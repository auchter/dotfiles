{ config, pkgs, options, lib, ... }:

{
  imports = [
    ./users.nix
  ];

  time.timeZone = "UTC";

  networking = {
    domain = "phire.org";
    search = [ config.networking.domain ];
  };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  services.sshguard.enable = true;

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
}
