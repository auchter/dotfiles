{ config, pkgs, home, ... }:

{
  environment.systemPackages = with pkgs; [
    kdeconnect
  ];

  # Only open ports on the wireguard interface
  networking.firewall.interfaces.wg0 = rec {
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedTCPPortRanges = allowedUDPPortRanges;
  };
}
