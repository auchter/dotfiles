{ config, lib, pkgs, ... }:

# Use this module for "interactive" devices,
# that is, machines that you interact with directly

with lib;

let
  cfg = config.modules.interactive;
in {
  options.modules.interactive = {
    enable = mkEnableOption "Configuration for interactive devices";
  };

  config = mkIf cfg.enable {

    # Don't enable powersaving for my USB mouse
    services.udev.extraRules = ''
      ENV{PRODUCT}=="46d/c025/9802", ATTR{power/control}="on"
    '';


    services.avahi.enable = true;
    services.avahi.nssmdns = true;

    sound.enable = true;
    hardware.pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      extraConfig = ''
        load-module module-bluetooth-policy auto_switch=2
      '';
    };

    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    hardware.opengl = {
      enable = true;
      driSupport = true;
    };

    # HACK: globally enable sway instead of relying on home-manager to ensure /etc/pam.d/swaylock gets installed
    programs.sway.enable = true;

    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
  };
}
