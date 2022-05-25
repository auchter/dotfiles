{ config, ... }:

{
  services.unifi = {
    enable = true;
  };

  # for admin gui
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
