{ config, pkgs, ... }:

{
  services.mpd = {
    enable = true;
    network.listenAddress = "any";
  };

  networking.firewall.allowedTCPPorts = [ config.services.mpd.network.port ];
}
