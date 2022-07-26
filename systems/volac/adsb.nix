{ config, pkgs, ... }:

let
  uuid = "6a97aa61-e1b4-4185-9225-c67306e5f968";
  siteName = "caseville";
  latitude = 43.981064;
  longitude = -83.181330;
  altitude = 183.0;
  mlatPort = 30104; # port for mlat-client to send mlat data to readsb
  adsbPort = 30005; # port that readsb outputs beast data
in {
  # mostly so the viewadsb tool is available...
  environment.systemPackages = with pkgs; [
    readsb
  ];

  services.readsb = {
    enable = true;
    uuid = uuid;
    deviceType = "rtlsdr";
    latitude = latitude;
    longitude = longitude;
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
    uuid = uuid;
    latitude = latitude;
    longitude = longitude;
    altitude = altitude;
    host = "feed.adsbexchange.com";
    port = 31090;
    user = siteName;
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
    hostName = "caseville.phire.org";
  };
}
