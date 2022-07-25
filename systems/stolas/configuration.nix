{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/base.nix
      ../../nixos/modules/airsonic.nix
      ../../nixos/modules/mta.nix
      ../../nixos/modules/smartd.nix
      ../../nixos/modules/plex.nix
      ../../nixos/modules/wg-client.nix
      ../../nixos/modules/radicale.nix
      ../../nixos/modules/restic.nix
    ];

  networking.interfaces.eno1.useDHCP = true;

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.restic_password = {};
  sops.secrets.restic_env = {};

  networking.wireguard.interfaces.wg0.ips = [ "10.100.0.3/24" ];

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

  services.nginx = {
    enable = true;
    virtualHosts = {
      "independent.phire.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8123";
          proxyWebsockets = true;
          extraConfig =
            "proxy_redirect off;" +
            "proxy_set_header Host $host;" +
            "proxy_set_header X-Real-IP $remote_addr;" +
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
            "proxy_set_header X-Forwarded-Proto $scheme;";
        };
      };
      "stolas.phire.org" = {
        forceSSL = true;
        enableACME = true;
        root = "/srv/stolas.phire.org";
      };
    };
  };

  virtualisation.oci-containers = {
    containers = {
      hass = {
        image = "homeassistant/home-assistant:2022.6.0";
        volumes = [
          "/home/a/.config/home-assistant:/config"
          "/etc/localtime:/etc/localtime:ro"
          "/mnt/storage/music:/media/music:ro"
          "/mnt/storage/videos:/media/videos:ro"
        ];
        extraOptions = [
          "--net=host"
        ];
      };
      zwavejs2mqtt = {
        image = "zwavejs/zwavejs2mqtt:6.10.0";
        volumes = [
          "/home/a/.config/zwavejs:/usr/src/app/store"
        ];
        ports = [
          "8091:8091"
          "3000:3000"
        ];
        extraOptions = [
          "--device=/dev/ttyACM0:/dev/zwave"
        ];
      };
      appdaemon = {
        image = "acockburn/appdaemon:4.2.1";
        volumes = [ "/home/a/.config/home-assistant/appdaemon:/conf" ];
        ports = [ "5050:5050" ];
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80 443 # nginx
    2049 # nfs
    139 445 # samba
    5050
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
