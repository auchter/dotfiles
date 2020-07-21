{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./base.nix
      ./users.nix
    ];

  networking.hostName = "stolas";
  networking.domain = "phire.org";
  networking.useDHCP = false;
  networking.interfaces.eno1.useDHCP = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fail2ban.ignoreIP = [ "192.168.1.0/24" ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  virtualisation.docker.enable = true;
  docker-containers.hass = {
    image = "homeassistant/home-assistant:stable";
    volumes = [
      "/home/a/.config/home-assistant:/config"
      "/etc/localtime:/etc/localtime:ro"
    ];
    extraDockerOptions = [
      "--net=host"
      "--device=/dev/ttyACM0"
    ];
  };

  networking.firewall.allowedTCPPorts = [ 8123 ];
}
