{ config, pkgs, lib, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
      ../common
    ];

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

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
    device = "/dev/disk/by-uuid/6b2a302e-3678-454a-a7bd-3601a9d07f94";
    fsType = "ext4";
    options = [ "nofail" ];
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;

  hardware.bluetooth = {
    enable = true;
  };

  services.mpd = {
    enable = false;
    musicDirectory = "/mnt/storage/music";
    network = {
      listenAddress = "any";
    };
    extraConfig = ''
      replaygain "auto"
      audio_output {
        type    "fifo"
        name    "snapcast"
        path    "/run/snapserver/mpd"
        format  "44100:16:2"
        mixer_type "none"
      }
    '';
  };

  sops.secrets.mopidy-subidy_config = {
    owner = "mopidy";
  };

  services.mopidy = {
    enable = true;
    extensionPackages = with pkgs; [
      mopidy-mpd
      mopidy-subidy
    ];
    configuration = ''
      [mpd]
      enabled = true
      hostname = 0.0.0.0
      port = 6600
      [audio]
      output = audioresample ! audioconvert ! audio/x-raw,rate=44100,channels=2,format=S16LE ! filesink location=${config.services.snapserver.streams.mopidy.location}
    '';
    extraConfigFiles = [
      config.sops.secrets.mopidy-subidy_config.path
    ];
  };

  networking.firewall.allowedTCPPorts = [
    config.services.mpd.network.port
  ];

  sops.secrets.lastfm_pass = {};
  sops.secrets.librefm_pass = {};

  services.mpdscribble = {
    enable = true;
    endpoints = {
      "last.fm" = {
        username = "auchter";
        passwordFile = config.sops.secrets.lastfm_pass.path;
      };
      "libre.fm" = {
        username = "auchter";
        passwordFile = config.sops.secrets.librefm_pass.path;
      };
    };
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

  services.pyhifid = {
    enable = true;
    backend = "PhirePreamp";
  };

  modules.snapclient = {
    enable = true;
    host = "localhost";
    sampleFormat = "44100:16:*";
    soundcard = "front:CARD=DAC,DEV=0";
  };

  modules.brutefir = {
    enable = true;
    inputs = {
      "in" = {
        channels = 2;
        format = "S16_LE";
      };
    };
    outputs = {
      out = {
        channels = 2;
        format = "S16_LE";
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

