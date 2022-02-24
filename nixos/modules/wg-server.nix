{ config, pkgs, options, sops-nix, ... }:

{
  sops.secrets.wireguard_private = {};

  networking.nat = {
    enable = true;
    externalInterface = "enp0s4";
    internalInterfaces = [ "wg0" ];
  };

  networking.firewall = {
    allowedUDPPorts = [ 53 51820 ];
    allowedTCPPorts = [ 53 ];
  };

  services.dnsmasq = {
    enable = true;
    extraConfig = ''
      interface=wg0
    '';
  };

  networking.extraHosts = ''
    10.100.0.1 ipos.internal
    10.100.0.2 moloch.internal
    10.100.0.3 stolas.internal
    10.100.0.4 orobas.internal
    10.100.0.5 pixel5.internal
  '';

  services.fail2ban.ignoreIP = [ "10.100.0.0/24" ];

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
        { # stolas
          publicKey = "jd0IBUGjSLjPqz8IxgwQ/43/qfAZnR2eOa+NUMbbWTE=";
          allowedIPs = [ "10.100.0.3/32" ];
        }
        { # orobas
          publicKey = "qJoRq6SwcmbutGVYv5F74kTrbsPTHBBjGrlYFOwgHQQ=";
          allowedIPs = [ "10.100.0.4/32" ];
        }
        { # pixel 5
          publicKey = "ioMtg6Y3xPPs15JmSYXK8GZi+MLqDjrjo8/RsybuE3s=";
          allowedIPs = [ "10.100.0.5/32" ];
        }
      ];
    };
  };
}
