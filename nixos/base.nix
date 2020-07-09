{ config, pkgs, options, ... }:

{
  time.timeZone = "UTC";

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;

  environment.systemPackages = with pkgs; [
    fail2ban
    git
    inetutils
    miniflux
    mtr
    nginx
    stow 
    sysstat
    tmux
    vim
    wget
    zsh
  ];

  services.sshd.enable = true;
  services.fail2ban.enable = true;

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

