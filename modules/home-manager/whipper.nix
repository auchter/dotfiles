{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.whipper;
in {
  options.modules.whipper = {
    enable = mkEnableOption "whipper";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.whipper
    ];

    xdg.configFile."whipper/whipper.conf".text = ''
      [drive:HL-DT-ST%3ADVDRAM%20SP80NB80%20%3ARF01]
      vendor = HL-DT-ST
      model = DVDRAM SP80NB80
      release = RF01
      defeats_cache = False
      read_offset = 6

      [drive:HL-DT-ST%3ADVDRAM%20GP65NB60%20%3ARF01]
      vendor = HL-DT-ST
      model = DVDRAM GP65NB60
      release = RF01
      defeats_cache = False
      read_offset = 6
    '';
  };
}
