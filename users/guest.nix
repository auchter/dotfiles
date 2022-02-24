{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/graphical.nix
    ../nixos/modules/unfree.nix
    ./modules/vim.nix
    ./modules/zsh.nix
    ./modules/thinkpad_x1c6.nix
  ];

  home.username = "guest";
  home.homeDirectory = "/home/guest";
  home.stateVersion = "21.11";

  programs.home-manager.enable = true;
}
