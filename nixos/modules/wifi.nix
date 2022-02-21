{ config, sops-nix, ... }:

{
  sops.secrets.wpa_supplicant = {
    sopsFile = ../../secrets/wifi.yaml;
    restartUnits = map (iface: "wpa_supplicant-" + iface) config.networking.wireless.interfaces;
  };
  environment.etc."wpa_supplicant.conf".source = config.sops.secrets.wpa_supplicant.path;
}
