{ config, pkgs, options, ... }:

{
  time.timeZone = "UTC";

  environment.systemPackages = with pkgs; [
    fail2ban
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
  services.fail2ban.enable = true;

  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

  nix.gc.automatic = true;
  nix.gc.dates = "03:20";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}

