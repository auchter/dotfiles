{ config, pkgs, options, ... }:

{
  networking.useDHCP = false;

  programs.mosh.enable = true;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}

