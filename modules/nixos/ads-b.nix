{ config, lib, ... }:

with lib;

let
  cfg = config.modules.ads-b;
in {
  options.modules.ads-b = {
    enable = mkEnableOption "ADS-B tracking";
    latitude = mkOption {
      type = types.float;
    };
    longitude = mkOption {
      type = types.float;
    };
    altitude = mkOption {
      type = types.float;
    };
    uuid = mkOption {
      type = types.str;
    };
    siteName = mkOption {
      type = types.str;
    };
    vhost = mkOption {
      type = types.str;
    };
  };

  config = let
    mlatPort = 30104;
    adsbPort = 30005;
  in mkIf cfg.enable {
    # mostly so the viewadsb tool is available...
    environment.systemPackages = with pkgs; [
      readsb
    ];

    services.readsb = {
      enable = true;
      uuid = cfg.uuid;
      deviceType = "rtlsdr";
      latitude = cfg.latitude;
      longitude = cfg.longitude;
      network = {
        beastInputPort = mlatPort;
        beastOutputPort = adsbPort;
      };
      connections = [
        {
          protocol = "beast_reduce_out";
          host = "feed1.adsbexchange.com";
          port = 30004;
          failover_host = "feed2.adsbexchange.com";
          failover_port = 64004;
        }
      ];
    };

    services.mlat-client = {
      enable = true;
      uuid = cfg.uuid;
      latitude = cfg.latitude;
      longitude = cfg.longitude;
      altitude = cfg.altitude;
      host = "feed.adsbexchange.com";
      port = 31090;
      user = cfg.siteName;
      input = {
        type = "dump1090";
        host = "localhost";
        port = adsbPort;
      };
      results = {
        connect = [
          {
            protocol = "beast";
            host = "localhost";
            port = mlatPort;
          }
        ];
      };
    };

    services.tar1090 = {
      enable = true;
      hostName = cfg.vhost;
    };
  };
}
