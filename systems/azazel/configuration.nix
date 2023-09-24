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
      mqtt = {
        enabled = false;
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
        driveway.ffmpeg.inputs = [
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

  system.stateVersion = "23.05"; # Did you read the comment?
}

