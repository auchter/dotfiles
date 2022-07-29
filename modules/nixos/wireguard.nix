{ config, lib, sops-nix, ... }:

with lib;

let
  cfg = config.modules.wireguard;
  hosts = {
    ipos = {
      publicKey = "+HafSQ+MyzN0Suv854kXa6ZG+9xGimMvV0cHGwOjdRk=";
      ip = "10.100.0.1";
    };
    moloch = {
      publicKey = "9zI5XY0ZWsMI1YHpq4+q5zEU7s/0VYSnIZU/pJODoAs=";
      ip = "10.100.0.2";
    };
    stolas = {
      publicKey = "jd0IBUGjSLjPqz8IxgwQ/43/qfAZnR2eOa+NUMbbWTE=";
      ip = "10.100.0.3";
    };
    orobas = {
      publicKey = "qJoRq6SwcmbutGVYv5F74kTrbsPTHBBjGrlYFOwgHQQ=";
      ip = "10.100.0.4";
    };
    pixel5 = {
      publicKey = "ioMtg6Y3xPPs15JmSYXK8GZi+MLqDjrjo8/RsybuE3s=";
      ip = "10.100.0.5";
    };
  };
  port = 51820;
  interface = "wg0";
  networkMask = "10.100.0.0/24";
in {
  options.modules.wireguard = {
    server = {
      enable = mkEnableOption "enable server";
      externalInterface = mkOption {
        description = "external interface for nat";
      };
    };

    client = {
      enable = mkEnableOption "enable client";
      server = mkOption {
        description = "hostname of the wireguard server";
        type = types.str;
      };
    };
  };

  config = mkIf (cfg.server.enable || cfg.client.enable) {
    services.fail2ban.ignoreIP = [ networkMask ];
  } // mkIf cfg.server.enable {
    sops.secrets.wireguard_private = {};
    networking.nat = {
      enable = true;
      externalInterface = cfg.server.externalInterface;
      internalInterfaces = [ interface ];
    };

    networking.firewall = {
      allowedUDPPorts = [ 53 port ];
      allowedTCPPorts = [ 53 ];
    };

    services.dnsmasq = {
      enable = true;
      extraConfig = ''
        interface=${interface}
      '';
    };

    networking.extraHosts = mapAttrs (host: info: "${info.ip} ${host}.internal") hosts;

    networking.wireguard.interfaces.${interface} = {
      ips = [ "10.100.0.1/24" ];
      listenPort = port;
      privateKeyFile = config.sops.secrets.wireguard_private.path;
      peers = mapAttrs (host: info: {
        publicKey = info.publicKey;
        allowedIPs = [ "${info.ip}/32" ];
      }) hosts;
    };
  } // mkIf cfg.client.enable {
    sops.secrets.wireguard_private = {};
    networking.firewall.allowedUDPPorts = [ port ];

    networking.wg-quick.interfaces."${interface}" = {
      listenPort = port;
      privateKeyFile = config.sops.secrets.wireguard_private.path;
      dns = [ hosts."${cfg.client.server}".ip ];
      address = [ hosts."${config.networking.hostName}".ip ];
      peers = [
        {
          publicKey = hosts."${cfg.client.server}".publicKey;
          allowedIPs = [ networkMask ];
          endpoint = "${cfg.client.server}.phire.org:${toString port}";
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
