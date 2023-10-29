{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ohsnapctrl;
in {
  options.services.ohsnapctrl = {
    enable = mkEnableOption "ohsnapctrl";
    hostId = mkOption {
      type = types.str;
      description = "snapclient host ID";
      default = config.modules.snapclient.hostId;
    };
    server = mkOption {
      type = types.str;
      description = "snapcast server";
      default = config.modules.snapclient.host;
    };
    gpio = mkOption {
      type = types.str;
      description = "amplifier trigger gpio";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.ohsnapctrl = {
      description = "ohsnapctrl";
      after = [ "network.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.ohsnapctrl}/bin/ohsnapctrl \
            --hostID ${cfg.hostId} \
            --server ${cfg.server} \
            --gpio ${cfg.gpio}
        '';
        Restart = "always";
        SupplementaryGroups = [ "gpio" ];
      };
    };
  };
}


