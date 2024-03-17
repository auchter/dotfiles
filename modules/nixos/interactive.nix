{ config, lib, pkgs, ... }:

# Use this module for "interactive" devices, ones that you want a graphical
# interface etc.

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

    sound.enable = true;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    services.blueman.enable = true;
    hardware.bluetooth.enable = true;

    hardware.opengl = {
      enable = true;
      driSupport = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiVdpau
        libvdpau-va-gl
      ];
    };

    environment.systemPackages = with pkgs; [
      libva-utils
      intel-gpu-tools
    ];

    # HACK: globally enable sway instead of relying on home-manager to ensure /etc/pam.d/swaylock gets installed
    programs.sway.enable = true;
  };
}
