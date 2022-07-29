{ config, pkgs, options, sops-nix, ... }:

{
  sops.secrets.wireguard_private = {};

  networking.firewall.allowedUDPPorts = [ 51820 ];

  services.fail2ban.ignoreIP = [ "10.100.0.0/24" ];

  networking.wg-quick.interfaces = {
    wg0 = {
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.wireguard_private.path;
      dns = [ "10.100.0.1" ];
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
