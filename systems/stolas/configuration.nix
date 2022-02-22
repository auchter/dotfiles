{ config, lib, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../../nixos/modules/base.nix
      ../../nixos/modules/users.nix
      ../../nixos/modules/acme.nix
      ../../nixos/modules/airsonic.nix
      ../../nixos/modules/ikiwiki.nix
      ../../nixos/modules/mta.nix
      ../../nixos/modules/smartd.nix
      ../../nixos/modules/gitolite.nix
      ../../nixos/modules/plex.nix
      ../../nixos/modules/unfree.nix
      ../../nixos/modules/wg-client.nix
    ];

  networking.hostName = "stolas";
  networking.interfaces.eno1.useDHCP = true;

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  networking.wireguard.interfaces.wg0.ips = [ "10.100.0.3/24" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.fail2ban.ignoreIP = [ "192.168.1.0/24" ];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

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
        image = "homeassistant/home-assistant:2021.5.5";
        volumes = [
          "/home/a/.config/home-assistant:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        extraOptions = [
          "--net=host"
          "--device=/dev/ttyACM0"
        ];
      };
    };
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
