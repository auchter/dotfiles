{ config, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/mta.nix
      ../../nixos/modules/smartd.nix
      ../../nixos/modules/radicale.nix
    ];

  networking.interfaces.eno1.useDHCP = true;

  modules.sshd.enable = true;

  modules.logo-site = {
    logo = ../../logos/stolas.png;
  };

  modules.wireguard.client = {
    enable = true;
    server = "ipos";
  };

  modules.airsonic = {
    enable = false;
    host = "airsonic.phire.org";
  };

  services.plex = {
    enable = true;
    openFirewall = true;
  };

  modules.syncthing = {
    enable = true;
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

  modules.photoprism = {
    enable = true;
    instances = {
      family = {
        port = 2342;
        vhost = "family.photos.phire.org";
        storageDir = "/var/lib/photoprism";
        originalsDir = "/mnt/storage/photoprism/originals";
        importDir = "/mnt/storage/photoprism/import";
      };
      personal = {
        port = 2343;
        vhost = "photos.phire.org";
        storageDir = "/var/lib/photoprism-personal";
        originalsDir = "/mnt/storage/personal/originals";
        importDir = "/mnt/storage/personal/import";
      };
    };
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fail2ban.ignoreIP = [ "192.168.1.0/24" ];

  nix.settings.max-jobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  sops.secrets.owntracks_htpasswd = {
    owner = config.users.users.nginx.name;
  };

  services.ot-recorder = {
    enable = true;
    vhost = "owntracks.phire.org";
    basicAuthFile = config.sops.secrets.owntracks_htpasswd.path;
  };

  modules.restic = {
    enable = true;
    cloudPaths = [
      "/mnt/storage/photos"
      "/var/lib/radicale"
      "/var/lib/ot-recorder"
      "/mnt/storage/music"
      "/mnt/storage/scanned"
      "/mnt/storage/photoprism/originals"
      "/var/lib/photoprism"
      "/mnt/storage/personal/originals"
      "/var/lib/photoprism-personal"
    ];
  };

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/6df923c0-ad42-4ef7-a5b8-eed82ef98aca";
    fsType = "ext4";
  };

  modules.bindmounts.mounts = {
    "/export/music" = "/mnt/storage/music";
    "/export/photos" = "/mnt/storage/photos";
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
    openFirewall = true;
    settings = {
      media_dir = [
        "A,/mnt/storage/music"
        "V,/mnt/storage/videos"
      ];
    };
  };

  sops.secrets.beetstream_config = { };
  modules.beetstream = {
    enable = true;
    vhost = "beetstream.phire.org";
    configFile = config.sops.secrets.beetstream_config.path;
  };

  networking.firewall.allowedTCPPorts = [
    80 443 # nginx
    2049 # nfs
    139 445 # samba
  ];

  networking.firewall.allowedUDPPorts = [
    137 138 # samba
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}
