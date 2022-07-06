{ config, ... }:

{
  services.unifi = {
    enable = true;
    openFirewall = true;
  };

  # for admin gui
  networking.firewall.allowedTCPPorts = [ 8443 ];
}
