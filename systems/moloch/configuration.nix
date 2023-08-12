{ pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
    ];

  networking.interfaces.enp0s31f6.useDHCP = true;

  modules.embedded = {
    enable = false;
    interface = "enp59s0u2u3";
  };

  modules.sshd.enable = true;
  modules.soulseek.enable = true;
  modules.interactive.enable = true;

  modules.wireguard.client = {
    enable = true;
    server = "ipos";
  };

  modules.wifi = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  modules.restic = {
    enable = true;
    cloudPaths = [
      "/home/a/photos"
      "/home/a/Maildir"
      "/var/lib/syncthing/obsidian"
      "/home/a/proj"
    ];
  };

  modules.syncthing = {
    enable = true;
  };

  powerManagement.powertop.enable = true;

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.git-crypt
  ];

  system.stateVersion = "21.11";
}
