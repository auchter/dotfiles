{ config, pkgs, lib, ... }:

{
  imports = [
    ./common.nix
    ../../nixos/modules/unfree.nix
    ../modules/git.nix
    ../modules/gpg-agent.nix
    ../modules/graphical.nix
    ../modules/ncmpcpp.nix
    ../modules/password-store.nix
    ../modules/roomeqwizard.nix
    ../modules/tmux.nix
    ../modules/vim.nix
    ../modules/zsh.nix
    ../modules/thinkpad_x1c6.nix
  ];


  programs.alacritty.settings = {
    font.size = 12.0;
  };

  home.packages = with pkgs; [
    esphome
    khard
    khal
    kicad
    vdirsyncer
  ];
}
