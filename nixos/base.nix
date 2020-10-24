{ config, pkgs, options, ... }:

{
  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    cryptsetup
    fail2ban
    flac
    git
    htop
    inetutils
    mtr
    nginx
    nmap
    stow 
    sysstat
    python3
    tmux
    unzip
    vim
    wget
    zsh
  ];

  services.sshd.enable = true;
  services.fail2ban = {
    enable = true;
    bantime-increment = {
      enable = true;
    };
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

