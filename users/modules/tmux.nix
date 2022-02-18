{ config, pkgs, lib, ... }:

{
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    terminal = "screen-256color";
  };
}
