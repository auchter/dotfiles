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

  networking.firewall.allowedTCPPorts = [
    8543 # port for weather station access
  ];

  services.mosquitto = {
    enable = true;
    listeners = [ {
      acl = [ "pattern readwrite #" ];
      omitPasswordAuth = true;
      settings.allow_anonymous = true;
    } ];
  };

  services.ws2902-mqtt = {
    enable = true;
  };

  modules.home-assistant = {
    enable = true;
    vhost = "cottage.phire.org";
    configDir = "/var/lib/home-assistant";
  };

  hardware.rtl-sdr.enable = true;

  modules.ads-b = {
    enable = true;
    latitude = 43.981064;
    longitude = -83.181330;
    altitude = 183.0;
    uuid = "6a97aa61-e1b4-4185-9225-c67306e5f968";
    siteName = "caseville";
    vhost = "caseville.phire.org";
  };

  # Temporary...
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCzIue421fOG3rtf/OrysL6lbGYuyavrZtQEPgXNkeYqQmBcHTGBujhXkr6fXVB+l4I2E+eWz+vyDD0JZWYZYeyyFSTS6yArIH+sEdEFzqNjQ+H0td5sEfysZfOkeGSKwNhnSKl5yVFkIn3DE3igCS97CqNBGf2kBLX//BGvgrvGLVvDIv6x0hUhNjHyTcth510sRi3TTcDb+GwNQqHyl9K/gtQFXVNVXg1bxGhzDD+NFARHiaPys6/QHP3N2X6KJV+1L3Of/w2+YLNPhRaJMBw3C4nrNoC/vPbH0m2pO3JhfILW7f7EgZSfp82vEO2XGuKbMc+1tXUaInA6Gy889f1 a@moloch.phire.org"
    ];
  };

  system.stateVersion = "22.05"; # Did you read the comment?
}

