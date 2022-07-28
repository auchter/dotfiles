{ config, pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
      ../../nixos/modules/soulseek.nix
      ../../nixos/modules/syncthing.nix
      ../../nixos/modules/laptop.nix
      ../../nixos/modules/wg-client.nix
      ../../nixos/modules/wifi.nix
      ../../nixos/modules/restic.nix
    ];

  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp2s0.useDHCP = true;

  networking.wireguard.interfaces.wg0.ips = [ "10.100.0.2/24" ];

  networking.wireless = {
    enable = true;
    interfaces = [ "wlp2s0" ];
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.restic_password = {};
  sops.secrets.restic_env = {};

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

  services.restic.backups.backblaze = {
    paths = [
      "/home/a/photos"
      "/home/a/Maildir"
      "/home/a/obsidian"
      "/home/a/proj"
    ];
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

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.bluetooth.enable = true;

  virtualisation.docker.enable = true;

  home-manager.users.a = {
    programs.notmuch.enable = true;
    programs.neomutt.enable = true;
    programs.msmtp.enable = true;
    programs.offlineimap.enable = true;
    programs.lieer.enable = true;
    programs.alot.enable = true;

    home.sessionVariables = {
      HASS_SERVER = "https://home.phire.org";
      HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
      MPD_HOST = "phire-preamp";
    };
  };

  systemd.user.services.vdirsyncer = {
    description = "vdirsyncer sync";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    };
  };

  systemd.user.timers.vdirsyncer = {
    description = "vdirsyncer sync";
    timerConfig = {
      OnCalendar = "*:0/5";
      Unit = "vdirsyncer.service";
    };
    wantedBy = [ "default.target" ];
  };

  # systemd doesn't support recursive directory watches.
  # could watch each specific directory instead, though...
  #systemd.user.paths.vdirsyncer = {
  #  pathConfig = {
  #    Unit = "vdirsyncer.service";
  #    PathChanged = [ "${config.users.users.a.home}/.calendars" "${config.users.users.a.home}/.contacts" ];
  #  };
  #  wantedBy = [ "default.target" ];
  #};

  services.offlineimap = {
    enable = true;
    install = true;
  };

  # HACK: globally enable sway instead of relying on home-manager to ensure /etc/pam.d/swaylock gets installed
  programs.sway.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
