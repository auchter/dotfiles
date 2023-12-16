{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_5;
  boot.kernelPatches = [
    {
      name = "ina260";
      patch = ./PATCH-hwmon-Add-support-for-the-INA260-chip-to-the-INA219-and-compatibles-driver.patch;
      extraConfig = ''
        SENSORS_INA2XX y
      '';
    }
  ];

  networking.interfaces.eth0.useDHCP = true;
  modules.sshd.enable = true;

  fileSystems."/mnt/storage" = {
    device = "/dev/disk/by-uuid/053afcd9-26c3-4fde-8466-40280f1195b3";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  modules.syncthing = {
    enable = true;
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  hardware.bluetooth = {
    enable = true;
  };

  services.avahi = {
    enable = false;
    nssmdns = false;
  };

  system.activationScripts.irq-affinity = ''
    echo e > /proc/irq/39/smp_affinity
  '';

  services.mpd = {
    enable = true;
    dataDir = "/mnt/storage/mpd";
    musicDirectory = "/mnt/storage/music";
    playlistDirectory = "/mnt/storage/music/playlists";
    network = {
      listenAddress = "any";
    };
    extraConfig = ''
      resampler {
        plugin "libsamplerate"
        type "2"
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

  modules.upmpdcli = {
    enable = true;
  };

  services.mympd = {
    enable = false;
    openFirewall = true;
    logLevel = 3; # TODO: currently ignored, since mympd is being built in release mode
    mpdHost = "localhost";
    ssl = false;
  };

  environment.systemPackages = with pkgs; [
    camilladsp
    listenbrainz-mpd
  ];

  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
    4953
  ];

  sops.secrets.listenbrainz_pass = {};

  services.mpdscribble = {
    enable = false;
    endpoints = {
      "listenbrainz" = {
        username = "e8beb414513f8";
        passwordFile = config.sops.secrets.listenbrainz_pass.path;
      };
    };
  };

  services.listenbrainz-mpd = {
    enable = true;
    tokenFile = config.sops.secrets.listenbrainz_pass.path;
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

  services.ampctrl.enable = true;
  services.ttctrl.enable = true;
  services.mpdcamillamixer.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    systemWide = true;
  };

  users.users.mpd.extraGroups = [ "audio" "pipewire" ];

  boot.kernelModules = [ "snd-aloop" ];
  sound = {
    enable = true;
    extraConfig = ''
      pcm.!default {
        type plug
        slave.pcm "camilladsp"
      }

      pcm.camilladsp {
        type plug

        slave {
          pcm {
            type     hw
            card     "Loopback"
            device   0
            channels 2
            format   "S32_LE"
            rate     96000
          }
        }
      }

      ctl.!default {
        type hw
        card "Loopback"
      }
      ctl.camilladsp {
        type hw
        card "Loopback"
      }
    '';
  };

  services.camillagui = {
    enable = true;
    openFirewall = true;
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

  hardware.gpio.enable = true;
  hardware.i2c.enable = true;
  hardware.deviceTree.overlays = [
    {
      name = "preamp-line-names";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&pio>;
            __overlay__ {
              gpio-line-names =
                /* A */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* B */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* C */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* D */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "RELAY_PWR", "TRIG_OUT_0", "TRIG_OUT_1", "TRIG_OUT_2", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* E */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* F */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* G */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                /* H */ "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "";
            };
          };
        };
      '';
    }
    {
      name = "ina260";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@1 {
            target = <&i2c0>;
            __overlay__ {
              status = "okay";
              ina260@40 {
                compatible = "ti,ina260";
                reg = <0x40>;
              };
            };
          };
        };
      '';
    }
  ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

