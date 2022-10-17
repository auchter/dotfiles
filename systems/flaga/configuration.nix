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

  services.avahi = {
    enable = true;
    nssmdns = true;
  };

  services.home-assistant = {
    enable = true;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "rpi_power"
      "lifx"
      "wled"
      "zwave_js"
    ];

    config = {
      homeassistant = {
        name = "Home";
        unit_system = "imperial";
        time_zone = "America/Chicago";
      };
      default_config = {};
    };

    openFirewall = true;
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

