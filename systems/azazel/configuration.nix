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

  modules.frigate = {
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
        streams = {
          patio_detect = [ "ffmpeg:http://reolink1.local.phire.org/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=frigate&password=frigate" ];
          patio_record = [ "ffmpeg:http://reolink1.local.phire.org/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=frigate&password=frigate" ];
          driveway_detect = [ "ffmpeg:http://reolink2.local.phire.org/flv?port=1935&app=bcs&stream=channel0_ext.bcs&user=frigate&password=frigate" ];
          driveway_record = [ "ffmpeg:http://reolink2.local.phire.org/flv?port=1935&app=bcs&stream=channel0_main.bcs&user=frigate&password=frigate" ];
        };
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
          ffmpeg = {
            inputs = [
              {
                path = "rtsp://127.0.0.1:8554/patio_record?video=copy&audio=aac";
                input_args = "preset-rtsp-restream";
                roles = [ "record" ];
              }
              {
                path = "rtsp://127.0.0.1:8554/patio_detect?video=copy";
                input_args = "preset-rtsp-restream";
                roles = [ "detect" ];
              }
            ];
          };
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
          ffmpeg.inputs = [
            {
              path = "rtsp://127.0.0.1:8554/driveway_record?video=copy&audio=aac";
              input_args = "preset-rtsp-restream";
              roles = [ "record" ];
            }
            {
              path = "rtsp://127.0.0.1:8554/driveway_detect?video=copy";
              input_args = "preset-rtsp-restream";
              roles = [ "detect" ];
            }
          ];
        };
      };
    };
  };

  system.stateVersion = "23.05"; # Did you read the comment?
}

