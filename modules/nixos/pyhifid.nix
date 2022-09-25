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
  };

  config = mkIf cfg.enable {
    systemd.services.pyhifid = {
      description = "pyhifid";
      after = [ "network.target" "snapclient.service" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.pyhifid}/bin/pyhifid --backend ${cfg.backend}";
        Restart = "always";
        SupplementaryGroups = [ "gpio" ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 4664 ];
  };
}
