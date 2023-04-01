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

  services.mpd = {
    enable = true;
    dataDir = "/mnt/storage/mpd";
    musicDirectory = "/mnt/storage/music";
    playlistDirectory = "/mnt/storage/music/playlists";
    network = {
      listenAddress = "any";
    };
    extraConfig = ''
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
        type    "fifo"
        name    "brutefir"
        path    "/tmp/mpd"
        format  "44100:32:2"
        mixer_type "software"
      }
    '';
  };

  services.mympd = {
    enable = false;
    openFirewall = true;
    logLevel = 3; # TODO: currently ignored, since mympd is being built in release mode
    mpdHost = "localhost";
    ssl = false;
  };

  environment.systemPackages = [
    pkgs.listenbrainz-mpd
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
      meta = {
        type = "meta";
        location = "/mopidy/mpd";
      };
      mopidy = {
        type = "pipe";
        location = "/run/snapserver/mopidy";
        query = {
          mode = "create";
          sampleformat = "44100:16:2";
        };
      };
      mpd = {
        type = "pipe";
        location = "/run/snapserver/mpd";
        query = {
          mode = "create";
          sampleformat = "44100:16:2";
        };
      };
    };
  };

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

  sound.enable = true;

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

