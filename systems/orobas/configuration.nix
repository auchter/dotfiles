{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  #modules.wireguard.client = {
  #  enable = true;
  #  server = "ipos";
  #};

  modules.sshd.enable = true;

  services.fail2ban.ignoreIP = [ "192.168.0.0/24" ];

  networking.interfaces.enp5s0.useDHCP = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
