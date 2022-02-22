{ config, pkgs, options, sops-nix, ... }:

{
  sops.secrets.wireguard_private = {};

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.interfaces = {
    wg0 = {
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.wireguard_private.path;
      peers = [
        { # ipos
          publicKey = "+HafSQ+MyzN0Suv854kXa6ZG+9xGimMvV0cHGwOjdRk=";
          allowedIPs = [ "10.100.0.0/24" ];
          endpoint = "ipos.phire.org:51820";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
