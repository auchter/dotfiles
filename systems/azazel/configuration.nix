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

  hardware.bluetooth.enable = true;

  services.mpdpower = {
    enable = true;
    mpdHost = "localhost";
    btAddr = "00:12:92:08:07:B9";
  };

  # stereo config

  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/ssd/music";
    playlistDirectory = "/mnt/ssd/music/playlists";
    network = {
      listenAddress = "any";
    };
    extraConfig = ''
      resampler {
        plugin "libsamplerate"
        type "0"
      }

      auto_update "yes"
      replaygain "auto"
      audio_output {
        type    "fifo"
        name    "snapcast"
        path    "/run/snapserver/mpd"
        format  "44100:16:2"
        mixer_type "null"
      }
      audio_output {
        type   "null"
        name   "CamillaDSP"
        #device "hw:Loopback,0"
        #format "96000:32:2"
        mixer_type "null"
      }
      audio_output {
        type "pipewire"
        name "Pipewire"
        mixer_type "null"
      }
    '';
  };

  systemd.services.mpd.serviceConfig.restart = "always";

  modules.upmpdcli = {
    enable = true;
  };

  services.snapserver = {
    enable = true;
    openFirewall = true;
    http.docRoot = "${pkgs.snapcast}/share/snapserver/snapweb";
    streams = {
      mpd = {
        type = "pipe";
        location = "/run/snapserver/mpd";
        query = {
          mode = "create";
          sampleformat = "44100:16:2";
          codec = "ogg";
        };
      };
    };
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    systemWide = true;
  };

  environment.etc = {
    "pipewire/pipewire.conf.d/pipewire.conf".text = ''
      context.properties = {
        default.clock.rate = 96000
      }
      context.objects = [
	{ factory = adapter
          args = {
              factory.name     = api.alsa.pcm.sink
              node.name        = "camilladsp-sink"
              node.description = "Alsa Loopback"
              media.class      = "Audio/Sink"
              api.alsa.path    = "hw:Loopback,0,0"
              audio.format     = "S32LE"
              audio.rate       = 96000
              audio.channels   = 2
              priority.session = 1400
          }
	}
      ]
    '';
    "wireplumber/main.lua.d/81-stereo.lua".text = ''
    '';
  };

  systemd.services.pipewire.restartTriggers = [
    config.environment.etc."pipewire/pipewire.conf.d/pipewire.conf".text
  ];

  users.users.mpd.extraGroups = [ "audio" "pipewire" ];

  boot.kernelModules = [ "snd-aloop" ];

  services.mpdcamillamixer.enable = true;

  services.camillagui = {
    enable = true;
    openFirewall = true;
    port = 5001;
  };

  services.camilladsp = {
    enable = true;
    extraFilters = [
    ];
    config = let
      mixCopy = dest: channel: {
        inherit dest;
        sources = [ { inherit channel; } ];
      };
      mixMono = dest: src1: src2: {
        inherit dest;
        sources = map (channel: { inherit channel; gain = -6; }) [src1 src2];
      };
      mkBiquad = type: params: {
        type = "Biquad";
        parameters = { inherit type; } // params;
      };
      mkBiquadCombo = type: freq: order: {
        type = "BiquadCombo";
        parameters = {
          inherit type;
          inherit freq;
          inherit order;
        };
      };
      mkPipelineFilter = channels: filters: map (channel: {
        type = "Filter";
        inherit channel;
        names = filters;
      }) channels;
      mkPipelineMixer = name: [{
        type = "Mixer";
        inherit name;
      }];
    in {
      devices = {
        samplerate = 96000;
        chunksize = 4096;
        capture = {
          type = "Alsa";
          channels = 2;
          device = "hw:Loopback,1";
          format = "S32LE";
        };
        playback = {
          type = "Alsa";
          channels = 4;
          device = "surround40:CARD=M4,DEV=0";
          format = "S32LE";
        };
      };
      mixers = {
        main = {
          channels = {
            "in" = 2;
            "out" = 4;
          };
          mapping = [
            (mixCopy 0 0)
            (mixCopy 1 1)
            (mixCopy 2 0)
            (mixCopy 3 1)
            #(mixMono 2 0 1)
            #(mixMono 3 0 1)
          ];
        };
      };
      filters = {
        right_plugged_0 = mkBiquad "Peaking" { freq = 103.0; gain = -5.6; q = 3.818; };
        right_plugged_1 = mkBiquad "Peaking" { freq = 219.0; gain = -6.4; q = 4.693; };
        right_plugged_2 = mkBiquad "Peaking" { freq = 480.0; gain = -4.8; q = 1.203; };

        left_plugged_0 = mkBiquad "Peaking" { freq = 102.0; gain = -3.5; q = 4.998; };
        left_plugged_1 = mkBiquad "Peaking" { freq = 497; gain = -6.2; q = 2.590; };

        right_unplugged_0 = mkBiquad "Peaking" { freq = 49.35; gain = -3.5; q = 4.618; };
        right_unplugged_1 = mkBiquad "Peaking" { freq = 102.5; gain = -7; q = 3.442; };
        right_unplugged_2 = mkBiquad "Peaking" { freq = 219.0; gain = -6.3; q = 4.872; };
        right_unplugged_3 = mkBiquad "Peaking" { freq = 475.0; gain = -4.9; q = 1.259; };

        left_unplugged_0 = mkBiquad "Peaking" { freq = 65.7; gain = -4.5; q = 2.081; };
        left_unplugged_1 = mkBiquad "Peaking" { freq = 104.0; gain = -5.9; q = 4.067; };
        left_unplugged_2 = mkBiquad "Peaking" { freq = 497.0; gain = -7.4; q = 1.895; };

        highpass = mkBiquadCombo "LinkwitzRileyHighpass" 100 8;
        lowpass = mkBiquadCombo "LinkwitzRileyLowpass" 100 8;
        sub_l_0 = mkBiquad "Peaking" { freq = 43.6; gain = -4.6; q = 2.781; };
        sub_l_1 = mkBiquad "Peaking" { freq = 81.9; gain = -5.5; q = 1.498; };
        sub_r_0 = mkBiquad "Peaking" { freq = 49.75; gain = -4.0; q = 3.22; };
        sub_r_1 = mkBiquad "Peaking" { freq = 90.1; gain = -8.4; q = 1.0; };
      };
      pipeline = builtins.concatLists [
        (mkPipelineMixer "main")
        (mkPipelineFilter [0] [
          "highpass"
          #"left_unplugged_0"
          #"left_unplugged_1"
          #"left_unplugged_2"
        ])
        (mkPipelineFilter [1] [
          "highpass"
          #"right_unplugged_0"
          #"right_unplugged_1"
          #"right_unplugged_2"
          #"right_unplugged_3"
        ])
        (mkPipelineFilter [2] [
          "lowpass"
          "sub_l_0"
          "sub_l_1"
        ])
        (mkPipelineFilter [3] [
          "lowpass"
          "sub_r_0"
          "sub_r_1"
        ])
      ];
    };
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

  system.stateVersion = "23.05"; # Did you read the comment?
}

