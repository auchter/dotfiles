{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    viddy
  ];

  programs.zsh.shellAliases = {
    watch = "viddy";
  };
}

