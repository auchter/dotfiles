{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.phire.modules.printing;
in {
  options.phire.modules.printing = {
    enable = mkEnableOption "Enable printing support.";
  };

  config = mkIf cfg.enable {
    services.avahi.enable = true;
    services.avahi.nssmdns = true;
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
  };
}
