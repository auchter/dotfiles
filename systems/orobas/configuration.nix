{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/mpd.nix
      ../../nixos/modules/mta.nix
      ../../nixos/modules/smartd.nix
      ../../nixos/modules/unifi.nix
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  modules.wireguard.client = {
    enable = true;
    server = "ipos";
  };

  modules.sshd.enable = true;

  services.fail2ban.ignoreIP = [ "192.168.0.0/24" ];

  networking.interfaces.enp0s10.useDHCP = true;
  networking.dhcpcd.persistent = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdb";

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/e56a3505-1ec1-4623-845f-b307b6a42e9d";
    fsType = "ext4";
  };

  modules.bindmounts.mounts = {
    "/export/music" = "/mnt/storage/music";
    "/export/films" = "/mnt/storage/films";
    "/export/tv" = "/mnt/storage/tv"
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export/music 192.168.0.0/24(ro,no_subtree_check) 192.168.10.0/24(ro,no_subtree_check)
    /export/tv 192.168.0.0/24(ro,no_subtree_check)
    /export/films 192.168.0.0/24(ro,no_subtree_check)
  '';

  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = PHIRE
      server string = orobas
      netbios name = orobas
      security = user
      hosts allow = 192.168.0.0/24 localhost
      guest account = nobody
    '';
    shares = {
      music = {
        path = "/export/music";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
      };
      tv = {
        path = "/export/tv";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
      };
      films = {
        path = "/export/films";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
      };
    };
  };

  services.mpd = {
    musicDirectory = "/mnt/storage/music";
    extraConfig = ''
      log_file "syslog"
    '';
  };

  networking.firewall.allowedTCPPorts = [
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
  system.stateVersion = "21.11"; # Did you read the comment?

}
