{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    mpc_cli
    ncmpc
    ncmpcpp
  ];
}
