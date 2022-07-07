{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../nixos/modules/base.nix
      ../../nixos/modules/users.nix
      ../../nixos/modules/acme.nix
      ../../nixos/modules/unifi.nix
      ../../nixos/modules/unfree.nix
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  networking.hostName = "volac";
  networking.interfaces.eth0.useDHCP = true;

  services.home-assistant = {
    enable = true;
    config = null;
  };

  networking.firewall.allowedTCPPorts = [
    8123
  ];

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

