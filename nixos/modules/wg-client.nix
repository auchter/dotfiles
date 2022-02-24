{ config, pkgs, options, sops-nix, ... }:

let
  unbound_resolv = "/etc/unbound/resolvconf.conf";
in
{
  sops.secrets.wireguard_private = {};

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.resolvconf.extraConfig = ''
    unbound_conf=${unbound_resolv}
  '';

  services.unbound = {
    enable = true;
    settings = {
      include = "${unbound_resolv}";
      server = {
        domain-insecure = [ "internal" ];
        private-domain = [ "internal" ];
      };
      forward-zone = [
        {
          name = "internal";
          forward-addr = "10.100.0.1";
        }
      ];
    };
  };

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
