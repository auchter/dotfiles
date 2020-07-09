{ config, pkgs, ... }:

{
  users.users.a = {
    description = "Michael Auchter";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    home = "/home/a";
    shell = pkgs.zsh;
    uid = 1000;
  };
}
