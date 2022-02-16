{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/common.nix
    ./modules/graphical.nix
  ];

  home.username = "guest";
  home.homeDirectory = "/home/guest";
  home.stateVersion = "21.11";
}
