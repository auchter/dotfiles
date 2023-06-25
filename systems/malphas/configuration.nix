{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_5_15;
  boot.kernelPatches = lib.mkIf false [
    {
      name = "bluetooth";
      patch = null;
      extraConfig = ''
        BT_HCIUART_3WIRE y
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
    enable = true;
    nssmdns = true;
  };

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
        mixer_type "none"
      }
      audio_output {
        type   "alsa"
        name   "CamillaDSP"
        device "hw:Loopback,0"
        format "96000:32:2"
        mixer_type "software"
      }
      audio_output {
        type    "fifo"
        name    "brutefir"
        path    "/tmp/mpd"
        format  "96000:32:2"
        mixer_type "software"
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

#  services.pyhifid = {
#    enable = true;
#    backend = "PhirePreamp";
#  };
#
#  modules.snapclient = {
#    enable = true;
#    host = "localhost";
#    sampleFormat = "44100:16:*";
#    soundcard = "front:CARD=DAC,DEV=0";
#  };
#
  modules.brutefir = {
    enable = true;
    floatBits = 64;
    inputs = {
      "in" = {
        channels = 2;
        format = "S32_LE";
      };
    };
    outputs = {
      out = {
        channels = 4;
        format = "S32_LE";
      };
    };
    filters = {
      filter = {
        input = "in";
        output = "out";
      };
    };
    coeffs = {
      dirac.path = "dirac pulse";
      speakers.path = ./brutefir/speakers.wav;
      no_sub.path = ./brutefir/no_sub.wav;
      dt770.path = ./brutefir/dt770.wav;
      hd650 = {
        path = ./brutefir/hd650.pcm;
        rate = 48000;
        format = "S16_LE";
      };
    };
  };

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

  services.camilladsp = {
    enable = true;
    extraFilters = [
      ./mso.json
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
          device = "surround40:CARD=U192k,DEV=0";
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
            (mixMono 2 0 1)
            (mixMono 3 0 1)
          ];
        };
      };
      filters = {
        speaker_hp = mkBiquad "Highpass" { freq = 80; q = 0.5; };
        speaker_bump = mkBiquad "Peaking" { freq = 48; gain = -8; q = 2; };
        subs_lp = mkBiquad "Lowpass" { freq = 80; q = 0.5; };
        spk1 = mkBiquad "Peaking" { freq = 182.5; q = 4.096; gain = -5.4; };
        spk2 = mkBiquad "Peaking" { freq = 283; q = 4.924; gain = -7.7; };
        spk3 = mkBiquad "Peaking" { freq = 2244; q = 1.058; gain = -3.4; };
      };
      pipeline = builtins.concatLists [
        (mkPipelineMixer "main")
        (mkPipelineFilter [0 1] [
          "speaker_bump"
          "speaker_hp"
          "spk1"
          "spk2"
          "spk3"
        ])
        (mkPipelineFilter [2 3] [
          "subs_lp"
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
      name = "delta1-overlay";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&i2c0>;
            __overlay__ {
              status = "okay";
              delta1_set: gpio@3f {
                compatible = "nxp,pcf8574a";
                reg = <0x3f>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA1_SET_0",
                                  "DELTA1_SET_1",
                                  "DELTA1_SET_2",
                                  "DELTA1_SET_3",
                                  "DELTA1_SET_4",
                                  "DELTA1_SET_5",
                                  "DELTA1_SET_6",
                                  "DELTA1_SET_7";
              };

              delta1_rst: gpio@3e {
                compatible = "nxp,pcf8574a";
                reg = <0x3e>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA1_RST_0",
                                  "DELTA1_RST_1",
                                  "DELTA1_RST_2",
                                  "DELTA1_RST_3",
                                  "DELTA1_RST_4",
                                  "DELTA1_RST_5",
                                  "DELTA1_RST_6",
                                  "DELTA1_RST_7";
              };
            };
          };
        };
      '';
    }
    {
      name = "delta2-overlay";
      dtsText = ''
        /dts-v1/;
        /plugin/;
        / {
          compatible = "pine64,pine-h64-model-b";
          fragment@0 {
            target = <&i2c0>;
            __overlay__ {
              status = "okay";
              delta2_set: gpio@3d {
                compatible = "nxp,pcf8574a";
                reg = <0x3d>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA2_SET_0",
                                  "DELTA2_SET_1",
                                  "DELTA2_SET_2",
                                  "DELTA2_SET_3",
                                  "DELTA2_SET_4",
                                  "DELTA2_SET_5",
                                  "DELTA2_SET_6",
                                  "DELTA2_SET_7";
              };

              delta2_rst: gpio@3c {
                compatible = "nxp,pcf8574a";
                reg = <0x3c>;
                gpio-controller;
                gpio-cells = <2>;
                lines-initial-states = <0xF>;
                gpio-line-names = "DELTA2_RST_0",
                                  "DELTA2_RST_1",
                                  "DELTA2_RST_2",
                                  "DELTA2_RST_3",
                                  "DELTA2_RST_4",
                                  "DELTA2_RST_5",
                                  "DELTA2_RST_6",
                                  "DELTA2_RST_7";
              };
            };
          };
        };
      '';
    }
  ];

  system.stateVersion = "22.05"; # Did you read the comment?
}

