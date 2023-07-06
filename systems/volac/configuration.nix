{ config, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.device = "nodev";

  networking.interfaces.enp0s31f6.useDHCP = true;
  modules.sshd.enable = true;

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/6f4bc97f-bdfb-40c2-bd9e-aec97b31ab6f";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    extraConfig = ''
      workgroup = PHIRE
      server string = ${config.networking.hostName}
      netbios name = ${config.networking.hostName}
      security = user
      hosts allow = 192.168.0.0/24 localhost
      guest account = nobody
    '';
    shares = {
      photos = {
        path = "/mnt/storage/photos";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "yes";
      };
    };
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  modules.wireguard.client = {
    enable = false;
    server = "ipos";
  };

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
    openFirewall = true;
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

  modules.logo-site.logo = ../../logos/volac.png;

  system.stateVersion = "23.05"; # Did you read the comment?
}

