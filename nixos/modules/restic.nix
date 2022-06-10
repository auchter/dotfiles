{ config, pkgs, options, sops-nix, ... }:

{
  services.restic.backups = {
    backblaze = {
      repository = "b2:restic-phire:/";
      passwordFile = config.sops.secrets.restic_password.path;
      environmentFile = config.sops.secrets.restic_env.path;
      timerConfig = {
        OnCalendar = "daily";
      };
    };
  };
}
