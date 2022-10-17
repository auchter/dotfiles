{ config, lib, ... }:

with lib;

let
  cfg = config.modules.sshd;
in {
  options.modules.sshd = {
    enable = mkEnableOption "enable sshd";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;
      passwordAuthentication = false;
    };

    services.sshguard.enable = true;
    programs.mosh.enable = true;
  };
}
