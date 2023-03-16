{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.vdirsyncer;
  mkConfig = with generators; toINI { mkKeyValue = mkKeyValueDefault { mkValueString = builtins.toJSON; } "="; };
  sectionName = section: attrsets.mapAttrs' (name: value: attrsets.nameValuePair (section + " " + name) value);
in {
  options.modules.vdirsyncer = {
    enable = mkEnableOption "vdirsyncer";

    frequency = mkOption {
      type = types.str;
      default = "*:0/5";
    };

    statusPath = mkOption {
      type = types.str;
      description = "status path";
      default = "~/.vdirsyncer/status";
    };

    storage = mkOption {};
    pairs = mkOption {};
  };

  config = mkIf cfg.enable {
    xdg.configFile."vdirsyncer/config".text = mkConfig ({
      general = {
        status_path = cfg.statusPath;
      };
    }
    // (sectionName "storage" cfg.storage)
    // (sectionName "pair" cfg.pairs));

    systemd.user.services.vdirsyncer = {
      Unit = {
        Description = "vdirsyncer";
      };
      Service = {
        Environment = [
          "PASSWORD_STORE_DIR=/home/a/.local/share/password-store"
        ];
        ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
        Type = "oneshot";
      };
    };

    systemd.user.timers.vdirsyncer = {
      Unit = { Description = "vdirsyncer sync"; };
      Timer = {
        Unit = "vdirsyncer.service";
        OnCalendar = cfg.frequency;
      };
      Install = { WantedBy = [ "timers.target" ]; };
    };
  };
}
