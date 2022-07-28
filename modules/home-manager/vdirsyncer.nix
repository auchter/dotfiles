{ config, lib, ... }:

with lib;

let
  cfg = config.modules.vdirsyncer;
in {
  options.modules.calendar = {
    enable = mkEnableOption "vdirsyncer";
  };
}
