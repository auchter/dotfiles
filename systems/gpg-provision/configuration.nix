{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5.nix"
    ../common
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  environment.systemPackages = with pkgs; [
    drduh-yubikey-guide
    gnupg
    pinentry-curses
    pinentry-qt
    paperkey
    wget
  ];

  programs = {
    ssh.startAgent = false;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };
}
