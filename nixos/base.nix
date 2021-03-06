{ config, pkgs, options, ... }:

{
  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    cryptsetup
    fail2ban
    flac
    git
    gnupg
    htop
    inetutils
    mtr
    moreutils
    nginx
    nmap
    pass
    pinentry-curses
    stow 
    sysstat
    python3
    tmux
    unzip
    vim
    wget
    zsh
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  services.sshguard.enable = true;
  services.fail2ban = {
    enable = true;
    bantime-increment = {
      enable = true;
    };
  };

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  nix.gc.automatic = true;
  nix.gc.dates = "03:20";
}

