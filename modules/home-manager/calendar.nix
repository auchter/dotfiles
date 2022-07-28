{ config, lib, ... }:

with lib;

let
  cfg = config.modules.calendar;
in {
  options.modules.calendar = {
    enable = mkEnableOption "Calendaring";
  };
}
