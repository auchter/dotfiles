{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.frigate;
in {
  options.modules.frigate = {
    enable = mkEnableOption "frigate";
    storageDir = mkOption {
      type = types.str;
      description = "storage directory";
    };

    settings = mkOption { };
  };

  config = mkIf (cfg.enable) {
    virtualisation.oci-containers = let
      configFile = pkgs.writeText "frigate.yml" (generators.toYAML {} cfg.settings);
    in {
      containers = {
        frigate = {
          image = "ghcr.io/blakeblackshear/frigate:0.12.1";
          volumes = [
            "${configFile}:/config/config.yml"
            "${cfg.storageDir}:/media/frigate"
            "/etc/localtime:/etc/localtime:ro"
          ];
          ports = [
            "5000:5000"
            "8554:8554"
            "8555:8555/tcp"
            "8555:8555/udp"
          ];
          environment = {
            FRIGATE_RTSP_PASSWORD = "password";
          };
          extraOptions = [
            "--shm-size=64m"
          ];
        };
      };
    };
  };
}
