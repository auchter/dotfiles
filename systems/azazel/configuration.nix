{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.interfaces.enp0s31f6.useDHCP = true;
  modules.sshd.enable = true;

  modules.wireguard.client ={
    enable = true;
    server = "ipos";
  };

  # stereo config


  sops.secrets.listenbrainz_pass = {};

  services.listenbrainz-mpd = {
    enable = false;
    tokenFile = config.sops.secrets.listenbrainz_pass.path;
    mpdHost = "azazel.local.phire.org";
  };

  # end stereo config

  services.nginx = {
    enable = true;
    virtualHosts = {
      "home.phire.org" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://homeassistant:8123";
          proxyWebsockets = true;
          extraConfig =
            "proxy_redirect off;" +
            "proxy_set_header Host $host;" +
            "proxy_set_header X-Real-IP $remote_addr;" +
            "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;" +
            "proxy_set_header X-Forwarded-Proto $scheme;";
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
    1935 # frigate
    1883 # mosquitto
    80 443 # nginx
  ];

  services.mosquitto = {
    enable = true;
    listeners = [
      {
        users = {
          root = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$nJzEroAJL8zLthtF$bp+MRRsu/a+15L9+inM/NtX46CF/lCQq7HPYbjmQQhg5cFNRl6j8VlsM2DcoU+XJib941sWLedEyDXzpVIlliw==";
          };
          frigate = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$UgWI1piCJbj3bgd7$1nP2ncFSoK6PmIzNzpBk55jC73IRTHtMNC0hWSe7PKpAALTTo0tn+PagsY8Q/uVffMV+q5tNp50AosqhGinZEw==";
          };
          homeassistant = {
            acl = [ "readwrite #" ];
            hashedPassword = "$7$101$0H1bjprvH/niHX5G$vLZQ1cnISSwxWJCJjSC0yHGAmpxbgMl+FiZOyOiF5ttmJrmTHdfklc02AoXQYeco5a6oQsnX5OiZvyZ/kf55Jg==";
          };
        };
      }
    ];
  };

  sops.secrets.frigate_mqtt_passwd = { };

  modules.frigate = let
    reolink_go2rtc_restream = name: url: {
      "${name}_detect" = [ "ffmpeg:http://${url}/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=frigate&password=frigate" ];
      "${name}_record" = [ "ffmpeg:http://${url}/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=frigate&password=frigate" ];
    };
    ffmpeg_restream_inputs = name: [
      {
        path = "rtsp://127.0.0.1:8554/${name}_record?video=copy&audio=aac";
        input_args = "preset-rtsp-restream";
        roles = [ "record" ];
      }
      {
        path = "rtsp://127.0.0.1:8554/${name}_detect?video=copy";
        input_args = "preset-rtsp-restream";
        roles = [ "detect" ];
      }
    ];
    ffmpeg_wyzecam_inputs = host: [
      {
        path = "rtsp://${host}:8554/video3_unicast";
        input_args = "preset-rtsp-generic";
        roles = [ "record" ]; # "detect" ];
      }
    ];
  in {
    enable = true;
    storageDir = "/srv/frigate";
    tpuDevice = "/dev/apex_0";
    environmentFiles = [
      config.sops.secrets.frigate_mqtt_passwd.path
    ];
    settings = {

      record = {
        enabled = true;
        events.retain.default = 10;
      };

      mqtt = {
        enabled = true;
        user = "frigate";
        password = "{FRIGATE_MQTT_PASSWORD}";
        host = "azazel.local.phire.org";
      };

      detectors = {
        coral_pci = {
          type = "edgetpu";
          device = "pci";
        };
      };

      objects = {
        track = [
          "person"
          "car"
          "bicycle"
          "motorcycle"
          "dog"
          "cat"
          "bird"
        ];
      };

      go2rtc = {
        streams =
          (reolink_go2rtc_restream "patio" "reolink1.local.phire.org") //
          (reolink_go2rtc_restream "driveway" "reolink2.local.phire.org");
      };

      cameras = {
        patio = {
          zones = {
            carport_zone = {
              coordinates = "843,0,1092,107,1075,194,668,126,690,0";
              objects = [
                "person"
                "dog"
                "cat"
              ];
            };
            patio_zone = {
              coordinates = "382,720,1280,720,1280,236,1101,113,1088,198,672,113";
              objects = [
                "person"
                "dog"
                "cat"
              ];
            };
          };
          snapshots.required_zones = [
            "carport_zone"
            "patio_zone"
          ];
          record.events.required_zones = [
            "carport_zone"
            "patio_zone"
          ];
          ffmpeg.inputs = ffmpeg_restream_inputs "patio";
        };
        driveway = {
          zones = {
            shed_zone.coordinates = "1076,720,1280,720,1280,233,1127,236";
            property_zone = {
              coordinates = "0,530,43,720,1080,720,1134,244,1100,239,1087,196,981,201,763,278,674,284,610,293,484,260,364,262,246,278,0,335";
              objects = [
                "person"
                "dog"
                "cat"
              ];
            };
            driveway_zone = {
              coordinates = "0,382,225,456,610,720,1061,720,1100,588,723,415,606,364,587,307,427,296";
              objects = [
                "person"
                "car"
                "motorcycle"
                "bicycle"
              ];
            };
          };
          snapshots.required_zones = [
            "shed_zone"
            "driveway_zone"
            "property_zone"
          ];
          record.events.required_zones = [
            "shed_zone"
            "driveway_zone"
            "property_zone"
          ];
          ffmpeg.inputs = ffmpeg_restream_inputs "driveway";
        };
        porch = {
          ffmpeg.inputs = ffmpeg_wyzecam_inputs "wyzecam1.local.phire.org";
        };
        office = {
          ffmpeg.inputs = ffmpeg_wyzecam_inputs "wyzecam.local.phire.org";
        };
      };
    };
  };

  modules.interactive.enable = true;
  system.stateVersion = "23.05"; # Did you read the comment?
}

