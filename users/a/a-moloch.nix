{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ../modules/git.nix
    ../modules/gpg-agent.nix
    ../modules/graphical.nix
    ../modules/himitsu.nix
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

  programs.himitsu = {
    enable = true;
    browsers = [ "firefox" ];
  };

  home.packages = with pkgs; [
    esphome
    exiftool
    kicad
    zotero

    mpc_cli
    ncmpc
    ncmpcpp
  ];

  programs.notmuch.enable = true;
  programs.neomutt.enable = true;
  programs.msmtp.enable = true;
  programs.offlineimap.enable = true;
  programs.lieer.enable = true;
  programs.alot.enable = true;

  home.sessionVariables = {
    HASS_SERVER = "https://home.phire.org";
    HASS_TOKEN = "$(${pkgs.pass}/bin/pass tokens/hass)";
    MPD_HOST = "phire-preamp";
  };
}
