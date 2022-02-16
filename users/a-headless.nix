{ config, pkgs, lib, ...}:

{
  imports = [
    ./modules/common.nix
  ];

  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "21.11";

  programs.git = {
    userName = "Michael Auchter";
    userEmail = "a@phire.org";
  };
}
