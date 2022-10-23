{ config, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  modules.sshd.enable = true;

  system.stateVersion = "22.05"; # Did you read the comment?
}

