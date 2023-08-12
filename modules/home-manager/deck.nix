{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.deck;
in {
  options.modules.deck = {
    enable = mkEnableOption "Ono-Sendai";
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      esphome
      exiftool
      home-assistant-cli
      kindle-send
    ];

    home.sessionVariables = {
      HASS_SERVER = "https://home.phire.org";
      HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
    };

    modules.calendar.enable = true;
    modules.development.enable = true;
    modules.email.enable = true;
    modules.git.enable = true;
    modules.gpg.enable = true;
    modules.tmux.enable = true;
    modules.vim.enable = true;
    modules.zsh.enable = true;
    modules.mpd-client = {
      enable = true;
      host = "malphas";
    };

    services.kdeconnect = {
      enable = true;
      indicator = true;
    };

    programs.password-store = {
      enable = true;
      package = pkgs.pass.withExtensions (exts: [ exts.pass-import ]);
    };
  };
}
