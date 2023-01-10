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
      package = pkgs.beets.override {
        pluginOverrides = {
          dynamicrange = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beets-dynamicrange ];
          };
          rym = {
            enable = true;
            propagatedBuildInputs = [ pkgs.beets-rym ];
          };
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
          "badfiles"
          "dynamicrange"
          "edit"
          "fetchart"
          "fromfilename"
          "lastgenre"
          "lastimport"
          "lyrics"
          "missing"
          "replaygain"
          "smartplaylist"
          "rym"
          "zero"
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
        musicbrainz = {
          genres = true;
        };
        replaygain = {
          backend = "ffmpeg";
        };
        smartplaylist = {
          relative_to = "${cfg.musicDir}";
          playlist_dir = "${cfg.musicDir}/playlists";
          forward_slash = false;
          playlists  = [
            {
              name = "Aphex Twin Analord.m3u";
              query = "album:Analord album+";
            }
            {
              name = "Autechre - Elseq.m3u";
              album_query = "albumartist:Autechre album:elseq";
            }
            {
              name = "Autechre - NTS Sessions.m3u";
              album_query = "albumartist:Autechre album:'NTS Session'";
            }
            {
              name = "Frank Zappa - Joe's Garage.m3u";
              album_query = "albumartist:'Frank Zappa' album:Garage";
            }
            {
              name = "Frank Zappa - Roxy Performances 1973-12-09 Show 1.m3u";
              query = "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐9‐73 show 1'";
            }
            {
              name = "Frank Zappa - Roxy Performances 1973-12-09 Show 2.m3u";
              query = "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐9‐73 show 2'";
            }
            {
              name = "Frank Zappa - Roxy Performances 1973-12-10 Show 1.m3u";
              query = "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐10‐73 show 1'";
            }
            {
              name = "Frank Zappa - Roxy Performances 1973-12-10 Show 2.m3u";
              query = "albumartist:'Frank Zappa' album:'Roxy Performances' title:'12‐10‐73 show 2'";
            }
            {
              name = "Secret Chiefs 3 Singles.m3u";
              album_query = "albumartist:'Secret Chiefs 3' albumtype:single";
            }
            {
              name = "John Zorn's Book of Angels.m3u";
              album_query = "album:'Book of Angels' year+ month+ day+";
            }
            {
              name = "John Zorn's The Book Beri'ah.m3u";
              album_query = "album:'The Book Beri' year+ month+ day+";
            }
            {
              name = "John Zorn's Moonchild.m3u";
              album_query = "album:astronome, album:moonchild, album:'six litanies', album:'the crucible'";
            }
            {
              name = "John Zorn's Gnostic Trio.m3u";
              album_query = "album:netzach, album:mockingbird";
            }
            {
              name = "John Zorn's Simulacrum.m3u";
              album_query = "album:Simulacrum, album:'true discoveries of witches', album:'baphomet', album:'garden of earthly delights'";
            }
            {
              name = "%left{$added, 7} - New Albums.m3u";
              album_query = "added:2022-11..";
            }
          ];
        };
        zero = {
          fields = "genre comments";
          update_database = true;
        };
      };
    };
  };
}
