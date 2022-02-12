{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./modules/base.nix
      ./modules/flakes.nix
      ./modules/users.nix
      ./modules/soulseek.nix
      ./modules/syncthing.nix
      ./modules/dev.nix
      ./modules/mpd-client.nix
      ./modules/laptop.nix
      ./modules/unfree.nix
      ./modules/home-manager.nix
      ./modules/geoclue.nix
#      <nix-ld/modules/nix-ld.nix>
    ];

  networking.hostName = "moloch";
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  fileSystems = lib.listToAttrs (
    map (name:
      lib.nameValuePair "/n/orobas/${name}" {
        device = "orobas.local.phire.org:/export/${name}";
        fsType = "nfs";
        options = [
          "nfsvers=4.2"
          "x-systemd.automount"
          "x-systemd.idle-timeout=600"
          "noauto"
        ];
      })
    [ "music" "videos" "personal" ]
  );

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices = {
    root = {
      device = "/dev/nvme0n1p2";
      preLVM = true;
      allowDiscards = true;
    };
  };

  environment.systemPackages = with pkgs; [
    home-assistant-cli
  ];

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
