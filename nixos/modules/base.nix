{ config, pkgs, options, ... }:

{
  networking.useDHCP = false;

  environment.systemPackages = with pkgs; [
    age
    cryptsetup
    fail2ban
    flac
    git
    gnupg
    htop
    inetutils
    jq
    mtr
    moreutils
    nfs-utils
    nginx
    nmap
    pass
    pinentry-curses
    pwgen
    restic
    sops
    stow 
    sysstat
    python3
    tmux
    unzip
    vim
    wget
    zsh
  ];

  programs.mosh.enable = true;

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  nix.gc = {
    automatic = true;
    dates = "10:20";
  };

  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "10:00";
  };
}

