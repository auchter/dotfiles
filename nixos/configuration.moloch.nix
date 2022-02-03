{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./modules/base.nix
      ./modules/users.nix
      ./modules/mail.nix
      ./modules/sway.nix
      ./modules/syncthing.nix
#      <nix-ld/modules/nix-ld.nix>
    ];


  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  networking.hostName = "moloch";
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  networking.firewall.allowedTCPPorts = [
    2234 8000
  ];

  fileSystems = {
    "/n/orobas/films" = {
      device = "orobas.local.phire.org:/export/films";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
      ];
    };
    "/n/orobas/tv" = {
      device = "orobas.local.phire.org:/export/tv";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
      ];
    };
    "/n/orobas/music" = {
      device = "orobas.local.phire.org:/export/music";
      fsType = "nfs";
      options = [
        "nfsvers=4.2"
        "x-systemd.automount"
        "x-systemd.idle-timeout=600"
        "noauto"
      ];
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
      allowDiscards = true;
    };
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.bluetooth.enable = true;

  powerManagement.powertop.enable = true;

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
