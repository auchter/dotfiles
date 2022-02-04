{ config, pkgs, lib, ... }:
{
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
    exiftool
    feh
    ffmpeg
    firefox
    google-chrome
    home-assistant-cli
    i3blocks
    mpv
    mupdf
    notify-desktop
    obsidian
    powertop
    qutebrowser
    signal-desktop
    usbutils
    wireshark
    wob
    zbar
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
}
