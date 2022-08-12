{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.mpd-client;
in {
  options.modules.mpd-client = {
    enable = mkEnableOption "enable mpd-client";
    host = mkOption {
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables.MPD_HOST = cfg.host;

    programs.ncmpcpp = {
      enable = true;
      settings = {
        media_library_primary_tag = "album_artist";
        display_bitrate = "yes";
        mouse_support = "no";
        message_delay_time = 2;
        playlist_separate_albums = "yes";
        playlist_display_mode = "columns";
        browser_display_mode = "columns";
        search_engine_display_mode = "columns";
        seek_time = "10";
        ignore_diacritics = "yes";
      };
      bindings =
        let
          bindChain = key: cmds: [ { key = "${key}"; command = cmds;  } ];
          bindMultiple = key: cmds: map (cmd: { key = "${key}"; command = "${cmd}"; }) cmds;
        in
          bindChain "j" "scroll_down" ++
          bindChain "J" [ "select_item" "scroll_down" ] ++
          bindChain "k" "scroll_up" ++
          bindChain "K" [ "select_item" "scroll_up" ] ++
          bindChain "ctrl-u" "page_up" ++
          bindChain "ctrl-d" "page_down" ++
          bindMultiple "l" [ "show_lyrics" "next_column" "slave_screen" ] ++
          bindMultiple "h" [ "previous_column" "master_screen" ];
    };
  };
}
