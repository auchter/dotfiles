{ config, pkgs, options, sops-nix, ... }:

{
  sops.secrets.wireguard_private = {};

  networking.nat = {
    enable = true;
    externalInterface = "enp0s4";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.wireguard_private.path;
      peers = [
        { # moloch
          publicKey = "9zI5XY0ZWsMI1YHpq4+q5zEU7s/0VYSnIZU/pJODoAs=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
}
