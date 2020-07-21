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

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/6df923c0-ad42-4ef7-a5b8-eed82ef98aca";
    fsType = "ext4";
  };

  fileSystems."/export/music" = {
    device = "/mnt/storage/music";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export/music 192.168.1.0/24(ro,no_subtree_check)
  '';

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

  networking.firewall.allowedTCPPorts = [
    8123 # home-assistant
    2049 # nfs
  ];
}
