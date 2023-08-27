{ pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
    ];

  powerManagement.powertop.enable = true;

  modules.sshd.enable = true;
  modules.soulseek.enable = true;
  modules.wifi = {
    enable = true;
    interfaces = [ "wlp0s20f3" ];
  };

  modules.interactive.enable = true;
#  modules.wireguard.client = {
#    enable = true;
#    server = "ipos";
#  };

  virtualisation.docker.enable = true;

  environment.systemPackages = [
    pkgs.git-crypt
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "23.05"; # Did you read the comment?
}
