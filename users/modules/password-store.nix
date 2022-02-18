{ config, pkgs, lib, ... }:

{
  programs.password-store = {
    enable = true;
  };
}
