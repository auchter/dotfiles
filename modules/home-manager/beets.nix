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
          "badfiles"
          "fetchart"
          "lastimport"
          "missing"
          "replaygain"
        ];
        badfiles = {
          check_on_import = true;
          commands = {
            "flac" = "${pkgs.flac}/bin/flac -wst";
            "mp3" = "${pkgs.mp3val}/bin/mp3val";
          };
        };
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
