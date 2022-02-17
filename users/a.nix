{ config, pkgs, lib, ... }:

{
  imports = [
    ./a-headless.nix
    ./modules/graphical.nix
    ./modules/audio.nix
    ../nixos/modules/unfree.nix
  ];
}
