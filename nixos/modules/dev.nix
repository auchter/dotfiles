{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    bc
    bmap-tools
    git
  ];
}
