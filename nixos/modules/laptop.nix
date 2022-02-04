{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
  ];

  powerManagement.powertop.enable = true;
}
