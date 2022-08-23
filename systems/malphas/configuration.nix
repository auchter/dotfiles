{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPatches = [
    {
      name = "preamp dts";
      patch = ./0001-arm64-dts-add-device-tree-for-preamp.patch;
      extraConfig = ''
        GPIO_PCF857X y
      '';
    }
    { # really should just merge this into the above...
      name = "gpio line names";
      patch = ./0002-add-line-names.patch;
    }
  ];

  networking.interfaces.eth0.useDHCP = true;
  modules.sshd.enable = true;

  system.stateVersion = "22.05"; # Did you read the comment?
}

