{ config, lib, ... }:

with lib;

let
  cfg = config.modules.embedded;
in {
  options.modules.embedded = {
    enable = mkEnableOption "Embedded stuff";
    interface = mkOption {
      type = types.str;
      description = "Interface attached to target";
    };
  };

  config = mkIf cfg.enable {
    networking.interfaces."${cfg.interface}" = {
      ipv4.addresses = [
        { address = "192.168.42.1"; prefixLength = 24; }
      ];
    };

    services.dhcpd4 = {
      enable = true;
      interfaces = [ "${cfg.interface}" ];
      extraConfig = ''
        option subnet-mask 255.255.255.0;
        option broadcast-address 192.168.1.255;
        option routers 192.168.1.5;
        subnet 192.168.42.0 netmask 255.255.255.0 {
          range 192.168.42.100 192.168.42.200;
        }
      '';
    };

    services.tftpd.enable = true;
    networking.firewall.allowedUDPPorts = [ 69 ]; # nice
  };
}
