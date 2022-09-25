{ config, lib, ... }:

with lib;

let
  cfg = config.hardware.gpio;
in {
  options.hardware.gpio = {
    enable = mkEnableOption "gpio support";

    group = mkOption {
      type = types.str;
      default = "gpio";
      description = ''
        Grant access to gpio devices (/dev/gpiochip*) to users in this group.
      '';
    };
  };

  config = mkIf cfg.enable {
    users.groups = mkIf (cfg.group == "gpio") {
      gpio = { };
    };

    services.udev.extraRules = ''
      # allow group ${cfg.group} access to gpio devices
      SUBSYSTEM=="gpio", KERNEL=="gpiochip[0-9]*", GROUP="${cfg.group}", MODE="660"
    '';
  };
}
