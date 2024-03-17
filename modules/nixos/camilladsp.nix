{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.camilladsp;
  jsonConfigs = map (x: builtins.fromJSON (builtins.readFile x)) cfg.extraFilters;
  mergeFunc = name: values:
    if name == "filters"
      then (foldAttrs (item: acc: acc // item) {} values)
    else if name == "pipeline"
      then (concatLists values)
    else (head values);
  finalConfig = zipAttrsWith mergeFunc ([cfg.config] ++ jsonConfigs);
  # If config is empty, pass --wait to wait for a config from the websocket
  configParam = if finalConfig == {} then "--wait" else pkgs.writeText "camilladsp.yml" (builtins.toJSON finalConfig);
in {
  options.services.camilladsp = {
    enable = mkEnableOption "enable camilladsp";

    package = mkOption {
      description = "camilladsp package to use";
      default = pkgs.camilladsp;
      defaultText = literalExpression "pkgs.camilladsp";
      type = types.package;
    };

    port = mkOption {
      description = "port for websocket";
      default = 5253;
      type = types.port;
    };

    config = mkOption {
      description = "extra configuration to add";
      default = {};
      type = types.attrs;
    };

    extraFilters = mkOption {
      description = "Extra JSON files describing filters and pipeline stages to append";
      type = with types; listOf path;
      default = [];
    };
  };

  config = mkIf cfg.enable {
    systemd.services.camilladsp = {
      description = "camilladsp";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.package}/bin/camilladsp --port ${toString cfg.port} ${configParam}
        '';
        Type = "simple";
        Restart = "always";
        DynamicUser = true;
        SupplementaryGroups = [ "audio" ];
      };
    };
  };
}
