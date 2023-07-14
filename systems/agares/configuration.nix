{ pkgs, lib, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ../common
    ];

  powerManagement.powertop.enable = true;

  modules.sshd.enable = true;
  modules.soulseek.enable = true;
  modules.wifi = {
    enable = true;
    interfaces = [ "wlp0s20f3" ];
  };

#  modules.wireguard.client = {
#    enable = true;
#    server = "ipos";
#  };

  services.blueman.enable = true;
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
  };

  hardware.bluetooth = {
    enable = true;
  };

  sound.enable = true;

  virtualisation.docker.enable = true;

  # HACK: globally enable sway instead of relying on home-manager to ensure /etc/pam.d/swaylock gets installed
  programs.sway.enable = true;

  environment.systemPackages = [
    pkgs.git-crypt
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
