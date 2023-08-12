{ config, lib, ... }:

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
  };
}
