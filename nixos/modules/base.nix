{ config, pkgs, options, ... }:

{
  time.timeZone = "UTC";

  networking.domain = "phire.org";
  networking.search = [ config.networking.domain ];
  networking.useDHCP = false;

  environment.systemPackages = with pkgs; [
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

