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
    networks = mkOption {
      default = null;
      type = types.nullOr (types.listOf types.str);
      description = "which SSIDs should be included";
    };
  };

  config = mkIf cfg.enable {
    networking.interfaces = builtins.listToAttrs (builtins.map (i: { name = i; value = { useDHCP = true; }; }) cfg.interfaces);

    networking.wireless = let
      netPred = if (cfg.networks == null) then (n: v: true) else (n: v: elem n cfg.networks);
    in {
      enable = true;
      interfaces = cfg.interfaces;
      environmentFile = config.sops.secrets.wpa_supplicant.path;
      networks = filterAttrs netPred (import ./wifi.secret.nix);
      userControlled = {
        enable = true;
        group = "wheel";
      };
    };

    sops.secrets.wpa_supplicant = {
      sopsFile = ../../secrets/wifi.yaml;
      restartUnits = map (iface: "wpa_supplicant-" + iface) cfg.interfaces;
    };
  };
}
