{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/mta.nix
      ../../nixos/modules/smartd.nix
      ../../nixos/modules/radicale.nix
      ../../nixos/modules/restic.nix
    ];

  networking.interfaces.eno1.useDHCP = true;

  modules.logo-site = {
    logo = ./stolas.png;
  };

  modules.wireguard.client = {
    enable = true;
    server = "ipos";
  };

  modules.airsonic = {
    enable = true;
    host = "airsonic.phire.org";
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  modules.home-assistant = {
    enable = true;
    vhost = "independent.phire.org";
    configDir = "/home/a/.config/home-assistant";
    appdaemon = {
      enable = true;
    };
    zwavejs = {
      enable = true;
      adapter = "/dev/ttyACM0";
      configDir = "/home/a/.config/zwavejs";
    };
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.restic_password = {};
  sops.secrets.restic_env = {};

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fail2ban.ignoreIP = [ "192.168.1.0/24" ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  services.restic.backups.backblaze.paths = [
    "/mnt/storage/photos"
    "/var/lib/radicale"
    "/mnt/storage/music"
  ];

  environment.systemPackages = with pkgs; [
    beets
  ];

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/6df923c0-ad42-4ef7-a5b8-eed82ef98aca";
    fsType = "ext4";
  };

  fileSystems."/export/music" = {
    device = "/mnt/storage/music";
    options = [ "bind" ];
  };

  fileSystems."/export/photos" = {
    device = "/mnt/storage/photos";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export/music 192.168.1.0/24(ro,no_subtree_check)
    /export/photos 192.168.1.0/24(ro,no_subtree_check)
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

  services.minidlna = {
    enable = true;
    mediaDirs = [
      "/mnt/storage/music"
      "/mnt/storage/videos"
    ];
  };

  networking.firewall.allowedTCPPorts = [
    80 443 # nginx
    2049 # nfs
    139 445 # samba
    8200 # minidlna
  ];

  networking.firewall.allowedUDPPorts = [
    137 138 # samba
    1900 # minidlna
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
