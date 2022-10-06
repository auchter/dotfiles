{ config, lib, ... }:

with lib;

let
  cfg = config.modules.wifi;
in {
  options.modules.wifi = {
    enable = mkEnableOption "wifi";
    interfaces = mkOption {
      default = [];
      type = types.listOf types.str;
    };
  };

  config = mkIf cfg.enable {
    networking.wireless = {
      enable = true;
      interfaces = cfg.interfaces;
    };

    sops.secrets.wpa_supplicant = {
      sopsFile = ../../secrets/wifi.yaml;
      restartUnits = map (iface: "wpa_supplicant-" + iface) cfg.interfaces;
    };

    environment.etc."wpa_supplicant.conf".source = config.sops.secrets.wpa_supplicant.path;
  };
}
