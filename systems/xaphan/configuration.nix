{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  modules.sshd.enable = true;
  modules.interactive.enable = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}

