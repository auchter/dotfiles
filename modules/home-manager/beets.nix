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
    smartPlaylists = mkOption {
      default = {};
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.ffmpeg # for replaygain
    ];

    programs.beets = {
      enable = true;
      package = pkgs.beets-unstable.override {
        pluginOverrides = {
          alternatives = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beetsPackages.alternatives ];
          };
          dynamicrange = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beets-dynamicrange ];
          };
          rym = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beets-rym ];
          };
          # hack, remove eventually:
          limit.builtin = true;
          substitute.builtin = true;
          advancedrewrite.builtin = true;
          autobpm.builtin = true;
        };
      };
      settings = {
        library = "${cfg.musicDir}/beets.db";
        directory = cfg.musicDir;
        import = {
          copy = false;
          move = true;
        };
        format_album = "$albumartist - $year - $album";
        sort_album = "artist+ year+ album+ disc+ track+";
        format_item = "$artist - $year - $album - $track - $title";
        sort_item = "artist+ year+ album+ disc+ track+";
        original_date = true;
        languages = [ "en" "de" ];
        plugins = [
          "alternatives"
          "badfiles"
          "convert"
          "dynamicrange"
          "edit"
          "fetchart"
          "fromfilename"
          "lastgenre"
          "lastimport"
          "lyrics"
          "mbsubmit"
          "mbsync"
          "missing"
          "replaygain"
          "smartplaylist"
          "rym"
          "zero"
        ];
        alternatives = {
          opus = {
            directory = "/mnt/storage/music.opus";
            formats = "opus mp3 ogg aac";
            removable = false;
            query = "";
          };
        };
        badfiles = {
          check_on_import = true;
          commands = {
            "flac" = "${pkgs.flac}/bin/flac -wst";
            "mp3" = "${pkgs.mp3val}/bin/mp3val";
          };
        };
        convert = {
          never_convert_lossy_files = true;
          copy_album_art = true;
        };
        lastfm.user = "auchter";
        missing = {
          format = "$albumartist - $album - $title";
          count = false;
          total = false;
        };
        musicbrainz = {
          genres = true;
        };
        replaygain = {
          backend = "ffmpeg";
        };
        rym = {
          set_genre = true;
        } // import ./beets-rym.secret.nix;
        smartplaylist = {
          relative_to = "${cfg.musicDir}";
          playlist_dir = "${cfg.musicDir}/playlists";
          forward_slash = false;
          playlists  = mapAttrsToList (name: query: { name = "${name}.m3u"; } // query) cfg.smartPlaylists;
        };
        zero = {
          fields = "comments";
          update_database = true;
        };
      };
    };
  };
}
