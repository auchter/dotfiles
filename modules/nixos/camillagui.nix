{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.camillagui;
  configFile = pkgs.writeText "camillagui.yml" (builtins.toJSON cfg.config);
in {
  options.services.camillagui = {
    enable = mkEnableOption "enable camillagui";
    port = mkOption {
      description = "Port for CamillaGUI";
      default = 5000;
      type = types.port;
    };
    openFirewall = mkEnableOption "open the firewall!";
    config = mkOption {
      description = "camillagui configuration";
      default = let 
        state_directory = "/var/lib/camillagui";
      in {
        camilla_host = "127.0.0.1";
        camilla_port = config.services.camilladsp.port;
        port = cfg.port;
        config_dir = "${state_directory}/configs";
        coeff_dir = "${state_directory}/coeffs";
        default_config = "${state_directory}/default_config.yml";
        active_config = "${state_directory}/active_config.yml";
        active_config_txt = "${state_directory}/active_config.txt";
        log_file = "${state_directory}/camilladsp.log";
      };
      type = types.attrs;
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [ cfg.port ];

    systemd.services.camillagui = {
      description = "camillagui";
      after = [ "camilladsp.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStartPre = ''${pkgs.coreutils}/bin/mkdir -p ''${STATE_DIRECTORY}/configs ''${STATE_DIRECTORY}/coeffs
        '';
        ExecStart = ''
          ${pkgs.camillagui}/bin/camillagui --config ${configFile}
        '';
        Type = "simple";
        Restart = "always";
        DynamicUser = true;
        StateDirectory = "camillagui";
      };
    };
  };
}
