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

  modules.wifi = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks = [ "pH" ];
  };

  modules.snapclient = {
    enable = true;
    sampleFormat = "44100:16:*";
    soundcard = "front:CARD=Audio,DEV=0";
    mixer = "hardware:PCM";
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

