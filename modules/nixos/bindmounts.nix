{ config, lib, ... }:

with lib;

let
  cfg = config.modules.bindmounts;
in {
  options.modules.bindmounts = {
    mounts = mkOption {
      type = types.attrsOf (types.str);
      description = "mapping from bind mount to canonical location";
      default = {};
    };
  };

  config = mkIf (cfg.mounts != {}) {
    fileSystems = mapAttrs (_bind: canon: {
      device = canon;
      options = [ "bind" ];
    }) cfg.mounts;
  };
}
