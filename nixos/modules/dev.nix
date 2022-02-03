{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bmap-tools
    git
  ];
}
