{ config, lib, ... }:

with lib;

let
  cfg = config.modules.restic;
in {
  options.modules.restic = {
    enable = mkEnableOption "restic";
    cloudPaths = mkOption {
      default = [];
      description = "paths to backup to the clown";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets.restic_password = {};
    sops.secrets.restic_env = {};

    services.restic.backups = {
      backblaze = {
        repository = "b2:restic-phire:/";
        passwordFile = config.sops.secrets.restic_password.path;
        environmentFile = config.sops.secrets.restic_env.path;
        timerConfig = {
          OnCalendar = "daily";
        };
        paths = cfg.cloudPaths;
      };
    };
  };
}
