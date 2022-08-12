{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ../modules/git.nix
    ../modules/gpg-agent.nix
    ../modules/ncmpcpp.nix
    ../modules/password-store.nix
    ../modules/roomeqwizard.nix
    ../modules/tmux.nix
    ../modules/vim.nix
    ../modules/viddy.nix
    ../modules/zsh.nix
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

    mpc_cli
    ncmpc
    ncmpcpp

    elinks

    home-assistant-cli
    age
    bc
    bmap-tools
    dterm
    htop
    jq
    moreutils
    nmap
    tmux
    wget
  ];

  home.sessionVariables = {
    HASS_SERVER = "https://home.phire.org";
    HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
    MPD_HOST = "phire-preamp";
  };

  modules.calendar.enable = true;
  modules.email.enable = true;
  modules.graphical.enable = true;

  modules.beets = {
    enable = true;
    musicDir = "/home/a/Music";
  };

  services.kdeconnect = {
    enable = true;
    indicator = true;
  };
}
