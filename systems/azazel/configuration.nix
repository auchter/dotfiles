{ config, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.interfaces.enp0s31f6.useDHCP = true;
  modules.sshd.enable = true;

  hardware.bluetooth.enable = true;

  services.mpdpower = {
    enable = true;
    mpdHost = "malphas";
    btAddr = "00:12:92:08:07:B9";
  };

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
    80 443 # nginx
  ];

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
    settings = {

      record = {
        enabled = true;
        events.retain.default = 10;
      };

      mqtt = {
        enabled = false;
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

  system.stateVersion = "23.05"; # Did you read the comment?
}

