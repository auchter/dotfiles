{ config, sops-nix, ... }:

{
  sops.secrets.wpa_supplicant.sopsFile = ../../secrets/wifi.yaml;
  environment.etc."wpa_supplicant.conf".source = config.sops.secrets.wpa_supplicant.path;
}
