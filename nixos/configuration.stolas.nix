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

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = PHIRE
      server string = stolas
      netbios name = stolas
      security = user
      hosts allow = 192.168.1.0/24 localhost
      guest account = nobody
    '';
    shares = {
      music = {
        path = "/export/music";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
      };
    };
  };

  virtualisation.docker.enable = true;
  docker-containers.hass = {
    image = "homeassistant/home-assistant@sha256:97219675e8e619be2bf56065d1a87c1a3670987d296f2e27984396813ba84367";
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
    139 445 # samba
  ];

  networking.firewall.allowedUDPPorts = [
    137 138 # samba
  ];
}
