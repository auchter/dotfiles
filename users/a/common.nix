{ config, pkgs, lib, ...}:

{
  home.username = "a";
  home.homeDirectory = "/home/a";
  home.stateVersion = "21.11";

  programs.git = {
    userName = "Michael Auchter";
    userEmail = "a@phire.org";
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "vim";
  };
}
