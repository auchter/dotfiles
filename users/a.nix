{ config, pkgs, lib, ... }:

{
  imports = [
    ./a-headless.nix
    ./modules/graphical.nix
  ];
}
