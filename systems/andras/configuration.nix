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

  networking.interfaces.wlan0.useDHCP = true;
  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
  };

  sound.enable = true;

  modules.snapclient = {
    enable = true;
    host = "malphas";
    sampleFormat = "44100:16:*";
    soundcard = "front:CARD=Audio,DEV=0";
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
        coeff = "bathroom";
      };
    };
    coeffs = {
      dirac.path = "dirac pulse";
      bathroom = {
        path = ./brutefir/bathroom.wav;
      };
    };
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

