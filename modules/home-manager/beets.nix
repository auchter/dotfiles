{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.beets;
in {
  options.modules.beets = {
    enable = mkEnableOption "beets";
    musicDir = mkOption {
      type = types.str;
      default = "/mnt/storage/music";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.ffmpeg # for replaygain
    ];

    programs.beets = {
      enable = true;
      settings = {
        library = "${cfg.musicDir}/beets.db";
        directory = cfg.musicDir;
        import = {
          copy = false;
          move = true;
        };
        original_date = true;
        languages = [ "en" "de" ];
        plugins = [
          "fetchart"
          "missing"
          "replaygain"
        ];
        lastfm.user = "auchter";
        missing = {
          format = "$albumartist - $album - $title";
          count = false;
          total = false;
        };
        replaygain = {
          backend = "ffmpeg";
        };
      };
    };
  };
}
