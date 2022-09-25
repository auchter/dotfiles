{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.snapclient;
in {
  options.modules.snapclient = {
    enable = mkEnableOption "snapclient";

    host = mkOption {
      default = null;
      description = "snapserver to connect to";
      type = types.nullOr types.str;
    };

    brutefirConfig = mkOption {
      default = null;
      description = "Path to brutefir configuration to use";
      type = types.nullOr types.path;
    };

    sampleFormat = mkOption {
      default = null;
      description = "Sample format to use";
      type = types.nullOr types.str;
    };

    hostId = mkOption {
      default = config.networking.hostName;
      type = types.str;
      description = "unique host ID";
    };

    soundcard = mkOption {
      default = null;
      type = types.nullOr types.str;
      description = "soundcard index or name";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.snapclient = {
      description = "Snapclient";
      after = [
        "network.target"
        "snapserver.service"
        "time-sync.target"
        "sound.target"
      ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = ''
          ${pkgs.snapcast}/bin/snapclient \
            --hostID ${cfg.hostId} \
            ${optionalString (cfg.host != null) "-h ${cfg.host}"} \
            ${optionalString (cfg.brutefirConfig != null) "--brutefir_config ${cfg.brutefirConfig}"} \
            ${optionalString (cfg.sampleFormat != null) "--sampleformat '${cfg.sampleFormat}'"} \
            ${optionalString (cfg.soundcard != null) "-s ${toString cfg.soundcard}"}
        '';
        Restart = "on-failure";
      };
    };
  };
}
