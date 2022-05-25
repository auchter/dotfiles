{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "google-chrome"
    "obsidian"
    "plexmediaserver"
    "roomeqwizard"
    "unifi-controller"
  ];
}
