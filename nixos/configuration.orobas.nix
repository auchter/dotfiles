{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./modules/base.nix
      ./modules/users.nix
    ];

  networking.hostName = "orobas";
  networking.useDHCP = false;
  networking.vlans = {
    vlan_iot = {
      id = 10;
      interface = "enp0s10";
    };
  };

  services.fail2ban.ignoreIP = [ "192.168.0.0/24" ];

  networking.interfaces.enp0s10.useDHCP = true;
  networking.interfaces.vlan_iot.useDHCP = true;

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sdb";

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/e56a3505-1ec1-4623-845f-b307b6a42e9d";
    fsType = "ext4";
  };

  fileSystems."/export/music" = {
    device = "/mnt/storage/music";
    options = [ "bind" ];
  };

  fileSystems."/export/films" = {
    device = "/mnt/storage/films";
    options = [ "bind" ];
  };

  fileSystems."/export/tv" = {
    device = "/mnt/storage/tv";
    options = [ "bind" ];
  };

  services.nfs.server.enable = true;
  services.nfs.server.exports = ''
    /export/music 192.168.0.0/24(ro,no_subtree_check)
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
