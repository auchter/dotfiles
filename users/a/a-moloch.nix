{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ../modules/viddy.nix
    ../modules/thinkpad_x1c6.nix
  ];

  programs.alacritty.settings = {
    font.size = 12.0;
  };

  home.packages = with pkgs; [
    esphome
    exiftool
    kicad
    zotero

    elinks

    home-assistant-cli
    age
    htop
    moreutils
    nmap
    wget

    roomeqwizard

    feh
    mpv
    mupdf
    obsidian
    signal-desktop
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
  modules.graphical.enable = true;
  modules.tmux.enable = true;
  modules.vim.enable = true;
  modules.zsh.enable = true;

  modules.beets = {
    enable = true;
    musicDir = "/home/a/Music";
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  programs.password-store.enable = true;
}
