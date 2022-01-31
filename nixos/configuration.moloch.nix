{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      ./base.nix
      ./users.nix
      ./mail.nix
      ./syncthing.nix
#      <nix-ld/modules/nix-ld.nix>
    ];

  networking.hostName = "moloch";
  networking.domain = "phire.org";
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

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      grim
      kanshi
      mako
      slurp
      swayidle
      swaylock
      waybar
      xwayland
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "google-chrome"
    "obsidian"
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    bc
    brightnessctl
    dmenu
    feh
    google-chrome
    i3blocks
    mpv
    mupdf
    ncmpc
    notify-desktop
    obsidian
    powertop
    qutebrowser
    signal-desktop
    snapcast
    usbutils
    wireshark
    wob
    (
      pkgs.writeTextFile {
        name = "startsway";
        destination = "/bin/startsway";
        executable = true;
        text = ''
          #! ${pkgs.bash}/bin/bash
          systemctl --user import-environment
          systemctl --user start sway.service
        '';
      }
    )
  ];

  systemd.user.targets.sway-session = {
    description = "Sway compositor";
    documentation = [ "" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
  };

  systemd.user.services.sway = {
    description = "Sway - Wayland WM";
    documentation = [ "" ];
    bindsTo = [ "graphical-session.target" ];
    wants = [ "graphical-session-pre.target" ];
    after = [ "graphical-session-pre.target" ];
    environment.PATH = lib.mkForce null;
    serviceConfig = {
      Type = "simple";
      ExecStart = ''
        ${pkgs.dbus}/bin/dbus-run-session ${pkgs.sway}/bin/sway
      '';
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };

  programs.waybar.enable = true;

  virtualisation.docker.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?
}
