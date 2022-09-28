{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.interfaces.eth0.useDHCP = true;
  modules.sshd.enable = true;

  sound.enable = true;

  modules.snapclient = {
    enable = true;
    host = "malphas";
    sampleFormat = "44100:16:*";
    soundcard = "front:CARD=adapter,DEV=0";
  };

  modules.brutefir = {
    enable = true;
    inputs = {
      "in" = {
        channels = 2;
        format = "S16_LE";
      };
    };
    outputs = {
      out = {
        channels = 2;
        format = "S16_LE";
      };
    };
    filters = {
      filter = {
        input = "in";
        output = "out";
      };
    };
    coeffs = {
      dirac.path = "dirac pulse";
      bed_door_open.path = ./brutefir/bed_door_open.wav;
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

