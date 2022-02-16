{ config, pkgs, lib, ... }:

{
  imports = [
    ./modules/common.nix
  ];

  home.username = "guest";
  home.homeDirectory = "/home/guest";
  home.stateVersion = "21.11";
}
