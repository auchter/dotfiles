{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.pyhifid;
in {
  options.services.pyhifid = {
    enable = mkEnableOption "pyhifid";

    backend = mkOption {
      type = types.str;
      description = "Backend to use";
    };

    logLevel = mkOption {
      type = types.nullOr types.str;
      description = "Logging verbosity";
      default = null;
    };
  };

  config = mkIf cfg.enable {
    systemd.services.pyhifid = {
      description = "pyhifid";
      after = [ "network.target" "snapclient.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.pyhifid}/bin/pyhifid \
            --backend ${cfg.backend} \
            ${optionalString (cfg.logLevel != null) "--log ${cfg.logLevel}"} \
        '';
        Restart = "always";
        SupplementaryGroups = [ "gpio" ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 4664 ];
  };
}
